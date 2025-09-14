@isTest
public class phsGoalControllerTest {
    
    @IsTest static void testgetGoalList() 
    {
        phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management',Name='Time Management');
        insert focusArea;
        phsGoals__c goal=new phsGoals__c(Name__c='Test Goal',FocusAreaId__c=focusArea.Id,Name='Test Goal',Role__c='Individual');
        insert goal;
        Test.startTest();
        String results= phsGoalController.getGoalList('Individual');
        Test.stopTest();
        System.assert(results.contains('Test Goal'));
        
    }

}