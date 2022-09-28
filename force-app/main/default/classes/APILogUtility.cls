public without sharing class APILogUtility {
    
    public static final String DEFAULT_DELIM = '\n';

    public static final Integer MAX_LEN_REQUEST_BODY    = SObjectType.API_Log__c.Fields.Request_Body__c.Length;
    public static final Integer MAX_LEN_RESPONSE_BODY   = SObjectType.API_Log__c.Fields.Response_Body__c.Length;
    public static final Integer MAX_LEN_ERROR           = SObjectType.API_Log__c.Fields.Errors__c.Length;
    public static final Integer MAX_LEN_DEBUG           = SObjectType.API_Log__c.Fields.Debug_Info__c.Length;
    public static final Integer MAX_LEN_NOTIF_BODY      = SObjectType.API_Log__c.Fields.Notification_Body__c.Length;

    public static final Map<String, Integer> FIELD_MAX_LEN = new Map<String, Integer>{
        'Request_Body__c'       =>  MAX_LEN_REQUEST_BODY,
        'Response_Body__c'      =>  MAX_LEN_RESPONSE_BODY,
        'Errors__c'             =>  MAX_LEN_ERROR,
        'Debug_Info__c'         =>  MAX_LEN_DEBUG
    };
    
    public API_Log__c apiLogRecord;

    public APILogUtility() {
        this(createNewLog());
    }

    public APILogUtility(API_Log__c apiLogRecord) {
        this.apiLogRecord = (apiLogRecord != null) ? apiLogRecord : createNewLog();
    }

    public APILogUtility(String tag) {
        this();
        apiLogRecord.Tag__c = tag;
    }

    public APILogUtility(String tag, String action) {
        this(tag);
        apiLogRecord.Action__c = action;
    }

    public APILogUtility(String tag, String action, String classname) {
        this(tag, action);
        apiLogRecord.Class_Name__c = classname;
    }

    public static API_Log__c createNewLog() {
        return new API_Log__c(
                Request_Start_Timestamp__c = String.valueOf(System.now().getTime()),
                Has_Errors__c = false,
                Send_Notification__c = false
            );
    }

    public APILogUtility addErrors(List<String> errs) {
        if ( errs != null ) {
            for ( String err : errs ) {
                addError(err);
            }
        }
        return this;
    }

    public APILogUtility addError(String err) {
        return addError(err, DEFAULT_DELIM);
    }

    public APILogUtility addError(String err, String delim) {

        if ( String.isBlank(delim) ) {
            delim = DEFAULT_DELIM;
        }
        
        if ( String.isBlank(apiLogRecord.Errors__c) ) {
            apiLogRecord.Errors__c = err + delim;
        } else{
            apiLogRecord.Errors__c += err + delim;
            apiLogRecord.Errors__c = apiLogRecord.Errors__c.left(MAX_LEN_ERROR);
        }
        
        apiLogRecord.Has_Errors__c = String.isNotBlank(apiLogRecord.Errors__c);
        return this;
    }   

    public APILogUtility addErrors(List<Exception> exceptions) {
        if ( exceptions != null ) {
            for ( Exception e : exceptions ) {
                addError(e);
            }
        }
        return this;
    }

    public APILogUtility addError(Exception e) {
        if ( e == null ) {
            return this;
        }
        return addError(e.getTypeName() + ': ' + e.getMessage() + '\n' + e.getStackTraceString());
    }

    public Boolean hasErrors() {
        return (this.apiLogRecord.Has_Errors__c == true);
    }

    public APILogUtility addDebugInfo(List<String> debugs) {
        if ( debugs != null ) {
            for ( String debug : debugs ) {
                addDebugInfo(debug);
            }
        }
        return this;
    }

    public APILogUtility addDebugInfo(String debug) {

        if ( String.isBlank(apiLogRecord.Debug_Info__c) ) {
            apiLogRecord.Debug_Info__c = debug + DEFAULT_DELIM;
        } else{
            apiLogRecord.Debug_Info__c += debug + DEFAULT_DELIM;
            apiLogRecord.Debug_Info__c = apiLogRecord.Debug_Info__c.left(MAX_LEN_DEBUG);
        }

        apiLogRecord.Has_Debug_Info__c = String.isNotBlank(apiLogRecord.Debug_Info__c);
        return this;
    }

    public static List<String> getNotifyEmailList(){
        List<String> emails = new List<String>();
        emails.add('piyush@sansotti.com');      //create a custom setting or use labels to get emails of people to notify.

        return emails;
    }


    public APILogUtility notifyErrorsDefault(String subject) {
        return notifyErrors(getNotifyEmailList(), subject);
    }

    public APILogUtility notifyErrors(List<String> toAddresses, String subject){
        return notify(toAddresses, subject, apiLogRecord.Errors__c);
    }

    public APILogUtility notifyDefault(String subject, String body) {
        return notify(getNotifyEmailList(), subject, body);
    }

    public APILogUtility notify(String toAddress, String subject, String body) {
        return notify(new String[]{toAddress}, subject, body);
    }

    public APILogUtility notifyToList(List<String> toAddresses, String subject, String body) {
        return notify(toAddresses, subject, body);
    }

    //This will only populate relevant fields on the API Log. To send the email alert, create 
    //required Email Template, Alert and Flow. 
    private APILogUtility notify(List<String> toAddresses, String subject, String body) {
        System.debug('log.notify: ' + subject);

        //apiLogRecord.Notification_Send_To__c   = populate from toAddress list;
        //apiLogRecord.Notification_Send_To_2__c = populate from toAddress list;
        //apiLogRecord.Notification_Send_To_3__c = populate from toAddress list;
        //apiLogRecord.Notification_Send_To_4__c = populate from toAddress list;

        apiLogRecord.Send_Notification__c = true;
        apiLogRecord.Notification_Subject__c = subject;
        apiLogRecord.Notification_Body__c = body;

        if ( apiLogRecord.Has_Errors__c && !apiLogRecord.Notification_Subject__c.contains('[INTERNAL_ERROR]') ) {     //or any other keyword, that is accepted as an unhandled exception, across the org.
            apiLogRecord.Notification_Subject__c += ' [INTERNAL_ERROR]';
        }
        return this;
    }

    public APILogUtility commitLog() {
        upsert apiLogRecord;
        return this;
    }

    public static List<String> fetchTransactionLimits(String header) {
        List<String> transLimits = new List<String>();
        if ( header != null ) {
            transLimits.add('----- DEBUG LIMITS for ' + header + ' -----');
        }
        transLimits.add('SOQL queries used   - '  + Limits.getQueries());
        transLimits.add('SOQL rows used      - '  + Limits.getQueryRows());
        transLimits.add('DML Operations used - '  + Limits.getDMLStatements());
        transLimits.add('DML Rows used       - '  + Limits.getDMLRows());
        transLimits.add('Callouts used       - '  + Limits.getCallouts());
        transLimits.add('Heap size used      - '  + Limits.getHeapSize());
        transLimits.add('CPU Time used       - '  + Limits.getCpuTime());
        return transLimits;
    }

}
