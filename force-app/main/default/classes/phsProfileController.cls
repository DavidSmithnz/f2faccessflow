public without sharing class phsProfileController {
    
    @AuraEnabled(cacheable=true) 
    public static string getUserProfile() {
        
        String userId=new phsUtilityController().getContactId();
        List<Contact> clist=new List< Contact>();
        UserProfile uobj=new UserProfile();
        try
        {
            clist=[Select Id ,Name , Department, Fax,MailingPostalCode, Date_of_Birth__c, App_Role__c , Title, Email, Phone, MobilePhone , ReportsTo.Name, Account.Name from Contact where Id=:userId ];  
            for(Contact c : clist)
            {                
                uobj.Id=c.Id;
                uobj.Name=c.Name;
                
                uobj.Title=c.Title;
                uobj.Email=c.Email;
                uobj.Phone=c.Phone;
                uobj.Mobile=c.MobilePhone;
                uobj.Department=c.Department;
                uobj.Fax=c.Fax;
                if(c.Date_of_Birth__c!=null)
                {
                    DateTime dt=c.Date_of_Birth__c;
                    uobj.DateOfBirth=dt.format('MM/dd/yyyy');
                }
                uobj.AppRole=c.App_Role__c;
                uobj.PostalCode=c.MailingPostalCode;
                uobj.ReportsTo=c.ReportsTo.Name;
                uobj.AccountName=c.Account.Name;
                
            } 
            String jsonResponse = JSON.serialize(uobj);
            return jsonResponse;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
            String jsonResponse = JSON.serialize('Error : '+e.getMessage());
            return jsonResponse;
        }      
    }
    class UserProfile
    {
        public String Id;
        public String Name;
        public String AccountName;
        public String Title;
        public String PostalCode;
        public String Email;
        public String Phone;
        public String Mobile;
        public String ReportsTo;
        public String Department;
        public String Fax;
        public String DateOfBirth;
        public String AppRole;                
    }   
}