# Sansotti Code Review Process & Coding Standards

# Purpose
Overview of common roles in code reviews and coding standards. Please update the README file with a brief description around samples for every new module/scenario/functionality.


## Overview
This is an overview of Sansotti’s proposed Code Review Checklist.  There are 3 parties involved in the code review process:

-Developer
-Reviewer
-Release Manager

In general the code review should NEVER take more than 30 minutes, per story. If the change does require more time, then break the review into smaller components. Typically the review will be done via screen share (as we have a geographically diverse team), however, as our process becomes more mature the developer and reviewer can do it asynchronously. In certain cases, code review can take more time - depending on the complexity of the story and number of components involved.

The end goal here is to create high quality code, while building a strong foundational team.  All comments should be encouraging and focused on learning of all parties involved.

## Role of Developer
It’s the developer’s responsibility to schedule code reviews with the reviewer to ensure quality code is pushed for testing. The developer should reach out to the reviewer and ask him/her to complete the review process. Any feedback received should be incorporated into the PR and then should be reviewed again by the reviewer. Developer should respond to every comment left by the reviewer. 

## Role of the Reviewer
It’s the reviewer responsibility to review the code/configuration changes submitted by the developer. The Reviewer should put individual comments against every change/line where a change is needed and make it as informative as possible for suggested changes. The Reviewer should approve the PR once he/she is satisfied with the changes. The reviewer should get to the Code Review as soon as possible so that the process isn’t delayed.

## Role of the Release Manager
The release manager should ensure that every Pull Request is approved by atleast one reviewer before approving and merging the change. No PR should be approved and merged by the release manager without the approval of the reviewer present. (Refer to items to be reviewed to see exceptions).

## When should Code Review be Done
Code Review should be done after a Pull Request is created, before it’s merged/approved by the Release Manager.

## Where should Code Review be Done
Code Review should be done in the tool used for raising PRs, so that it’s easy to identify changes made vs existing code. For declarative changes (Process Builders, Flows, Workflows, Email Templates, etc), the Code Review should be done by coordinating with the developer and reviewing the changes in the developer’s sandbox before approving it as it is difficult to review declarative changes in the IDE.

## Components to be reviewed
Apex Class
Apex Trigger
VF Pages/Components
Aura Components
LWC
Workflows
Process Builders
Flows
Destructive Changes
Platform Events
Custom Metadata
Custom Settings
Creation of VF Email Templates
External Objects
Custom Buttons/Actions
Static Resources referred in code
Email Alerts
Field Updates
Test Classes (Should be present in original PR with rest of the changes)

## Not required to be reviewed
Creation of Custom Labels
Creation of Queues
Creation of Public Groups
Creation of Roles
Creation of Email Templates (Except VF Ones)
Reports
Dashboards
Report Types
Creation of Custom Fields
Page Layout changes
Profile changes
Permission Set changes
Creation of Custom Tabs/Connected Apps/etc.

# coding-standards

The purpose of this repository is to provide code snippets/examples for various modules/scenarios/functionalities that can (should) be used across various Client implementations. Please update the README file with a brief description around samples for every new module/scenario/functionality.


## Test Data Factory

The intent of this is to provide a base class example of how to create a test data factory and use it across various test classes. Please refer to methods from Test Data Factory to create records of specific object or custom setting.

The test methods in the class, **TestDataFactory** will have the bare minimum fields populated, which are required to insert a record for a particular Object/Custom Setting. This will change with every Organization, so this should only be treated as a reference and changes should be made as per the Organization one is working on.

For each method in the **TestDataFactory.cls** where object/custom setting records are returned, a Boolean field called, **commitRecords** should be present in the methods as a parameter. The purpose of this variable is to insert/not insert the record in the test data factory depending on if the value is true/false, before it's returned to the calling respective Test Class. This allows developers to change the value of the records, if required, before inserting the records. 

