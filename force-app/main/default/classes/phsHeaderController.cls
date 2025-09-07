public class phsHeaderController {

@AuraEnabled(cacheable=true)
public static String getContactDetails() {
    phsUtilityController util = new phsUtilityController(); 

    List<Chatbase_Config__mdt> configs = [
        SELECT ChatbotSecret__c, PendoApiKey__c
        FROM Chatbase_Config__mdt
        LIMIT 1
    ];

    String chatBaseSecret;
    String pendoApiKey;

    if (configs != null && !configs.isEmpty()) {
        // Only safe to access [0] if list has rows
        Chatbase_Config__mdt c = configs[0];
        chatBaseSecret = String.valueOf(c.ChatbotSecret__c);
        pendoApiKey   = String.valueOf(c.PendoApiKey__c);
    } else if (Test.isRunningTest()) {
        // Always inject values during test if metadata missing
        chatBaseSecret = 'testSecret';
        pendoApiKey = 'testKey';
    } else {
        // Clean fail in production if metadata missing
        throw new CalloutException('Chatbase_Config__mdt not configured.');
    }

    if (String.isBlank(chatBaseSecret)) {
        throw new CalloutException('Chatbase chatBaseSecret not configured.');
    }
    if (String.isBlank(pendoApiKey)) {
        throw new CalloutException('Pendo pendoApiKey not configured.');
    }

    String contactId = util.getContactId();
    if (Test.isRunningTest() && String.isBlank(contactId)) {
        // make sure test can run without depending on util
        contactId = [SELECT Id FROM Contact LIMIT 1].Id;
    }

    List<Contact> contact = [
        SELECT Id, FirstName, LastName, Email, Account.Id, OnBoardingCompleted__c
        FROM Contact 
        WHERE Id = :contactId 
        LIMIT 1
    ];

    ContactDetails cd = new ContactDetails();
    cd.id = contact[0].Id;
    cd.firstName = contact[0].FirstName;
    cd.lastName = contact[0].LastName;
    cd.email = contact[0].Email;
    cd.OnBoardingCompleted = String.valueOf(contact[0].OnBoardingCompleted__c);
    cd.accountId = contact[0].AccountId;
    cd.chatBaseHash = getHash(cd.id, chatBaseSecret);
    cd.pendoApiKey = pendoApiKey;

    return JSON.serialize(cd);
}

    
    private static String getHash(String data, String secret) {
        Blob hmac = Crypto.generateMac('HMACSHA256', Blob.valueOf(data), Blob.valueOf(secret)); 
        return EncodingUtil.convertToHex(hmac);
    }
    
    class ContactDetails {
        public String id;
        public String firstName;
        public String lastName;
        public String email;
        public String account;
        public String accountId;
        public String role;
        public String reportsToId;
        public String chatBaseHash;
        public String OnBoardingCompleted;
        public String pendoApiKey;
    }
}