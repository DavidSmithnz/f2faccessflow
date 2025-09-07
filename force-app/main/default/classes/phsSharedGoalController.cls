public without sharing class phsSharedGoalController {
  
   
@AuraEnabled() 
    public static string getSharedGoalList() {
        phsUtilityController utility=new phsUtilityController();
       	String userId=utility.getContactId();
      	String reportToId=  utility.getReportId();
        List<CommonGoal> commongoals=new List<CommonGoal>();
        List<phsSharedGoals__c> goals = new List<phsSharedGoals__c>(); 
        try
        {
        goals = [SELECT Id , GoalName__c , GoalType__c  ,Status__c,UserId__c,FocusAreaName__c ,CreatedBy.FirstName,CreatedBy.LastName  FROM phsSharedGoals__c where UserId__c =: reportToId];
            
            for(phsSharedGoals__c g : goals)
            {
                CommonGoal c=new CommonGoal();
                c.goalId=g.Id;
                c.goalName=g.GoalName__c;
                c.goalType=g.GoalType__c;
                c.status=g.Status__c;
                c.focusAreaName=g.FocusAreaName__c;
                c.SharedBy=g.CreatedBy.FirstName +' '+g.CreatedBy.LastName;
                commongoals.add(c);
            }
            
                String jsonResponse = JSON.serialize(commongoals);
        return jsonResponse;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
                 String jsonResponse = JSON.serialize(e.getMessage());
        return jsonResponse;
        }

    }
    
    class CommonGoal {
	public  String goalId ;
   	public  String goalName ; 
   	public  String goalType; 
    public  String focusAreaName ; 
    public  String status ; 
        public String SharedBy;
            
}

    
    
        @AuraEnabled() 
    	public static String addSharedGoal(String goalName,String focusArea) {
        try
        {
            phsUtilityController utility=new phsUtilityController();
       		String userId=new phsUtilityController().getContactId();
            phsSharedGoals__c obj=new phsSharedGoals__c();
            obj.GoalName__c=goalName;
           // obj.GoalType__c='Manager';
            obj.FocusAreaName__c=focusArea;
            obj.Status__c='Shared';
            obj.UserId__c=userId;
            insert obj;
            String jsonResponse = JSON.serialize(obj.Id);
        	return jsonResponse;
                                     
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
            String jsonResponse = JSON.serialize(e.getMessage());
        	return jsonResponse;
        }
        
    }
    
        class Strategy
{
    public String strategyId;
    public String strategyName;
    public String goalId;
    public integer rowNo=0;
    public string description;
    public boolean isShow=false;
}
      @AuraEnabled() 
    	public static String addSharedGoalStrategies(String data) {
         try
        {
        List<Strategy> strategyList = (List<Strategy>)JSON.deserialize(data, List<Strategy>.class);
            //(List<Strategy>)JSON.deserialize(data,Strategy.class);
            
        for(Strategy s : strategyList)
        {
            phsSharedGoalsStrategies__c c=new phsSharedGoalsStrategies__c();
            c.StrategyName__c=s.strategyName;
            c.phsSharedGoals__c=s.goalId;
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
     public static String getGoalStrategiesList(String userGoalId) {
        
      
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
    
   
    
        /*
    @AuraEnabled(cacheable=true) 
    public static boolean updateSharedGoal(String goalId, String status) {
        try
        {
          
                            phsManagerGoals__c a = [SELECT Id , Status__c   from phsManagerGoals__c WHERE Id  =: goalId LIMIT 1];
    									a.Status__c = status;
    									update a;
                                        return true; 
        }
        catch(Exception e)
        {
             System.debug('The following exception has occurred: ' + e.getMessage()); 
             return false;
        }
        
    }
    */
}