In order to create a method for a new record, the method should have paramters like:

    1. Number of Records
    2. Dependent Value to pass (Lets' say Picklist Value, or Parent Lookup/Master Object Record ID, etc)
    3. Boolean to Commit
    4. Include all required fields for the object only in the method definition in the TestDataFactory method, make modifications in the calling class.

        public static List<Object_API_Name__c> createObjectApiNameRecors(Integer numberOfRec, Value for picklist/Lookup 1, Value for picklist/Lookup 2, ....., Boolean commitRecords){

            List<Object_API_Name__c> ObjectApiNameList = new List<Object_API_Name__c>();
            for ( Integer i = 0; i < numberOfRec; i++ ) {
                ObjectApiNameList.add(new Object_API_Name__c(field1 = value 1,
                                    field2 = value 2, field3 = value 3,....);
            }
            if(commitRecords){
                insert ObjectApiNameList;
            }

            return ObjectApiNameList;

        }

## Naming Conventions 

### Class Names
Class names should be nouns in CamelCase with the first letter of each word capitalized. Try to keep class names simple and descriptive. Use whole words, avoid acronyms and abbreviations unless it is widely known (e.g. URL, HTML). 
Examples:
    public class ImageSprite { }
    public class AccountTriggerHandler { }

### Trigger Names
Should be named after sObject and and appended with Trigger. Examples:

    AccountTrigger
    ContactTrigger

### Variable Names
Variable names should be words. They should be clear and self explanatory. Avoid acronyms. Avoid redundancies. 
Avoid: 

    String nameString
    Integer countInteger
Specifying the variable type in the variable name does not add value. 

### Map Names
Map names should be “valueByKey”. For example: 

    Map<Id, Account> accountById
    Map<String, Account> accountByName
    Map<String, Account> accountByExternalId

### Method Names
Method names should be verbs. They should be self explanatory and should avoid acronyms.
do, is, set, get, query, run are all acceptable verbs to start a method name with. For example:

    setAccountName
    isAccountNamePopulated
    doQuarterlyCalculations
    queryAccounts
    getAccountName

### Parameter Names

## Design 
# Method Design
Methods should do 1 thing. If you find you are doing more than one thing, break it out into multiple methods. As a general rule of thumb, smaller methods are better methods. If a method passes 25 lines, it should be considered for refactoring. 

## SOQL Design Considerations
Database queries should be as narrow in scope as possible. However, queries into a single sObject should be performed once per sObject. If multiple methods need to access the same sObject with different filters, one query should be used and each method should filter the records needed. 

## Lazy Loading Queries
Queries that are only queried when needed (lazy loading) are preferrable to always querying. Example: 

    for(Account account: accounts) {
        if(account.Name == ‘’ && account.ParentId != null) {
            account.Name = accountById.get(account.Parent.Id).Name;
        }
    }
    public Map<Id, Account> accountById {get {
        if(accountById == null) {
            accountById = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN: accounts]);
        }
    }
    return accountById;
    } set;}

## Selector Layers
Selector layers are great! Highly recommend using a single class to select records from the database as needed. Drives consistencies and ensures all relevant fields are grabbed each time they are queried.

## DML
DML for generic sObject lists should always be sorted first. 
Example: 

    List<sObject> sobjects = new List<sObject>();
    sobjects.sort(); 	//MUST HAVE BEFORE DML
    insert sobjects;

Should avoid multiple DMLs on same sObject type. Combine all DML when possible. 

All DML should be wrapped in a try catch. 

# Naming Convention
------------------

## Classes: 
As per Object Oriented Programming language rules, class names should be nouns. They should define or describe a 
thing or entity. A class name should be camel-case. The first letter of each word in the class name should be 
capitalized.The class name should be simple and descriptive. Acronyms and abbreviations should be used sparingly 
and economically to avoid confusion. Do not use underscore or other special characters in a class name.
    
    e.g. Account, RevenueDepartment, MinecraftVehicle

There are a few recommended variations for different types of classes
Batch Apex Class: The class name should be suffixed by 'Batch'. 
     
     e.g. AccountRefundBatch, ValidateOpportunityBatch

Controller: The class name is typically suffixed by 'Controller' 
    
    e.g. SolarEnergyController, NewAccountController

Trigger: If your client follows the standard trigger, then the main sObject trigger 
name should be suffixed by 'Trigger', and the handler Class should be suffixed by 'TriggerHandler' 

    e.g. AccountTrigger, AccountTriggerHandler

Remember there are more than one Trigger pattern out there.

Amend your coding style according to the pattern selected.

Test Classes: A test class should be suffixed by 'Test'. 

    e.g. DebitAccountTest, CreditAccountTest

