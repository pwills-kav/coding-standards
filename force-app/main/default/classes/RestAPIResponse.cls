public class RestAPIResponse {
    
    public transient Integer statusCode     {public get; private set;}      // hide this from the JSON response
    public Boolean success                  {public get; private set;}
    public Object response                  {public get; private set;}
    public List<ErrorResponse> errors       {public get; private set;}

    public RestAPIResponse() {
        success = true;
        statusCode = 200;
    }

    public RestAPIResponse(Object response) {
        this();
        setResponse(response);
    }

    public RestAPIResponse(Integer errorCode, String errorType, String errorMessage) {
        this();
        this.statusCode = errorCode;
        addError(errorCode, errorType, errorMessage);
    }

    public void setResponse(Object response) {
        this.response = response;
    }

    public void addError(Integer errorCode, String errorType, String errorMessage) {
        success = false;
        if ( errors == null ) {
            errors = new List<ErrorResponse>();
        }
        errors.add(new ErrorResponse(errorCode, errorType, errorMessage));
    }

    public void setStatusCode(Integer errorCode){
        statusCode = errorCode;
    }

    public class ErrorResponse {
        public String type;
        public String message;
        public Integer code;
        public ErrorResponse(Integer code, String type, String message) {
            this.code = code;
            this.type = type;
            this.message = message;
        }
    }

}