@isTest
public without sharing class TestDataFactory {
    
    private static Map<String, Id> profileCache = new Map<String, Id>();
    
    public static Id getProfileId(String profileName) {
        if ( !profileCache.containsKey(profileName) ) {
            Profile prof = [select Id, Name from Profile where Name = :profileName];
            profileCache.put(prof.Name, prof.Id);
        }
        return profileCache.get(profileName);
    }

    public static List<User> createUsers(Integer numRecords, String profileName, Boolean commitRecords) {
        List<User> users = new List<User>();
        for ( Integer i = 0; i < numRecords; i++ ) {
            users.add(new User(
                ProfileId = getProfileId(profileName),
                FirstName = 'FirstName ' + i,
                LastName = 'LastName ' + i,
                Email = 'testUser' + i + '@testUserDomain.com',
                Username = 'testUser' + i + '@testUserDomain.com',
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            ));
        }
        if ( commitRecords ) {
            insert users;
        }
        return users;
    }

    public static List<Account> createAccount(Integer numRecords, Boolean commitRecords){
        List<Account> accountList = new List<Account>();
        for ( Integer i = 0; i < numRecords; i++ ) {
            accountList.add(new Account(
                Name = 'Test Account ' + i,
                Type = 'Customer',
                Industry = 'Technology'
            ));
        }
        if ( commitRecords ) {
            insert accountList;
        }
        return accountList;
    }

    public static List<Contact> createContact(Integer numRecords, Id accountId, Boolean commitRecords){
        List<Contact> contactList = new List<Contact>();
        if(accountId == null){
            List<Account> accList = createAccount(1,true);
            accountId = accList[0].Id;
        }
        for ( Integer i = 0; i < numRecords; i++ ) {
            contactList.add(new Contact(
                    FirstName = 'Test First Name ' + i,
                    LastName = 'Test Last Name ' + i,
                    Email = 'test' + i + '@testemail.com',
                    Phone = '555867530' + String.valueOf(i),
                    AccountId = accountId ));
        }
        if ( commitRecords ) {
            insert contactList;
        }
        return contactList;

    }


}