Interfaces:
Interface names follow the same rules as Classes and should be prefixed with a capital I e.g. IRecipe, ICoupon.  
Where the interface is describing the ability to be used in a certain way, the interface name should be an 
adjective and end with the suffix 'ible' or 'able' e.g. IBatchable

  
Variables: 
    Variable names should be mixed case with a lowercase first letter and each consecutive word starts with capital 
    letters. This rule applies to instance and class variables. They should not start with an underscore(_), a 
    dollar sign($), even though both are allowed. Infact you should avoid using underscores or special characters in 
    a variable name. Variables names should short yet meaningful. It should indicate the intent of its use. 
    Avoid single letter variable names like (i, j, k), unless they are used as a throwaway variable in a loop.

Constants:
    Constants (i.e. variables defined as static final int), are a special type of variable and a constant name 
    should be all uppercase with words seperated by underscores(_). Avoid any special characters in a constant name.
    e.g MIN_WIDTH, UK_CURRENCY

Methods:
    Method name should be a verb, an action. Like a variable name, it should be mixed case with a lowercase first 
    letter and the first letter of each internal word capitalized.

Documents:
    You should follow the following naming proto-pattern for Documents.
    'Project Name - Title of Document - Document Order - Version'

Declarations
One declaration per line is recommended.
    Integer numberOfAccountsFound;
    DateTime earliestAccountCreatedDate;
    DateTime lastAccountCreatedDate;

Is preferable to 
    Integer numberOfAccountsFound;
    DateTime earliestAccountCreatedDate, lastAccountCreatedDate; //WRONG


Code Layout and Formatting
--------------------------
A well formatted code increases readability, understanding and ultimately maintainability of the code base. 
A developer should strive to use a consistent layout and format. It will make the lives of other developers
(who want to read, review, or maintain your code) a lot easier. I have listed a few guidelines as to how a 
Force.com developer should format code. 

### Wrapping Lines:

When an expression will not fit on a single line, break it according to these general principles:
       * Break after a comma
       * Break before an operator
       * Prefer higher-level breaks to lower-level breaks
       * Align the new line with the beginning of the expression at the same level on the previous line.
       * If the above rules lead to confusing code or to code that's squished up against the right margin, just 
         indent 8 spaces instead. 

Here are some examples of breaking method calls:

       someMethod(longExpression1, longExpression2, longExpression3, 
                  longExpression4, longExpression5);
       var = someMethod1(longExpression1,
                         someMethod2(longExpression2,
                         longExpression3)); 

Following are two examples of breaking an arithmetic expression. 
The first is preferred, since the break occurs outside the parenthesized expression, which is at a higher level.

        longName1 = longName2 * (longName3 + longName4 - longName5)
                    + 4 * longname6; // PREFER

        longName1 = longName2 * (longName3 + longName4
                                 - longName5) + 4 * longname6; // AVOID 

Following are two examples of indenting method declarations. 
The first is the conventional case. 
The second would shift the second and third lines to the far right if it used conventional indentation, so 
instead it indents only 8 spaces.

    //CONVENTIONAL INDENTATION
    someMethod(int anArg, Object anotherArg, String yetAnotherArg,
        Object andStillAnother) {
    ...
    }

    //INDENT 8 SPACES TO AVOID VERY DEEP INDENTS
    private static void horkingLongMethodName(int anArg,
            Object anotherArg, String yetAnotherArg,
            Object andStillAnother) {
    ...
    }

Line wrapping for if statements should generally use the 8-space rule, since conventional (4 space)
indentation makes seeing the body difficult. For example:

    //DON'T USE THIS INDENTATION
    if ((condition1 && condition2)
        || (condition3 && condition4)
        ||!(condition5 && condition6)) { //BAD WRAPS
        doSomethingAboutIt();            //MAKE THIS LINE EASY TO MISS
    } 

    //USE THIS INDENTATION INSTEAD
    if ((condition1 && condition2)
            || (condition3 && condition4)
            ||!(condition5 && condition6)) {
        doSomethingAboutIt();
    } 

    //OR USE THIS
    if ((condition1 && condition2) || (condition3 && condition4)
            ||!(condition5 && condition6)) {
        doSomethingAboutIt();
    } 

Here are three acceptable ways to format ternary expressions:

    alpha = (aLongBooleanExpression) ? beta : gamma;  

    alpha = (aLongBooleanExpression) ? beta
                                    : gamma;  

    alpha = (aLongBooleanExpression)
            ? beta 
            : gamma;  


### Placement:

