public without sharing class RestAPICreateContactHandler extends RestAPIHandler {
    public RestAPICreateContactHandler() {
        super();
        operation = 'RestAPICreateContactHandler';
    }

    // override GET
    private void processGET() {
        
    }

    // override POST
    private void processPOST() {
        if ( String.isBlank(requestBody) ) {
            throw new InvalidInputException('No request body specified.');
        }

        //populate request class
        InboundContactRequest inboundContact;
        //putting a try catch around deserializing to catch errors such as sending a string in place of a boolean
        //and to throw a valid request instead of a 500 Internal Server error.
        try {
            inboundContact = (InboundContactRequest)JSON.deserialize(requestBody, InboundContactRequest.class);
        } catch ( Exception e ) {
            throw new InvalidInputException('Unable to parse request - please confirm your request format is valid.');
        }

        //validateFieldValues(inboundContact);

        //check if contact exists for given email, then throw error.
        Contact[] existingContacts = [SELECT ID FROM Contact WHERE Email =: inboundContact.email];

        if ( !existingContacts.isEmpty() ) {
            throw new ValidationException('Duplicate record found');
        }

        //create Account and Contact.
        currentContact = new Contact();
        currentAccount = new Account();

        currentAccount.Name = inboundContact.firstName + inboundContact.LastName;
        insert currentAccount;

        currentContact.FirstName = inboundContact.firstName;
        currentContact.LastName = inboundContact.lastName;
        currentContact.Email = inboundContact.email;
        currentContact.Phone = inboundContact.phone;
        currentContact.AccountId = currentAccount.Id;
        insert currentContact;

        generateResponse(currentContact);
        
    }

    private void generateResponse(Contact con) {
        response = new RestAPIResponse(new ContactResponse(con));
    }

    public class InboundContactRequest {
        public String firstName;
        public String lastName;
        public String email;
        public String phone;

    }

    public class ContactResponse {
        public String contactId;
        public String accountId;

        public ContactResponse(Contact con) {
            contactId = con.Id;
            accountId = con.AccountId;
        }
    }
}
