@isTest
public class RestAPIHandlerTest {
    
    static testmethod void testExceptions() {
        try {
            throw new RestAPIHandler.InternalServerErrorException();
        } catch ( RestAPIHandler.RestAPIException e ) {
            System.debug(e.getErrorMessage() + '  ' + e.getResponseCode() + '  ' + e.getErrorType());
        }
        
        try {
            throw new RestAPIHandler.UnauthenticatedException();
        } catch ( RestAPIHandler.RestAPIException e ) {
            System.debug(e.getErrorMessage() + '  ' + e.getResponseCode() + '  ' + e.getErrorType());
        }
        
        try {
            throw new RestAPIHandler.InvalidInputException('Invalid Input');
        } catch ( RestAPIHandler.RestAPIException e ) {
            System.debug( e.getErrorMessage() + '  ' + e.getResponseCode() + '  ' + e.getErrorType());
        }
        
        try {
            throw new RestAPIHandler.ValidationException('Validation Exception');
        } catch ( RestAPIHandler.RestAPIException e ) {
            System.debug(e.getErrorMessage() + '  ' + e.getResponseCode() + '  ' + e.getErrorType());
        }
        
        try {
            throw new RestAPIHandler.UnexpectedException('Unexpected');
        } catch ( RestAPIHandler.RestAPIException e ) {
            System.debug(e.getErrorMessage() + '  ' + e.getResponseCode() + '  ' + e.getErrorType());
        }

    }

    static testMethod void testHandlerClass() {

        //Test GET
        RestRequest req = new RestRequest();
        req.httpMethod = 'GET';
        req.requestURI = '/TestURI/';
        req.addHeader('TestHeader', 'TestValue');
        req.addParameter('TestParameter', 'TestValue');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        TestRestAPIHandler testHandler = new TestRestAPIHandler();
        testHandler.processRequest();
        system.assertEquals(1, [SELECT Id FROM API_Log__c].size());

        //Test POST - No Body
        req = new RestRequest();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        testHandler = new TestRestAPIHandler();
        testHandler.processRequest();
        system.assertEquals(2, [SELECT Id FROM API_Log__c].size());
        
        //Test POST - Blank Body
        req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        testHandler = new TestRestAPIHandler();
        testHandler.processRequest();
        system.assertEquals(3, [SELECT Id FROM API_Log__c].size());
        
        //Test POST - Valid Body
        req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"testKey":"testValue"}');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        testHandler = new TestRestAPIHandler();
        testHandler.processRequest();
        system.assertEquals(4, [SELECT Id FROM API_Log__c].size());
        
        //Test POST - Invalid Body
        req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"testKey":"testValue","testKey2":"testValue2" "testKey3":"testValue3"}');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        testHandler = new TestRestAPIHandler();
        testHandler.processRequest();
        system.assertEquals(5, [SELECT Id FROM API_Log__c].size());
        
        //Test PUT
        req = new RestRequest();
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        testHandler = new TestRestAPIHandler();
        testHandler.processRequest();
        system.assertEquals(6, [SELECT Id FROM API_Log__c].size());
        
        //Test DELETE
        req = new RestRequest();
        req.httpMethod = 'DELETE';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        testHandler = new TestRestAPIHandler();
        testHandler.processRequest();
        system.assertEquals(7, [SELECT Id FROM API_Log__c].size());
        
        //No METHOD
        req = new RestRequest();
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        testHandler = new TestRestAPIHandler();
        testHandler.processRequest();
        system.assertEquals(8, [SELECT Id FROM API_Log__c].size());
    }

    public class TestRestAPIHandler extends RestAPIHandler {

        public void processGET(){
			initializeSavePoint();
            String uriValue = getParamFromUri(1);
        }

        public void processPOST(){
			initializeSavePoint();
        }
    }

}