@isTest
public class phsUserGoalsControllerTest {
    
    private static Contact createContact() {
        Survey__c s = new Survey__c(); 
        insert s;
        
        Contact c = new Contact(
            LastName = 'Test Contact',
            Email = 'test' + System.currentTimeMillis() + '@example.com',
            Most_Recent_Survey__c = s.Id
        );
        insert c;
        return c;
    }
    private static phsUserGoals__c createUserGoal() {
        phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management',Name='Time Management');
        insert focusArea;
        phsGoals__c goal = new phsGoals__c(Name='Time Management',FocusAreaId__c=focusArea.Id,Name__c='Test Goal4',Role__c='Individual');
        insert goal;
        Contact c=phsUserGoalsControllerTest.createContact();
        Contact c1=phsUserGoalsControllerTest.createContact();   
        phsUserGoals__c userGoal=new phsUserGoals__c(Active__c=true,FocusArea__c='Time Management',GoalAdherence__c=3.0,
                                                     GoalEffectiveness__c=3.0,GoalName__c='Time Management',GoalStrategyStatus__c='In Progress',GoalType__c='Individual'
                                                     ,Name=goal.Id,UserId__c=c.Id,StandardGoalId__c=goal.Id,LastCheckInDate__c=Date.today(),
                                                     SharedBy__c=c1.Id,ManagerFeedback__c='Good' );
        insert userGoal;
        phsUserGoalsStrategies__c strategy=new phsUserGoalsStrategies__c(GoalId__c=userGoal.Id,Strategy__c='Put Timer on every work to complete on time1',
                                                                         StrategyType__c='Standard');
        insert strategy;
        return userGoal;
    }
    
    @IsTest static void testgetUserGoalList() 
    {
        phsUserGoals__c userGoal=phsUserGoalsControllerTest.createUserGoal();
        Test.startTest();
        String results=phsUserGoalsController.getUserGoalList();
        Test.stopTest();
        List<phsUserGoals__c> goals = [SELECT Id FROM phsUserGoals__c ];
        System.assertEquals(1, goals.size());    
    }
    
    @IsTest static void testgetMyUserGoalList() 
    {
        
        phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management',Name='Time Management');
        insert focusArea;
        phsGoals__c goal = new phsGoals__c(Name='Time Management',FocusAreaId__c=focusArea.Id,Name__c='Test Goal4',Role__c='Individual');
        insert goal;
        Contact c=phsUserGoalsControllerTest.createContact();
        Contact c1=phsUserGoalsControllerTest.createContact();
        phsUserGoals__c userGoal=new phsUserGoals__c(Active__c=true,FocusArea__c='Time Management',GoalAdherence__c=3.0,
                                                     GoalEffectiveness__c=3.0,GoalName__c='Time Management',GoalStrategyStatus__c='In Progress',GoalType__c='Individual'
                                                     ,Name=goal.Id,UserId__c=c.Id,StandardGoalId__c=goal.Id,LastCheckInDate__c=Date.today(),
                                                     SharedBy__c=c1.Id,ManagerFeedback__c='Good' );
        insert userGoal;
        
        Test.startTest();
        String results=phsUserGoalsController.getMyUserGoalList(c.Id);
        Test.stopTest();
        List<phsUserGoals__c> goals = [SELECT Id FROM phsUserGoals__c ];
        System.assertEquals(1, goals.size());
        System.debug('Test : '+results);
        
    }
    
    @IsTest static void testupdateManagerFeedback() 
    {
        phsUserGoals__c userGoal=phsUserGoalsControllerTest.createUserGoal();        
        Test.startTest();
        String results=phsUserGoalsController.updateManagerFeedback(userGoal.Id,'New Feedback');
        Test.stopTest();
        List<phsUserGoals__c> goals = [SELECT Id, ManagerFeedback__c FROM phsUserGoals__c ];
        System.assertEquals('New Feedback', goals[0].ManagerFeedback__c);        
    }
    
    @IsTest static void testgetUserGoalListUpdate() 
    {
        phsUserGoals__c userGoal= createUserGoal();
        
        Test.startTest();
        String results=phsUserGoalsController.getUserGoalListUpdate();
        Test.stopTest();
        List<phsUserGoals__c> goals = [SELECT Id FROM phsUserGoals__c ];
        System.assertEquals(1, goals.size());
        System.debug('Test : '+results);
        
    }
    
    @IsTest static void testaddUserGoal() 
    {        
        phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management',Name='Time Management');
        insert focusArea;
        phsGoals__c goal = new phsGoals__c(Name='Time Management',FocusAreaId__c=focusArea.Id,Name__c='Test Goal4',Role__c='Individual');
        insert goal;
        Contact c=phsUserGoalsControllerTest.createContact();
        Contact c1=phsUserGoalsControllerTest.createContact();
        
        Test.startTest();
        String results=phsUserGoalsController.addUserGoal('Time Management','Individual',  focusArea.Id,
                                                          null,goal.Id,null , null, 'true', 'Test Strategy');
        Test.stopTest();
        List<phsUserGoals__c> goalList=[Select Id from phsUserGoals__c];
        System.assertEquals(1, goalList.size());
        
    }
    
    
    @IsTest static void testaddUserGoalExists() 
    {
        
        phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management',Name='Time Management');
        insert focusArea;
        phsGoals__c goal = new phsGoals__c(Name='Time Management',FocusAreaId__c=focusArea.Id,Name__c='Test Goal4',Role__c='Individual');
        insert goal;
        Contact c=phsUserGoalsControllerTest.createContact();
        Contact c1=phsUserGoalsControllerTest.createContact();
        phsUserGoals__c userGoal=new phsUserGoals__c(Active__c=true,FocusArea__c='Time Management',GoalAdherence__c=3.0,
                                                     GoalEffectiveness__c=3.0,GoalName__c='Time Management',GoalStrategyStatus__c='In Progress',GoalType__c='Individual'
                                                     ,Name=goal.Id,UserId__c=c.Id,StandardGoalId__c=goal.Id,LastCheckInDate__c=Date.today(),
                                                     SharedBy__c=c1.Id,ManagerFeedback__c='Good' );
        insert userGoal;
        phsUserGoalsStrategies__c strategy=new phsUserGoalsStrategies__c(GoalId__c=userGoal.Id,Strategy__c='Test Strategy',StrategyType__c='Standard');
        insert strategy;
        
        Test.startTest();
        String results=phsUserGoalsController.addUserGoal('Time Management','Individual',  focusArea.Id,
                                                          null,goal.Id,null , null, 'true', 'Test Strategy');
        Test.stopTest();
        List<phsUserGoals__c> goalList=[Select Id from phsUserGoals__c];
        System.assertEquals(1, goalList.size());
        
    }
    
    @IsTest static void testupdateUserGoal() 
    {
        phsUserGoals__c userGoal= createUserGoal();
        double d=5.0;
        Test.startTest();
        String results=phsUserGoalsController.updateUserGoal(userGoal.Id,d,d,true, 'Established' );
        Test.stopTest();
        List<phsUserGoals__c> goalList=[Select Id,GoalStrategyStatus__c from phsUserGoals__c];
        System.assertEquals('Established', goalList[0].GoalStrategyStatus__c);        
    }
    
}