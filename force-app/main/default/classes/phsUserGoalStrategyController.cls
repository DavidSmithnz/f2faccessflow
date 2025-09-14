public class phsUserGoalStrategyController {
    
    
    @AuraEnabled(cacheable=true) 
    public static string addUserGoalStrategy(String goalId,String strategy, String strategyType ) {
        try
        {
            
            phsUserGoalsStrategies__c obj=new phsUserGoalsStrategies__c();
            obj.GoalId__c=goalId;
            obj.Strategy__c=strategy;
            obj.StrategyType__c=strategyType;
            
            
            insert obj;
            
            String jsonResponse = JSON.serialize('Added Successfully');
            return jsonResponse;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
        }
        String jsonResponse = JSON.serialize('Goal Failed to Add');
        return jsonResponse;                          
        
    }
    
    
    @AuraEnabled(cacheable=true) 
    public static string getUserGoalStrategies(String goalId)
    {
        List<phsUserGoalsStrategies__c> phsUserStrategieslist = new List<phsUserGoalsStrategies__c>(); 
        List<GoalStrategy> strategieslist = new List<GoalStrategy>(); 
        try
        {
            phsUserStrategieslist = [SELECT Id , Strategy__c ,StrategyType__c,GoalId__c
                                     FROM phsUserGoalsStrategies__c where GoalId__c =: goalId ];
            for (phsUserGoalsStrategies__c s: phsUserStrategieslist) {
                GoalStrategy obj=new GoalStrategy();
                obj.strategyId=s.Id;
                obj.strategyName=s.Strategy__c;
                obj.strategyType=s.StrategyType__c;
                obj.userGoalId=s.GoalId__c; 
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
    class GoalStrategy
    {
        public String strategyId;
        public String strategyName;
        public String strategyType;
        public String userGoalId;
        
    }
    
}