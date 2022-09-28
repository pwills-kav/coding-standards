@RestResource(urlMapping='/contact/create/*')
global without sharing class RestAPICreateContact {

    @HttpGet
    global static void doGET() {
        (new RestAPICreateContactHandler()).processRequest();
    }
    
    @HttpPost
    global static void doPOST() {
        (new RestAPICreateContactHandler()).processRequest();
    }

}

