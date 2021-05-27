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

# Class Design
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

## Comments
### Header Comments


### Trailing Comments
Very short comments can appear on the same line as the code they describe, but should be shifted far enough to separate them from the statements. If more than one short comment appears in a chunk of code, they should all be indented to the same tab setting.

    if(accounts.size() == 1) {
    	isSingle = true;		//single account exist
    } else if(accounts.size() > 1) {
    	isMultiple = true;		//multiple accounts exist
    }

## Declarations
One declaration per line is recommended.
    Integer numberOfAccountsFound;
    DateTime earliestAccountCreatedDate;
    DateTime lastAccountCreatedDate;

Is preferable to 
    Integer numberOfAccountsFound;
    DateTime earliestAccountCreatedDate, lastAccountCreatedDate; //WRONG

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

