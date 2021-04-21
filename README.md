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
