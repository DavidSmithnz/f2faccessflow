@isTest
public class phsSharedGoalControllerTest {
  private static Contact createContact() {
        Contact c = new Contact(
            LastName = 'Test Contact',
            Email = 'test' + System.currentTimeMillis() + '@example.com'
        );
        insert c;
        return c;
    }
    //Noyt working
      @IsTest static void testgetSharedGoalList() 
          {
             phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management2',Name='Time Management2');
         insert focusArea;
                Contact c=phsSharedGoalControllerTest.createContact();
                Contact c2=phsSharedGoalControllerTest.createContact();
              
              c.ReportsToId=c2.Id;
         update c;
             
        phsSharedGoals__c goal = new phsSharedGoals__c(GoalName__c='Time Management2', GoalType__c='Standard', FocusAreaName__c=focusArea.Id,
                                                       Name='Test Goal42',Status__c='Active',UserId__c=c2.Id);
        insert goal;
        
    
         phsSharedGoalsStrategies__c strategy=new phsSharedGoalsStrategies__c(phsSharedGoals__c=goal.Id,Name='My Unique Strategy',StrategyDescription__c='My Unique Strategy',
                                                                          StrategyName__c='My Unique Strategy');
            insert strategy;
              Test.startTest();
           	 System.debug('Testxyz : '+ goal.Id); 
            String  results=phsSharedGoalController.getSharedGoalList();
              System.debug('Testxyz1 : '+ results); 
              Test.stopTest();
               List<phsSharedGoals__c> sharedGaols = [SELECT Id FROM phsSharedGoals__c ];
        	    System.assert(sharedGaols.size()>0);
              System.debug('Testxyz : '+ results); 
            
          }
    
        @IsTest static void testaddSharedGoal() 
          {
               Test.startTest();
           
            String  results=phsSharedGoalController.addSharedGoal('Test Shared Goal','Time Management');
               Test.stopTest();
               List<phsSharedGoals__c> sharedGoals = [SELECT Id FROM phsSharedGoals__c ];
        	    System.assert(sharedGoals.size()>0);
              //System.debug('Testxyz : '+ strategies.size()); 
              // System.assert( results.contains('Exists'));
          }
    
     @IsTest static void testaddSharedGoalStrategies_negative() 
          {
                phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management2',Name='Time Management2');
         insert focusArea;
                Contact c=phsSharedGoalControllerTest.createContact();
           
        phsSharedGoals__c goal = new phsSharedGoals__c(GoalName__c='Time Management2', GoalType__c='Standard', FocusAreaName__c=focusArea.Id,
                                                       Name='Test Goal42',Status__c='Active',UserId__c=c.Id);
        insert goal;
        
              String data='{"strategyName":"Test Strategy","goalId":"'+goal.Id+'","description":"Test Strategy"}';
               Test.startTest();
           
            String  results=phsSharedGoalController.addSharedGoalStrategies(data);
               Test.stopTest();
               List<phsSharedGoalsStrategies__c> sharedGoalStrategy = [SELECT Id FROM phsSharedGoalsStrategies__c ];
        	   // System.assert(sharedGoalStrategy.size()>0);
              System.debug('Testxyz : '+ results); 
               System.assert( results.contains('Malformed JSON: Expected'));
          }
    
    
      @IsTest static void testaddSharedGoalStrategies() 
          {
                phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management2',Name='Time Management2');
         insert focusArea;
                Contact c=phsSharedGoalControllerTest.createContact();
           
        phsSharedGoals__c goal = new phsSharedGoals__c(GoalName__c='Time Management2', GoalType__c='Standard', FocusAreaName__c=focusArea.Id,
                                                       Name='Test Goal42',Status__c='Active',UserId__c=c.Id);
        insert goal;
        
              String data='[{"strategyName":"Test Strategy","goalId":"'+goal.Id+'","description":"Test Strategy"}]';
               Test.startTest();
           
            String  results=phsSharedGoalController.addSharedGoalStrategies(data);
               Test.stopTest();
               List<phsSharedGoalsStrategies__c> sharedGoalStrategy = [SELECT Id FROM phsSharedGoalsStrategies__c ];
        	    System.assert(sharedGoalStrategy.size()>0);
              System.debug('Testxyz : '+ results); 
               //System.assert( results.contains('Malformed JSON: Expected'));
          }
    
    
    
    @IsTest static void testgetGoalStrategiesList() 
          {
              phsFocusArea__c focusArea=new phsFocusArea__c(Name__c='Time Management2',Name='Time Management2');
         insert focusArea;
        phsGoals__c goal = new phsGoals__c(Name='Time Management2',FocusAreaId__c=focusArea.Id,Name__c='Test Goal42',Role__c='Individual');
        insert goal;
          Contact c=phsSharedGoalControllerTest.createContact();
             
         phsUserGoals__c userGoal=new phsUserGoals__c(Active__c=true,FocusArea__c='Time Management2',GoalAdherence__c=3.0,
                                                      GoalEffectiveness__c=3.0,GoalName__c='Time Management2',GoalStrategyStatus__c='In Progress',GoalType__c='Individual'
                                                      ,Name=goal.Id,UserId__c=c.Id,StandardGoalId__c=goal.Id );
         insert userGoal;
         phsUserGoalsStrategies__c strategy=new phsUserGoalsStrategies__c(GoalId__c=userGoal.Id,Name='My Unique Strategy',Strategy__c='My Unique Strategy',
                                                                          StrategyDescription__c='My Unique Strategy',StrategyType__c='Standard');
            insert strategy;
              Test.startTest();
           	
            String  results=phsSharedGoalController.getGoalStrategiesList(userGoal.Id);
              Test.stopTest();
               List<phsUserGoalsStrategies__c> strategies = [SELECT Id FROM phsUserGoalsStrategies__c where GoalId__c =: userGoal.Id];
        	    System.assert(strategies.size()>0);
              System.debug('Testxyz : '+ results); 
              // System.assert( results.contains('Exists'));
              		
              
          }
    
    
    
    
}