Put declarations only at the beginning of blocks. (A block is any code surrounded by curly braces "{" and "}".) 
Don't wait to declare variables until their first use; it can confuse the unwary programmer and hamper code portability within the scope.

    void myMethod() {
        int int1 = 0;         // beginning of method block

        if (condition) {
            int int2 = 0;     // beginning of "if" block
        }
    }

The one exception to the rule is indexes of for loops, which in Java can be declared in the for statement:

    for (int i = 0; i < maxLoops; i++) { ... }

Avoid local declarations that hide declarations at higher levels. For example, do not declare the same variable name in an inner block:

    int count;
    ...
    myMethod() {
        if (condition) {
            int count = 0; // AVOID!
        ...
        }
    ...
    }
  
  ### Header Comments
  
All files should begin with a c-style comment that lists the company, date, author, description, and history:
    
    /*
    * Company
    * Date
    * Author
    * Description
    * History
    */

### Trailing Comments
Very short comments can appear on the same line as the code they describe, but should be shifted far enough to separate them from the statements. If more than one short comment appears in a chunk of code, they should all be indented to the same tab setting.

    if(accounts.size() == 1) {
    	isSingle = true;		//single account exist
    } else if(accounts.size() > 1) {
    	isMultiple = true;		//multiple accounts exist
    }


### Class and Interface Declarations:

When coding Apex classes and interfaces, the following formatting rules should be followed:
    * No space between a method name and the parenthesis "(" starting its parameter list
    * Open brace "{" appears at the end of the same line as the declaration statement 
    * Closing brace "}" starts a line by itself indented to match its corresponding opening statement, except when it is a null statement the "}" should appear immediately after the "{"

    class Sample extends Object {
        int ivar1;
        int ivar2;

        Sample(int i, int j) {
            ivar1 = i;
            ivar2 = j;
        }

        int emptyMethod() {}

    }

### if, if-else, if else-if else Statements:

The if-else class of statements should have the following form:

    if (condition) {
        statements;
    }
    
    if (condition) {
        statements;
    } else {
        statements;
    }
    
    if (condition) {
        statements;
    } else if (condition) {
        statements;
    } else {
        statements;
    }

Note: if statements should always use braces {}. Avoid the following error-prone form:
        
    if (condition) //AVOID! THIS OMITS THE BRACES {}!
        statements;
        
### for Loop

A for loop should have the following format:
        
    //traditional for loop
    for (initStatement; exitCondition, incrementStatement) {
        //code block
    }

    //set iteration for loop
    for (variable : list_or_set) {
        //code block
    }

    //SOQL for loop
    for (variable : [soql query]) {
        //code block
    }

Make sure you break the query into multiple lines if it is a long query.


### try-catch Statements:

A try-catch statement should have the following format:

    try {
        statements;
    } catch (ExceptionClass e) {
        statements;
    }

A try-catch statement may also be followed by finally, which executes regardless of whether or not the try block has completed successfully.

    try {
        statements;
    } catch (ExceptionClass e) {
        statements;
    } finally {
        statements;
    }

### Blank Lines:

Blank lines improve readability by setting off sections of code that are logically related.

Two blank lines should always be used in the following circumstances:

    * Between sections of a source file
    * Between class and interface definitions 

One blank line should always be used in the following circumstances:

    * Between methods
    * Between the local variables in a method and its first statement
    * Before a block or single-line comment
    * Between logical sections inside a method to improve readability

Best Practices
--------------
These are the key coding principles and best practices that will ensure we write efficient, scalable code.

### Keep code stupid simple:
  
There should be as little logic in your code as possible. Reusing code in several places, should be replaced with a single method and reduce the clutter in the code base.
    
      //BAD EXAMPLE
    public boolean isTrue(boolean myBool){
        if(myBool){
            return true;
        }else{
            return false;
        }
    }
      
    public Map<Id,Contact> getContactMap(){
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
          
        List<Contact> contacts = [Select Id From Contact];
        if(contacts != null && contacts.size() > 0 && !contacts.isEmpty()){
            for(Integer i=0; i < contacts.size(); i++){
                contactMap.put(contacts.get(i).Id,contacts.get(i));
            }
        }
        return contactMap;
    }
    
      //GOOD Example
      public boolean isTrue(boolean myBool){
          return myBool;
      }
       
      public Map<Id,Contact> getContactMap(){
          return new Map<Id,Contact>([Select Id From Contact]);
      }
  
