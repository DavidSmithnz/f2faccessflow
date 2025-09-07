public without sharing class phsStrategyController {
    
   
 @AuraEnabled(cacheable=true) 
    public static String getStrategiesList(String goalId) {
        
      
        List<phsStrategies__c> phsStrategieslist = new List<phsStrategies__c>(); 
        List<Strategy> strategieslist = new List<Strategy>(); 
        try
        {
        phsStrategieslist = [SELECT Id , Name__c ,phsGoals__c , StrategyDescription__c
                            FROM phsStrategies__c where phsGoals__c =: goalId ];
             for (phsStrategies__c s: phsStrategieslist) {
        Strategy obj=new Strategy();
            obj.strategyId=s.Id;
            obj.strategyName=s.Name__c;
            obj.goalId=s.phsGoals__c;
             obj.description    =s.StrategyDescription__c;
                 
            strategieslist.add(obj);
             } 
		}
              catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
        }
          String jsonResponse = JSON.serialize(strategieslist);
        return jsonResponse;
            
    }
    class Strategy
{
    public String strategyId;
    public String strategyName;
    public String goalId;
    public integer rowNo=0;
    public string description;
    public boolean isShow=false;
    public boolean isSelected=false;
}
    
    @AuraEnabled() 
    public static String addStrategies(String data) {
        try
        {
        List<Strategy> strategyList = (List<Strategy>)JSON.deserialize(data, List<Strategy>.class);
            //(List<Strategy>)JSON.deserialize(data,Strategy.class);
            
        for(Strategy s : strategyList)
        {
            phsUserGoalsStrategies__c c=new phsUserGoalsStrategies__c();
            c.Strategy__c=s.strategyName;
            c.GoalId__c=s.goalId;
            c.StrategyDescription__c=s.description;
            insert c;
        }
        String jsonResponse = JSON.serialize(true);
        return jsonResponse;
        }
        catch(Exception e)
        {
             System.debug('The following exception has occurred: ' + e.getMessage()); 
            String jsonResponse = JSON.serialize(e.getMessage());
        return jsonResponse;
        }
    }
    
    
        @AuraEnabled() 
    public static String addStrategy(String strategyName,String goalId,String description) {
        try
        {
       
            List<phsUserGoals__c> userGoal=new List<phsUserGoals__c>();
            
            userGoal=[Select Id, GoalName__c,UserId__c from phsUserGoals__c where Id=:goalId];
            
            String goalName=userGoal[0].GoalName__c;
            String userId=userGoal[0].UserId__c;
            
            List<phsUserGoalsStrategies__c> goalStrategyCheck=new List<phsUserGoalsStrategies__c>();
            goalStrategyCheck= [Select Id , Strategy__c , GoalId__r.UserId__c , GoalId__r.GoalName__c ,GoalId__r.Id,GoalId__r.GoalStrategyStatus__c  from phsUserGoalsStrategies__c 
                                      where GoalId__r.UserId__c =: userId and Strategy__c=: strategyName and GoalId__r.GoalName__c =: goalName];
            
            if(goalStrategyCheck.size()==0)
            {
            phsUserGoalsStrategies__c c=new phsUserGoalsStrategies__c();
            c.Strategy__c=strategyName;
            c.GoalId__c=goalId;
            c.StrategyDescription__c=description;
            insert c;
        
                addStrategyStatus objres=new addStrategyStatus();
                objres.status='true';
        String jsonResponse = JSON.serialize(objres);
        return jsonResponse;
            }
            else
            {
                 addStrategyStatus objres=new addStrategyStatus();
                objres.status='exists';
                objres.goalStatus=goalStrategyCheck[0].GoalId__r.GoalStrategyStatus__c;
                
         String jsonResponse = JSON.serialize(objres);
        return jsonResponse; 
            }
        }
        catch(Exception e)
        {
             System.debug('The following exception has occurred: ' + e.getMessage()); 
             addStrategyStatus objres=new addStrategyStatus();
                objres.status='false';
                objres.errorDetails= e.getMessage();
            String jsonResponse = JSON.serialize(objres);
        return jsonResponse;
        }
    }
    
    class addStrategyStatus
    {
        string status;
        string goalStatus;
        string errorDetails;
    }
    
    @AuraEnabled() 
    public static String deleteStrategy(String userGoalId) {
        try
        {
             List<phsUserGoalsStrategies__c> phsStrategieslist = new List<phsUserGoalsStrategies__c>(); 
        phsStrategieslist = [SELECT Id 
                            FROM phsUserGoalsStrategies__c where Id =: userGoalId ];
            delete phsStrategieslist;

        String jsonResponse = JSON.serialize(true);
        return jsonResponse;
        }
        catch(Exception e)
        {
             System.debug('The following exception has occurred: ' + e.getMessage()); 
            String jsonResponse = JSON.serialize(e.getMessage());
        return jsonResponse;
        }
       
    }
    
    
    
     @AuraEnabled() 
     public static String getUserGoalStrategiesList(String userGoalId) {
        
      
        List<phsUserGoalsStrategies__c> phsStrategieslist = new List<phsUserGoalsStrategies__c>(); 
        List<Strategy> strategieslist = new List<Strategy>(); 
        try
        {
            integer counter=0;
        phsStrategieslist = [SELECT Id , Strategy__c, StrategyType__c ,GoalId__c ,StrategyDescription__c
                            FROM phsUserGoalsStrategies__c where GoalId__c =: userGoalId ];
             for (phsUserGoalsStrategies__c s: phsStrategieslist) {
        Strategy obj=new Strategy();
            obj.strategyId=s.Id;
            obj.strategyName=s.Strategy__c;
            obj.goalId=s.GoalId__c;
                 counter++;
                 obj.rowNo=counter;
                 obj.description=s.StrategyDescription__c;
                 obj.isShow=false;
                 
            strategieslist.add(obj);
             } 
		}
              catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
        }
          String jsonResponse = JSON.serialize(strategieslist);
        return jsonResponse;
            
    }
    
    
          @AuraEnabled(cacheable=true) 
    public static String getSharedGoalStrategiesList(String goalId) {
        
      
        List<phsSharedGoalsStrategies__c> phsStrategieslist = new List<phsSharedGoalsStrategies__c>(); 
        List<Strategy> strategieslist = new List<Strategy>(); 
        try
        {
        phsStrategieslist = [SELECT Id , StrategyName__c ,phsSharedGoals__c , StrategyDescription__c
                            FROM phsSharedGoalsStrategies__c where phsSharedGoals__c =: goalId ];
             for (phsSharedGoalsStrategies__c s: phsStrategieslist) {
        Strategy obj=new Strategy();
            obj.strategyId=s.Id;
            obj.strategyName=s.StrategyName__c;
            obj.goalId=s.phsSharedGoals__c;
             obj.description    =s.StrategyDescription__c;
                 
            strategieslist.add(obj);
             } 
		}
              catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
        }
          String jsonResponse = JSON.serialize(strategieslist);
        return jsonResponse;
            
    }
}