public without sharing class HTTPCalloutHandler {
    
    public static final Integer MAX_CALLOUT_TIME = 120000;

    //Request Variables
    public String endpoint;
    public String method;
    public Integer timeout;
    public Object requestBody;
    public Map<String, String> requestHeader;
    public Map<String, String> urlParamsMap;
    public HttpRequest request;

    public API_Log__c apiLog;
    public List<Exception> errors;
    public List<String> debugInfo;

    // define these in the calling class using this class's instance, before the processRequest() call.
    public String operation = 'HTTPCalloutUtility';
    public String action = 'HTTPCalloutUtility';
    public String className = 'HTTPCalloutUtility';

    //Response Variables
    public Integer responseStatusCode;
    public String responseStatus;
    public String responseBodyString;
    public Blob responseBodyBlob;
    public Map<String,String> responseHeaders;
    public HttpResponse response;

    public HTTPCalloutHandler(String endpoint, String method, Integer timeout, Object requestBody, Map<String, String> requestHeader, Map<String, String> urlParamsMap) {
        
        this.requestHeader = new Map<String, String>();
        this.urlParamsMap = new Map<String, String>();
        
        this.endpoint = endpoint;
        this.method = method;
        this.timeout = timeout;
        this.requestBody = requestBody;
        
        if ( requestHeader != null ) {
            this.requestHeader = requestHeader;
        }
        
        if ( urlParamsMap != null ) {
            this.urlParamsMap = urlParamsMap;
        }
    }

    //In Order to make a callout, declare an instance of the HTTPCalloutHandler class, with appropriate parameters,
    //and call the processRequest method. This will create the HTTP Request, attempt to make the callout and store
    //the request/response in the API Log, and insert it.
    public void processRequest() {
        try {
            
            //Step 1 -> Initialize debugging and other variables
            initialize();

            //Step 2 -> Prepare HTTP Request
            prepareHttpRequest();

            //Step 3 -> Make Callout
            makeCallout();

            //Step 4 -> Parse Response
            processResponse();

        } catch (Exception ex) {
            logException(ex);
        } finally {
            addDebugInfo(APILogUtility.fetchTransactionLimits(operation));
            logRequest();
        }
    }

    private void initialize() {
        errors = new List<Exception>();
        debugInfo = new List<String>();
        request = new HttpRequest();
        responseHeaders = new Map<String,String>();

        apiLog = (new APILogUtility('Rest API Framework')).apiLogRecord;
    }
    
    public void prepareHttpRequest() {
        
        if ( String.isEmpty(endpoint) || String.isEmpty(method) ) {
            throw new HttpCalloutException('HTTP Request endpoint and method are required to make a callout.');
        }

        appendURLParameters();

        request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);

        if ( requestBody != null ) {
            if ( requestBody instanceof String ) {
                request.setBody( (String)requestBody );
            } else if ( requestBody instanceof Blob ) {
                request.setBodyAsBlob( (Blob)requestBody );
            } else {
                request.setBody( JSON.serialize(requestBody, true) );
            }
        }
        
        addHeaderParameters();        
    }

    private void appendURLParameters() {
        
        if( !urlParamsMap.isEmpty() ) {
            endpoint += '?';
            for ( String urlParamKey : urlParamsMap.keySet() ) {
                endpoint += urlParamKey + '=' + urlParamsMap.get(urlParamKey) + '&';
            }
            endpoint = endpoint.substringBeforeLast('&');
        }
    }

    private void addHeaderParameters() {

        if( !requestHeader.isEmpty() ){
            for ( String key :requestHeader.keySet() ) {
                request.setHeader(key, requestHeader.get(key));
            }
        }
    }

    private void makeCallout() {
        if ( request == null ) {
            throw new HttpCalloutException('HttpRequest cannot be null');
        }

        response = (new Http()).send(request);
    }

    private void processResponse() {
        if ( response == null ) {
            throw new HttpCalloutException('HTTP Response is null.');
        }

        responseStatusCode = response.getStatusCode();
        responseStatus = response.getStatus();
        responseBodyString = response.getBody();
        responseBodyBlob = response.getBodyAsBlob();
        responseHeaders = getHeaders();
    }

    private Map<String, String> getHeaders() {
        Map<String, String> retHeaders = new Map<String, String>();
        if ( response != null && response.getHeaderKeys() != null ) {
            for ( String key : response.getHeaderKeys() ) {
                if ( key != null ) {
                    retHeaders.put(key, response.getHeader(key));
                }
            }
        }
        return retHeaders;
    }

    private void logRequest() {
        try {
            
            apiLog.Action__c = action;
            apiLog.Direction__c = 'Outbound';
			
			apiLog.Request_Method__c = method;
            apiLog.Request_URI__c = endpoint;
			apiLog.Request_Headers__c = JSON.serializePretty(requestHeader);		//TO DO - write a method to remove sensitive information from the header.
			apiLog.Request_Body__c = requestBody?.toString().left(APILogUtility.MAX_LEN_REQUEST_BODY);
			apiLog.Request_Params__c = String.valueOf(urlParamsMap);
            
			apiLog.Response_Status_Code__c = responseStatusCode;
            apiLog.Response_Length__c = apiLog.Response_Body__c?.length();
			apiLog.Response_Body__c = responseBodyString?.left(APILogUtility.MAX_LEN_REQUEST_BODY);
			apiLog.Response_Headers__c = JSON.serializePretty(responseHeaders);

            apiLog.Class_Name__c = className;        //put the name of the main Rest Resource Class.

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
            backupLog.Tag__c = 'HTTP CALLOUT LOG ERROR BACKUP';
            try {
                backupLog.Errors__c = 'line ' + e.getLineNumber() + ': ' + e.getMessage() + '\n' + e.getStackTraceString();
                backupLog.Request_Body__c = JSON.serialize(apiLog).left(APILogUtility.MAX_LEN_REQUEST_BODY);
            } catch ( Exception e2 ) {
                System.debug(LoggingLevel.ERROR, e2.getMessage() + '\n' + e2.getStackTraceString());
            }
            insert backupLog;
        }
    }

    private void addDebugInfo(String str) {
        debugInfo.add(str);
    }

    private void addDebugInfo(List<String> strs) {
        debugInfo.addAll(strs);
    }

    private void logException(Exception ex) {
        System.debug(LoggingLevel.ERROR, 'logException:\n' + ex.getMessage() + '\n' + ex.getStackTraceString());
        errors.add(ex);
    }    
    
    //to throw callout exceptions
    public class HttpCalloutException extends Exception {}



}
