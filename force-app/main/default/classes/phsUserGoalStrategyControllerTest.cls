@isTest
public class phsUserGoalStrategyControllerTest {
    
    private static Contact createContact() {
        Contact c = new Contact(
            LastName = 'Test Contact',
            Email = 'test' + System.currentTimeMillis() + '@example.com'
        );
        insert c;
        return c;
    }
    
    
    private static phsUserGoals__c createUserGoal() {
        phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management',Name='Time Management');
        insert focusArea;
        phsGoals__c goal = new phsGoals__c(Name='Time Management',FocusAreaId__c=focusArea.Id,Name__c='Test Goal4',Role__c='Individual');
        insert goal;
        Contact c=phsUserGoalStrategyControllerTest.createContact();        
        phsUserGoals__c userGoal=new phsUserGoals__c(Active__c=true,FocusArea__c='Time Management',GoalAdherence__c=3.0,
                                                     GoalEffectiveness__c=3.0,GoalName__c='Time Management',GoalStrategyStatus__c='In Process',GoalType__c='Individual'
                                                     ,Name=goal.Id,UserId__c=c.Id,StandardGoalId__c=goal.Id );        
        return userGoal;
    }
    
    @IsTest static void testaddUserGoalStrategy() 
    {
        phsUserGoals__c userGoal=phsUserGoalStrategyControllerTest.createUserGoal();
        Test.startTest();
        phsUserGoalStrategyController.addUserGoalStrategy(userGoal.Id,  'Put Timer on every work to complete on time3','Standard');
        Test.stopTest();
        List<phsUserGoalsStrategies__c> strategies = [SELECT Name FROM phsUserGoalsStrategies__c where GoalId__c =  :userGoal.Id];
        System.assertEquals(1, strategies.size());
        
    }
    @IsTest static void testaddUserGoalStrategy_Negative() 
    {
        phsUserGoals__c userGoal=phsUserGoalStrategyControllerTest.createUserGoal();
        Test.startTest();
        phsUserGoalStrategyController.addUserGoalStrategy(userGoal.Id,  'Put Timer on every work to complete on time2','Wrong Data');
        Test.stopTest();
        List<phsUserGoalsStrategies__c> goals = [SELECT Name FROM phsUserGoalsStrategies__c where GoalId__c =  :userGoal.Id];
        System.assertEquals(0, goals.size());
        
    }
    
    @IsTest static void testgetUserGoalStrategies() 
    {
        phsUserGoals__c userGoal=phsUserGoalStrategyControllerTest.createUserGoal();        
        phsUserGoalsStrategies__c strategy=new phsUserGoalsStrategies__c(GoalId__c=userGoal.Id,Strategy__c='Put Timer on every work to complete on time1',StrategyType__c='Standard');
        insert strategy;        
        Test.startTest();
        String results= phsUserGoalStrategyController.getUserGoalStrategies(userGoal.Id);
        Test.stopTest();
        System.assert(results.contains('Put Timer on every work to complete on time'));
        
    }
    
    
}