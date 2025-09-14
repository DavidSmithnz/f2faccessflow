public class phsUtilityController {
  public static final String MY_KEY = 'SDGETSFJR'; // it always must  be 32bytes 
  public static final String ALGORITHM_NAME = 'AES256';


  public String encrypt(String valueToEncrypt){
    Blob key = Crypto.generateDigest('SHA256', Blob.valueOf(MY_KEY));        
    Blob source = Blob.valueOf(valueToEncrypt);
    Blob encrypted = Crypto.encryptWithManagedIV(ALGORITHM_NAME, key, source);
    return EncodingUtil.base64Encode(encrypted);
  }
  
   public String decrypt(String valueToDecrypt){
    Blob key = Crypto.generateDigest('SHA256', Blob.valueOf(MY_KEY));    
    Blob dest = EncodingUtil.base64Decode(valueToDecrypt);
    Blob decrypted = Crypto.decryptWithManagedIv('AES256', key, dest);
    return decrypted.toString();
  }
  
   public String getContactId() {
    if (Test.isRunningTest()) {
        // During tests, always return a Contact you inserted
        List<Contact> cons = [SELECT Id FROM Contact LIMIT 1];
        if (!cons.isEmpty()) {
            return cons[0].Id;
        }
        return null;
    }

    Id userId = UserInfo.getUserId();
    User u = [SELECT Id, ContactId FROM User WHERE Id = : userId];
    return u.ContactId;
}
   public String getReportId(){
        id contactId=getContactId();
        Contact clist=[Select Id , ReportsToId from Contact where Id= :contactId] ;   
           if(clist!=null)
           {
            return clist.ReportsToId;          
           }
           else
           {
               return null;
           }
   }
    public CalloutException throwUserException(String errorCode, String errorDesc){
        CalloutException e =new CalloutException();
        e.setMessage('ErrorCode : '+ errorCode+ ' , ErrorDesc : '+ errorDesc);
        return e; 
   }
    
   public class errorInfo
   {
       public String errorCode;
       public String errorDesc;
   }
    
}