### Do not put queries in loops:
  
    One of the most stringent governor limits is a SOQL query limit of 100 queries in a transaction.
    To avoid this simply do not put queries in for loops.
    
      //BAD example
      List<Account> accList = new List<Account>([Select Id,Name From Account]);
       
      for(Account acc : accList){
          Integer numWithEmail = 0;
          for(Contact cont : [Select Id,Email From Contact Where AccountId = :acc.Id]){
              if(!String.isEmpty(cont.Email)){
                  numWithEmail++;
              }
          }
      }
      
      //GOOD Example
      List<Account> accList = new List<Account>(
          [SELECT Id, Name,
            (SELECT Email FROM Contacts)
            FROM Account]
      );
       
    for(Account acc : accList){
        Integer numWithEmail = 0;
        for(Contact cont : acc.Contacts){
            if(!String.isEmpty(cont.Email)){
                numWithEmail++;
            }
        }
    }
    
### Use maps for queries:
  
This is a fundamental technique and trick to use in order to make SOQL queries, DML transactions, and Apex triggers more efficient. You can get a Map from a list, without a For Loop. For exampe:
    
    Map<Id, sObject> myAwesomeMap = new Map<Id,sObject>(List of sObjects or SOQL Query);
    
### Use relationships to reduce queries
  
SOQL allows you to query for parent/children record information. 
    
    List<Account> accList = new List<Account>(
        [SELECT Id, Name,
            (SELECT Email FROM Contacts)
        FROM Account]
    );
       
    List<Account> accountsToUpdate = new List<Account>(); 
        for(Account acc : accList){
            Integer numWithEmail = 0;
            for(Contact cont : acc.Contacts){
                if(!String.isEmpty(cont.Email)){
                    numWithEmail++;
                }
            }
            acc.Contacts_With_Email_Address__c = numWithEmail;
            accountsToUpdate.add(acc);
        }
    update accountsToUpdate;
    
### Do not put DML in loops:

DML means any insert, update, delete, undelete, merge, convertLead transaction. To avoid governor limits
simply by not putting DML in for loops, and generally speaking, make sure you're acting on multiple records.

### Only use one trigger per object:

Having multiple triggers across the same object greatly increases the complexity of your Salesforce org.
By consolidating any triggers, you are less prone to mistakes, and business processes are easier to maintain.

### Keep logic outside of triggers:

Triggers should only contain a handful of lines of code, used for calling methods. The trigger should be used
for managing execution order, and delegate all else to a separate Apex class such as a trigger helper.

### Have a happy balance between clicks and code:
  
Knowing when to use declarative features rather than jumping straight into an Apex or Visualforce solution
will greatly help reduce the complexity of the code base, and improve performance and maintenance.
    
### Write test code:
  
You should always aim for 100% code coverage. The goal is get as high a code coverage as is sensible. 
    
### Avoid hardcoding IDs:
  
It is paramount to avoid hardcoding IDs in the Apex code. By ensuring no IDs are stored in the Apex code,
you are making the code much more dynamic and flexible, allowing for safe deployments between environments.

# Class Structure
Elements in a class should be structured in the following order:
Header Comments
Constants
Static Variables (first public, then private)
Instance Variables (first public, then private)
Static Initializers
Factory Methods
Constructors
Static Methods (first public, then private)
Instance Methods
Inner Classes

    /*
    * @author MyNamegoesHere
    * @version versionX.x.x
    * @description DESCRIPTION_GOES_HERE
    */
    public class YourClass {
    /* Instance Variables */
    /* Static Variables */
    /* Constants */
    /* Static Initializers */
    /* Factory Methods */
    /* Constructors */
    /* Instance Methods */
    /* Static Methods */
    /* Inner Classes */
    }

## Asynchronous Threads

### Future
Should always check to see if running in future or batch context already before invoking a future thread.

    if(!System.isBatch() && !System.isFuture()) {
        runFuture();
    }

### Batch
Should always check to see if running in future or batch context already before invoking a batch thread.
Should not invoke a batch job from a trigger. 

    if(!System.isBatch() && !System.isFuture()) {
        runBatch();
    }

### Queueable
Should avoid queuables. It is the asynchronous choice of the last result.
Platform Events
Use with caution. Should prevent infinite recursions by using static variables to prevent a platform event from reinvoking itself. 
Scheduled Jobs
Use rarely. Orgs are limited to a total of 100 scheduled jobs.

### Schedulable

### Time Based Flows

### Time Based Workflows

