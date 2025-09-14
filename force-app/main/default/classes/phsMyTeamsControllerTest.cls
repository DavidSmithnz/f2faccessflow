@isTest
public class phsMyTeamsControllerTest {
       
    private static Contact createContact() {
        Contact c = new Contact(
            LastName = 'Test Contact',
            Email = 'test' + System.currentTimeMillis() + '@example.com',
            Title='Test'
        );
        insert c;
        return c;
    }
    
    @IsTest static void testgetMyTeamList() 
    {
        Contact c=phsMyTeamsControllerTest.createContact();
        Contact c2=phsMyTeamsControllerTest.createContact();
        c2.ReportsToId=c.Id;
        update c2;
        phsUGPerformance__c obj=new phsUGPerformance__c(ChallengesFaced__c='Time',FocusQuality__c=1.0,Name='Test',StressLevel__c=1.0,
                                                        SuccessStories__c='Story',TimeInFlowState__c=1.0,UserId__c=c.Id);
        insert obj;    
        Test.startTest();
        String results=  phsMyTeamsController.getMyTeamList();
        Test.stopTest();
        System.assert(results.contains('Test'));
        System.debug('Test : '+ results);
        
    }
}