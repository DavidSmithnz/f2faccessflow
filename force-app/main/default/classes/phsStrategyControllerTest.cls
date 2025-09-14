@isTest
public class phsStrategyControllerTest {
    
    
    private static Contact createContact() {
        Contact c = new Contact(
            LastName = 'Test Contact',
            Email = 'test' + System.currentTimeMillis() + '@example.com'
        );
        insert c;
        return c;
    }
    
    private static phsUserGoals__c createUserGoalWithStrategy() {
        phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management',Name='Time Management');
        insert focusArea;
        phsGoals__c goal = new phsGoals__c(Name='Time Management',FocusAreaId__c=focusArea.Id,Name__c='Test Goal4',Role__c='Individual');
        insert goal;
        Contact c=phsStrategyControllerTest.createContact();        
        phsUserGoals__c userGoal=new phsUserGoals__c(Active__c=true,FocusArea__c='Time Management',GoalAdherence__c=3.0,
                                                     GoalEffectiveness__c=3.0,GoalName__c='Time Management',GoalStrategyStatus__c='In Progress',GoalType__c='Individual'
                                                     ,Name=goal.Id,UserId__c=c.Id,StandardGoalId__c=goal.Id );
        insert userGoal;        
        phsUserGoalsStrategies__c strategy=new phsUserGoalsStrategies__c(GoalId__c=userGoal.Id,Name='My Unique Strategy',Strategy__c='My Unique Strategy',
                                                                         StrategyDescription__c='My Unique Strategy',StrategyType__c='Standard');
        insert strategy;
        return userGoal;       
    }
    
    
    private static phsGoals__c createGoalWithStrategy() 
    {
        phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management',Name='Time Management');
        insert focusArea;
        phsGoals__c goal = new phsGoals__c(Name='Time Management',FocusAreaId__c=focusArea.Id,Name__c='Test Goal4',Role__c='Individual');
        insert goal;
        Contact c=phsStrategyControllerTest.createContact();
        phsStrategies__c strategy=new phsStrategies__c(phsGoals__c=goal.Id,Name__c='My Unique Strategy',Name='My Unique Strategy',
                                                       StrategyDescription__c='My Unique Strategy');
        insert strategy;
        return goal;        
    }
    
    
    @IsTest static void testgetStrategiesList() 
    {
        phsGoals__c goal=phsStrategyControllerTest.createGoalWithStrategy();
        Test.startTest();
        String results=   phsStrategyController.getStrategiesList(goal.Id);
        Test.stopTest();
        List<phsStrategies__c> strategies = [SELECT Id FROM phsStrategies__c where phsGoals__c = :goal.Id];
        System.assertEquals(1, strategies.size());  
    }
    
    private static phsUserGoals__c createUserGoalWithoutStrategy()
    {
        phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management1',Name='Time Management1');
        insert focusArea;
        phsGoals__c goal = new phsGoals__c(Name='Time Management1',FocusAreaId__c=focusArea.Id,Name__c='Test Goal41',Role__c='Individual');
        insert goal;
        Contact c=phsStrategyControllerTest.createContact();
        
        phsUserGoals__c userGoal=new phsUserGoals__c(Active__c=true,FocusArea__c='Time Management1',GoalAdherence__c=3.0,
                                                     GoalEffectiveness__c=3.0,GoalName__c='Time Management1',GoalStrategyStatus__c='In Progress',GoalType__c='Individual'
                                                     ,Name=goal.Id,UserId__c=c.Id,StandardGoalId__c=goal.Id );
        insert userGoal;
        return userGoal;
    }
    @IsTest static void testaddStrategies() 
    {
        
        phsUserGoals__c userGoal= createUserGoalWithoutStrategy();
        String data ='[{"strategyName":"Test Strategy","goalId":"'+userGoal.Id+'","description":"Test Strategy"}]';
        
        Test.startTest();
        String results=   phsStrategyController.addStrategies(data);
        Test.stopTest();
        List<phsUserGoalsStrategies__c> strategies = [SELECT Id FROM phsUserGoalsStrategies__c where GoalId__c = :userGoal.Id];
        System.assert( strategies.size()>0);
        System.assert(results.contains('true'));
        
    }
    
