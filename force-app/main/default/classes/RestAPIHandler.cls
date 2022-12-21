public abstract class RestAPIHandler {    

    // request/response variables
    protected RestRequest request;
    protected Map<String, Object> parameters;
    protected Map<String, String> uriParams;
    protected Map<String, String> headers;
    protected List<String> uriParts;
    protected String requestBody;
    protected RestAPIResponse response;

    // debugging variables
    protected String operation = 'RestAPIHandler';
    protected String apiAction;
    protected API_Log__c apiLog;
    protected List<Exception> errors;
    protected List<String> debugInfo;
    protected Boolean debugMode = true;     //can be set using custom label or during test execution.

    // lookup variables
    protected Account currentAccount;
    protected Contact currentContact;

    protected Savepoint snapshot;
    
    // GET method - Will need to be implemented by the Child Class
    private abstract void processGET();

    // POST method - Will need to be implemented by the Child Class
    private abstract void processPOST();

    protected virtual void processPUTWithoutRollback() {

    }

    // DELETE - This is an example, where DELETE is not being implemented. If this is needed, declare it as abstract method 
    // if it will be used for all implementations, otherwise - just override the function in the Child Class, and let it be virtual.
    protected virtual void processDELETE() {
        response = new RestAPIResponse(405, 'METHOD_NOT_ALLOWED', 'METHOD_NOT_ALLOWED');
    }

    // Main method - to be called by the Rest Resource class using the handler class.
    // Rest Resouce class should have a handler class that extends the RestAPIHandler abstract class. 
    public void processRequest() {
        initialize();

        Boolean requiresRollback = false;

        try {
            parseRequest();

            switch on request.httpMethod {
                when 'GET' {
                    //snapshot = Database.setSavepoint();
                    processGET();
                } when 'POST' {
                    //snapshot = Database.setSavepoint();
                    processPOST();
                } when 'DELETE' {
                    //snapshot = Database.setSavepoint();
                    processDELETE();
                } when 'PUT' {
                    processPUTWithoutRollback();
                } when else {       
                    response = new RestAPIResponse(405, 'METHOD_NOT_ALLOWED', 'METHOD_NOT_ALLOWED');
                }
            }
        
        } catch ( RestAPIException ex ) {
            setExceptionResponse(ex);
            clearDanglingLookups();
            requiresRollback = true;

        } catch ( Exception ex ) {
            setGenericExceptionResponse(ex);
            clearDanglingLookups();
            requiresRollback = true;

        } finally {

            if ( requiresRollback && snapshot != null ) {
                Database.rollback(snapshot);
            }

            String responseBody = '';

            try {

                RestContext.response.statusCode = 500;      //setting response to Generic Error Code by default.
                if ( response != null ) {
                    responseBody = JSON.serialize(response);
                    RestContext.response.statusCode = response.statusCode;
                }
                System.debug('responseBody: ' + responseBody);
                System.debug('response status code: ' + RestContext.response.statusCode);

                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.addHeader('Context-Length', String.valueOf(responseBody.length()));
                RestContext.response.responseBody = Blob.valueOf(responseBody);

            } catch ( Exception ex ) {
                System.debug(LoggingLevel.ERROR, 'ERROR IN finally BLOCK: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
                logException(ex);
            } finally {
                addDebugInfo(APILogUtility.fetchTransactionLimits(operation));
                logRequest();
            }

        }
    }

    private void initialize() {
        
        errors = new List<Exception>();
        debugInfo = new List<String>();
        request = RestContext.request;
        headers = new Map<String, String>();
        parameters = new Map<String, Object>();
        uriParts = new List<String>();
        uriParams = new Map<String, String>();

        apiLog = (new APILogUtility('Rest API Framework')).apiLogRecord;    //Provide name of Functionality you want to log, in the APILogUtility() method

    }

    protected void initializeSavePoint() {
        snapshot = Database.setSavepoint();
    }

    private void clearDanglingLookups() {
        //Purpose of this function is to clear lookups/parent/dependent records created as a result of the operation 
        //which failed, and if API Log has references to these created records, then to null it - in order
        //to avoid exception.

        //Implement as needed. 
    }

    private void setExceptionResponse(RestAPIException ex) {
        logException(ex);
        response = new RestAPIResponse(ex.getResponseCode(), ex.getErrorType(), ex.getErrorMessage());
    }

    private void setGenericExceptionResponse(Exception ex) {
        logException(ex);
        response = new RestAPIResponse(500, 'INTERNAL_SERVER_ERROR', 'An unexpected error occurred, Please contact your system administrator.');
    }

    private void parseRequest() {
        try {
            requestBody = '';
            if ( request.requestBody != null ) {
                requestBody = request.requestBody.toString();
                parameters = String.isNotBlank(requestBody) ? (Map<String, Object>)JSON.deserializeUntyped(requestBody) : new Map<String, Object>();
            }
            uriParams = request.params;
            uriParts = new List<String>();
            if ( request.requestURI != null ) {
                uriParts = request.requestURI.split('/');
            }

            if ( request.headers != null ) {
                for ( String headerKey : request.headers.keySet() ) {
                    headers.put(headerKey.toUpperCase(), request.headers.get(headerKey));
                }
            }

        } catch ( Exception ex ) {
            logException(ex);
            throw new InvalidInputException('Unable to parse request - please confirm your request format is valid.');
        } finally {
            //This can be utilised to print the request, for debugging purposes.
            debugRequest();
        }
    }

    protected void logException(Exception ex) {
        System.debug(LoggingLevel.ERROR, 'logException:\n' + ex.getMessage() + '\n' + ex.getStackTraceString());
        errors.add(ex);
    }

    protected void logRequest() {
        try {

            RestResponse resp = RestContext.response;
            
            apiLog.Action__c = apiAction;
            apiLog.Direction__c = 'Inbound';
            apiLog.Request_Body__c = request.requestBody?.toString().left(APILogUtility.MAX_LEN_REQUEST_BODY);
            apiLog.Response_Body__c = resp.responseBody?.toString().left(APILogUtility.MAX_LEN_RESPONSE_BODY);

            apiLog.Response_Status_Code__c = resp?.statusCode;
            apiLog.Response_Length__c = apiLog.Response_Body__c?.length();

            apiLog.Request_Params__c = String.valueOf(uriParams);
            apiLog.Request_URI__c = request.requestURI;
            apiLog.Request_Headers__c = String.valueOf(headers);
            apiLog.Resource_Path__c = request.resourcePath;
            apiLog.Remote_Address__c = request.remoteAddress;
            apiLog.Request_Method__c = request.httpMethod;

            apiLog.Class_Name__c = 'RestAPIHandler';        //put the name of the main Rest Resource Class.

            APILogUtility tempLogUtility = new APILogUtility(apiLog);
            tempLogUtility.addDebugInfo(debugInfo);
            tempLogUtility.addErrors(errors);

            //implement this if you wish to notify on Errors. If one wants to notify only in case of specific errors, can be
            //modified as ndded.
            if ( tempLogUtility.hasErrors() ) {
                String msgBody = apiLog.Errors__c + '\n------------------\n' + apiLog.Response_Body__c;
                tempLogUtility.notifyDefault('REST API Errors', msgBody);
            }

            tempLogUtility.commitLog();

        } catch ( Exception e ) {
            System.debug(LoggingLevel.ERROR, 'logRequest exception.' + e);
            API_Log__c backupLog = new API_Log__c();
            backupLog.Tag__c = 'RESTAPI LOG ERROR BACKUP';
            try {
                backupLog.Errors__c = 'line ' + e.getLineNumber() + ': ' + e.getMessage() + '\n' + e.getStackTraceString();
                backupLog.Request_Body__c = JSON.serialize(apiLog).left(APILogUtility.MAX_LEN_REQUEST_BODY);
            } catch ( Exception e2 ) {
                System.debug(LoggingLevel.ERROR, e2.getMessage() + '\n' + e2.getStackTraceString());
            }
            insert backupLog;
        }
    }

    protected void addDebugInfo(String str) {
        debugInfo.add(str);
    }

    protected void addDebugInfo(List<String> strs) {
        debugInfo.addAll(strs);
    }

    protected void debugRequest() {
        if ( debugMode ) {
            //System.debug statements to print out various properties of Rest Request.
        }
    }

    protected String getParamFromUri(Integer index) {
        String param;
        if ( index != null && uriParts.size() >= index+1 ) {
            param = uriParts.get(index);
        }
        return param;
    }

    //Try and check for DML Limit and SOQL Limits, if we can capture it. 
    // exception handling tied directly to response structure

    public virtual interface RestAPIExceptionInterface {
        String getErrorType();
        String getErrorMessage();
        Integer getResponseCode();
        Integer getErrorCode();
    }

    public abstract class RestAPIException extends Exception implements RestAPIExceptionInterface {
        public abstract String getErrorType();
        public abstract String getErrorMessage();
        public abstract Integer getResponseCode();
        public virtual Integer getErrorCode() {
            return null;
        }
        protected List<Object> additionalData;
        public List<Object> getAdditionalData() {
            return (additionalData!=null ? additionalData : new List<Object>());
        }
    }

    public class InternalServerErrorException extends RestAPIException {
        public override String getErrorType() {
            return 'INTERNAL_SERVER_ERROR';
        }
        public override String getErrorMessage() {
            return 'Unable to process the request, Please contact your system administrator.';
        }
        public override Integer getResponseCode() {
            return 500;
        }
    }

    public class UnauthenticatedException extends RestAPIException {
        public override String getErrorType() {
            return 'UNAUTHENTICATED';
        }
        public override String getErrorMessage() {
            return 'Missing or invalid authentication header';
        }
        public override Integer getResponseCode() {
            return 401;
        }
    }


    public class InvalidInputException extends RestAPIException {
        public override String getErrorType() {
            return 'INVALID_INPUT';
        }
        public override String getErrorMessage() {
            return this.getMessage();
        }
        public override Integer getResponseCode() {
            return 400;
        }
    }


    public virtual class ValidationException extends RestAPIException {
        public override String getErrorType() {
            return 'VALIDATION_ERROR';
        }
        public override String getErrorMessage() {
            return this.getMessage();
        }
        public override Integer getResponseCode() {
            return 400;
        }
    }

    public class UnexpectedException extends RestAPIException {
        public override String getErrorType() {
            return 'UNEXPECTED_ERROR';
        }
        public override String getErrorMessage() {
            return this.getMessage();
        }
        public override Integer getResponseCode() {
            return 400;
        }
    }

}