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

    public static List<User> createUsers(Integer numUsers, String profileName, Boolean commitRecords) {
        List<User> users = new List<User>();
        for ( Integer i = 0; i < numUsers; i++ ) {
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


}