    @IsTest static void testaddStrategy() 
    {
        phsUserGoals__c userGoal= createUserGoalWithoutStrategy();
        
        Test.startTest();
        String results=   phsStrategyController.addStrategy('Test Strategy1',userGoal.Id,'Test Strategy1');
        Test.stopTest();
        List<phsUserGoalsStrategies__c> strategies = [SELECT Id FROM phsUserGoalsStrategies__c where GoalId__c = :userGoal.Id];
        System.assert( strategies.size()>0);
        
        
    }
    
    
    @IsTest static void testaddStrategy_negative() 
    {
        phsUserGoals__c userGoal= createUserGoalWithoutStrategy();
        String results=   phsStrategyController.addStrategy('Test Strategy1',userGoal.Id,'Test Strategy1');        
        Test.startTest();
        results=phsStrategyController.addStrategy('Test Strategy1',userGoal.Id,'Test Strategy1');
        Test.stopTest();
        List<phsUserGoalsStrategies__c> strategies = [SELECT Id FROM phsUserGoalsStrategies__c where GoalId__c = :userGoal.Id];
        System.assert( strategies.size()==1);
        // System.assert( results.contains('Exists'));                
    }
    
    @IsTest static void testdeleteStrategy() 
    {
        phsUserGoals__c userGoal= createUserGoalWithoutStrategy();
        phsUserGoalsStrategies__c strategy=new phsUserGoalsStrategies__c(GoalId__c=userGoal.Id,Name='My Unique Strategy',Strategy__c='My Unique Strategy',
                                                                         StrategyDescription__c='My Unique Strategy',StrategyType__c='Standard');
        insert strategy;
        Test.startTest();
        
        String  results=phsStrategyController.deleteStrategy(strategy.Id);
        Test.stopTest();
        List<phsUserGoalsStrategies__c> strategies = [SELECT Id FROM phsUserGoalsStrategies__c];
        System.assertEquals(0, strategies.size());
        
        
    }
    
    @IsTest static void testgetUserGoalStrategiesList() 
    {
        phsUserGoals__c userGoal= createUserGoalWithoutStrategy();
        phsUserGoalsStrategies__c strategy=new phsUserGoalsStrategies__c(GoalId__c=userGoal.Id,Name='My Unique Strategy',Strategy__c='My Unique Strategy',
                                                                         StrategyDescription__c='My Unique Strategy',StrategyType__c='Standard');
        insert strategy;
        Test.startTest();
        
        String  results=phsStrategyController.getUserGoalStrategiesList(userGoal.Id);
        Test.stopTest();
        List<phsUserGoalsStrategies__c> strategies = [SELECT Id FROM phsUserGoalsStrategies__c where GoalId__c =: userGoal.Id];
        System.assert(strategies.size()>0);
        
        
    }
    
    @IsTest static void testgetSharedGoalStrategiesList() 
    {
        phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management2',Name='Time Management2');
        insert focusArea;
        Contact c=phsStrategyControllerTest.createContact();
        phsSharedGoals__c goal = new phsSharedGoals__c(GoalName__c='Time Management2', GoalType__c='Standard', FocusAreaName__c=focusArea.Id,
                                                       Name='Test Goal42',Status__c='Active',UserId__c=c.Id);
        insert goal;
        
        phsSharedGoalsStrategies__c strategy=new phsSharedGoalsStrategies__c(phsSharedGoals__c=goal.Id,Name='My Unique Strategy',StrategyDescription__c='My Unique Strategy',
                                                                             StrategyName__c='My Unique Strategy');
        insert strategy;
        Test.startTest();
        
        String  results=phsStrategyController.getSharedGoalStrategiesList(goal.Id);
        Test.stopTest();
        List<phsSharedGoalsStrategies__c> strategies = [SELECT Id FROM phsSharedGoalsStrategies__c where phsSharedGoals__c =: goal.Id];
        System.assert(strategies.size()>0);        
        
    }
    
}