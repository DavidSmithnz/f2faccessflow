@isTest
public class phsProfileControllerTest {
    
    private static Contact createContact() {
        Survey__c s=new Survey__c();
        insert s;
        Contact c = new Contact(
            LastName = 'Test Contact',
            Email = 'test' + System.currentTimeMillis() + '@example.com',
            Most_Recent_Survey__c=s.Id,
            Department='HR', Fax='2222',MailingPostalCode='2222', Date_of_Birth__c=Date.today(), 
            App_Role__c='Team Manager' , Title='Manager', Phone='1111', MobilePhone ='22222'
        );
        insert c;
        return c;
    }
     
    @isTest
    public static void testgetUserProfile() 
    {         
        Contact c=phsProfileControllerTest.createContact();
        Test.startTest();
        String result=phsProfileController.getUserProfile();
        Test.stopTest();
        System.assert(result.contains('Manager'));
        System.debug(result);
    }    
}