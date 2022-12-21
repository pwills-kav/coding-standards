@IsTest
public class APILogUtilityTest {
    
    @IsTest
    static void methodName(){
        String default_delim = APILogUtility.DEFAULT_DELIM;
        Integer max_len_request_body = APILogUtility.MAX_LEN_REQUEST_BODY;
        Integer max_len_response_body = APILogUtility.MAX_LEN_RESPONSE_BODY;
        Integer max_len_error = APILogUtility.MAX_LEN_ERROR;
        Integer max_len_debug = APILogUtility.MAX_LEN_DEBUG;
        Integer max_len_notif_body = APILogUtility.MAX_LEN_NOTIF_BODY;
        Map<String, Integer> field_max_len = APILogUtility.FIELD_MAX_LEN;
        API_Log__c log = APILogUtility.createNewLog();
        APILogUtility.getNotifyEmailList();
        APILogUtility.fetchTransactionLimits('test');
        APILogUtility.populateApiLogRequest(log, 'endpoint', 'method', 0, null, null, null);
        //TODO - fix assertions
    }
}