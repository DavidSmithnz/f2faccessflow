public with sharing class phsUserGoalsController {
    
    @AuraEnabled(cacheable=true) 
    public static String getUserGoalList( ) {
        phsUtilityController utility=new phsUtilityController();
        String userId=utility.getContactId();
        List<phsUserGoals__c> usergoals = new List<phsUserGoals__c>(); 
        List<myGoal> mygoals = new List<myGoal>(); 
        
        try
        {
            usergoals = [SELECT Id , GoalName__c , GoalType__c  ,Status__c,FocusArea__c,StandardGoalId__c ,UserId__c,GoalAdherence__c,
                         GoalEffectiveness__c,Active__c,LastCheckInDate__c,SharedBy__c,SharedTo__c , ManagerFeedback__c , GoalStrategyStatus__c ,
                         (Select Strategy__c from phsUserGoalsStrategies__r  order by createddate desc limit 1) FROM phsUserGoals__c where UserId__c =: userId];
            
            for (phsUserGoals__c c : usergoals)
            { 
                myGoal obj=new myGoal();
                obj.keyId=c.Id;
                obj.goalName=c.GoalName__c;
                obj.goalType=c.GoalType__c;
                obj.goalStatus=c.Status__c;
                obj.focusArea=c.FocusArea__c;
                obj.goalAdherence=c.GoalAdherence__c;
                obj.goalEffectiveness=c.GoalEffectiveness__c;
                obj.isActive=c.Active__c;
                obj.StandardGoalId=c.StandardGoalId__c;
                obj.LastCheckInDate=c.LastCheckInDate__c.format('MM-dd-YY, HH:MM');
                obj.SharedBy=c.SharedBy__c;
                obj.SharedTo=c.SharedTo__c;
                obj.ManagerFeedback=c.ManagerFeedback__c;
                obj.CheckInDate=c.LastCheckInDate__c;
                obj.GoalStrategyStatus=c.GoalStrategyStatus__c;
                if(c.phsUserGoalsStrategies__r!=null)
                {
                    for(phsUserGoalsStrategies__c s : c.phsUserGoalsStrategies__r)
                    {
                        
                        obj.StrategyTitle =s.Strategy__c ;  
                    }
                }
                mygoals.add(obj);
            }
        }
        catch(Exception e)
        {
            System.debug('getUserGoalList : The following exception has occurred: ' + e.getMessage()); 
            utility.throwUserException('120022','getUserGoalList: ' + e.getMessage());
        }
        
        String jsonResponse = JSON.serialize(mygoals);
        return jsonResponse;
    } 
    
    // My User Specific Data    
    @AuraEnabled() 
    public static String getMyUserGoalList(String userId ) {
        // String userId=new phsUtilityController().getContactId();
        List<phsUserGoals__c> usergoals = new List<phsUserGoals__c>(); 
        List<myGoal> mygoals = new List<myGoal>(); 
        
        try
        {
            usergoals = [SELECT Id , GoalName__c , GoalType__c  ,Status__c,FocusArea__c,StandardGoalId__c ,UserId__c,GoalAdherence__c,
                         GoalEffectiveness__c,Active__c,LastCheckInDate__c,SharedBy__c,SharedTo__c,ManagerFeedback__c,GoalStrategyStatus__c ,
                         (Select Strategy__c from phsUserGoalsStrategies__r  order by createddate desc limit 1)  FROM phsUserGoals__c where UserId__c =: userId];
            
            for (phsUserGoals__c c : usergoals)
            { 
                myGoal obj=new myGoal();
                obj.keyId=c.Id;
                obj.goalName=c.GoalName__c;
                obj.goalType=c.GoalType__c;
                obj.goalStatus=c.Status__c;
                obj.focusArea=c.FocusArea__c;
                obj.goalAdherence=c.GoalAdherence__c;
                obj.goalEffectiveness=c.GoalEffectiveness__c;
                obj.isActive=c.Active__c;
                obj.StandardGoalId=c.StandardGoalId__c;
                obj.LastCheckInDate=c.LastCheckInDate__c.format('MM-dd-YY, HH:MM');
                obj.SharedBy=c.SharedBy__c;
                obj.SharedTo=c.SharedTo__c;
                obj.ManagerFeedback=c.ManagerFeedback__c;
                obj.CheckInDate=c.LastCheckInDate__c;
                obj.GoalStrategyStatus=c.GoalStrategyStatus__c;
                
                if(c.phsUserGoalsStrategies__r!=null)
                {
                    for(phsUserGoalsStrategies__c s : c.phsUserGoalsStrategies__r)
                    {
                        
                        obj.StrategyTitle =s.Strategy__c ;  
                    }
                }
                mygoals.add(obj);
            }
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
        }
        
        String jsonResponse = JSON.serialize(mygoals);
        return jsonResponse;
    } 
    
    @AuraEnabled() 
    public static String updateManagerFeedback(String userId, String feedback ) 
    {
        try
        {
            List<phsUserGoals__c> usergoals  = [SELECT Id , ManagerFeedback__c FROM phsUserGoals__c where Id =: userId];
            
            for(phsUserGoals__c obj : usergoals)
            {
                obj.ManagerFeedback__c = feedback;
                
            }
            if(usergoals.size()>0 && usergoals !=null){
                update usergoals;
                
            }
            
            String jsonResponse = JSON.serialize('Updated');
            return jsonResponse;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
            String jsonResponse = JSON.serialize(e.getMessage());
            return jsonResponse;
        }
    }
    class myGoalStatus
    {
        public string status;
        public string goalStatus;
    }
    
    class myGoal
    {
        public string keyId;
        public string goalName;
        public string goalType;
        public string goalStatus;
        public string focusArea;
        
        public Decimal goalAdherence;
        public Decimal goalEffectiveness;
        public boolean isActive;
        public String StandardGoalId;
        public String LastCheckInDate;
        public String SharedBy;
        public String SharedTo;
        public String ManagerFeedback;
        public Datetime CheckInDate; 
        public String GoalStrategyStatus;
        public String StrategyTitle;
    }
    
    @AuraEnabled() 
    public static String getUserGoalListUpdate( ) {
        String userId=new phsUtilityController().getContactId();
        List<phsUserGoals__c> usergoals = new List<phsUserGoals__c>(); 
        List<myGoal> mygoals = new List<myGoal>(); 
        
        try
        {
            usergoals = [SELECT Id , GoalName__c , GoalType__c  ,Status__c,FocusArea__c,StandardGoalId__c ,UserId__c,GoalAdherence__c,GoalEffectiveness__c
                         ,SharedBy__c,SharedTo__c,Active__c,LastCheckInDate__c, ManagerFeedback__c,GoalStrategyStatus__c ,
                         (Select Strategy__c from phsUserGoalsStrategies__r  order by createddate desc limit 1) FROM phsUserGoals__c where UserId__c =: userId];
            
            for (phsUserGoals__c c : usergoals)
            { 
                myGoal obj=new myGoal();
                obj.keyId=c.Id;
                obj.goalName=c.GoalName__c;
                obj.goalType=c.GoalType__c;
                obj.goalStatus=c.Status__c;
                obj.focusArea=c.FocusArea__c;
                obj.goalAdherence=c.GoalAdherence__c;
                obj.goalEffectiveness=c.GoalEffectiveness__c;
                obj.isActive=c.Active__c;
                obj.LastCheckInDate=c.LastCheckInDate__c.format('MM-dd-YY, HH:MM');
                obj.StandardGoalId=c.StandardGoalId__c;
                obj.SharedBy=c.SharedBy__c;
                obj.SharedTo=c.SharedTo__c;
                obj.ManagerFeedback=c.ManagerFeedback__c;
                obj.CheckInDate=c.LastCheckInDate__c;
                obj.GoalStrategyStatus=c.GoalStrategyStatus__c;
                if(c.phsUserGoalsStrategies__r!=null)
                {
                    for(phsUserGoalsStrategies__c s : c.phsUserGoalsStrategies__r)
                    {
                        
                        obj.StrategyTitle =s.Strategy__c ;  
                    }
                }
                mygoals.add(obj);
            }
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
            String jsonResponse = JSON.serialize(e.getMessage());
            return jsonResponse;
        }
        
        String jsonResponse = JSON.serialize(mygoals);
        return jsonResponse;
    } 
    
    @AuraEnabled() 
    public static string addUserGoal(String goalName,String goalType, String focusArea,
                                     String managerGoalId,String StandardGoalId,String SharedBy , String SharedTo, String isShared, String GoalStrategy ) {
                                         try
                                         {
                                             String userId=new phsUtilityController().getContactId();
                                             
                                             List<phsUserGoals__c> usergoals = new List<phsUserGoals__c>(); 
                                             usergoals = [SELECT Id , GoalName__c , GoalType__c  ,Status__c,FocusArea__c,StandardGoalId__c ,UserId__c,GoalAdherence__c,GoalEffectiveness__c
                                                          ,SharedBy__c,SharedTo__c,Active__c,LastCheckInDate__c, ManagerFeedback__c,GoalStrategyStatus__c FROM phsUserGoals__c where UserId__c =: userId and GoalName__c=:goalName and Active__c=: true  ];
                                             
                                             
                                             Boolean addStatus=true;
                                             String returnGoalStatus='';
                                             if(usergoals.size() == 0)
                                             {
                                                 addStatus=true;   
                                             }
                                             else 
                                             {
                                                 List<phsUserGoalsStrategies__c> phsStrategieslist = new List<phsUserGoalsStrategies__c>(); 
                                                 
                                                 for(phsUserGoals__c ug :usergoals  )
                                                 {
                                                     phsStrategieslist = [SELECT Id , Strategy__c, StrategyType__c ,GoalId__c 
                                                                          FROM phsUserGoalsStrategies__c where GoalId__c =: ug.Id and Strategy__c=:GoalStrategy ];
                                                     if(phsStrategieslist.size()>0)
                                                     {
                                                         addStatus=false;
                                                         returnGoalStatus=ug.GoalStrategyStatus__c;
                                                         break;
                                                     }
                                                     
                                                 }
                                             }
                                             
                                             
                                             if(addStatus == true)
                                             {
                                                 phsUserGoals__c obj=new phsUserGoals__c();
                                                 obj.UserId__c=userId;
                                                 obj.GoalName__c=goalName;
                                                 
                                                 obj.GoalType__c=goalType;
                                                 obj.FocusArea__c=focusArea;
                                                 obj.GoalAdherence__c=0.0;
                                                 obj.GoalEffectiveness__c=0.0;
                                                 obj.Active__c=true;
                                                 obj.Status__c=isShared;
                                                 
                                                 obj.SharedTo__c=SharedTo;
                                                 obj.SharedBy__c=SharedBy;
                                                 
                                                 obj.StandardGoalId__c=StandardGoalId;
                                                 obj.LastCheckInDate__c=Datetime.now();
                                                 if(managerGoalId!=null)
                                                 {
                                                     obj.ManagerGoalId__c=new phsUtilityController ().decrypt(managerGoalId);
                                                 }
                                                 insert obj;
                                                 
                                                 
                                                 String jsonResponse = JSON.serialize(obj.Id);
                                                 return jsonResponse;
                                             }
                                             else
                                             {
                                                 myGoalStatus o=new myGoalStatus();
                                                 o.status='GoalExists';
                                                 o.goalStatus=returnGoalStatus;
                                                 String jsonResponse = JSON.serialize(o);
                                                 return jsonResponse;
                                                 
                                             }
                                             
                                         }
                                         
                                         
                                         catch(Exception e)
                                         {
                                             System.debug('The following exception has occurred: ' + e.getMessage()); 
                                             String jsonResponse = JSON.serialize('Goal Failed to Add'+ e.getMessage());
                                             return jsonResponse;   
                                         }
                                         
                                         
                                     }
    
    
    @AuraEnabled() 
    public static String updateUserGoal(String usergoalId, double effectiveness,double adherence, 
                                        boolean isActive, String goalStrategyStatus ) {
                                            
                                            try
                                            {
                                                List<phsUserGoals__c> usergoals  = [SELECT Id , GoalName__c , GoalType__c  ,Status__c,FocusArea__c ,UserId__c,GoalAdherence__c,GoalEffectiveness__c,Active__c,GoalStrategyStatus__c FROM phsUserGoals__c where Id =: usergoalId];
                                                
                                                for(phsUserGoals__c obj : usergoals)
                                                {
                                                    obj.GoalAdherence__c = adherence;
                                                    obj.GoalEffectiveness__c = effectiveness;
                                                    obj.Active__c = isActive;
                                                    obj.LastCheckInDate__c=Datetime.now();
                                                    obj.GoalStrategyStatus__c=goalStrategyStatus;
                                                    
                                                }
                                                if(usergoals.size()>0 && usergoals !=null){
                                                    update usergoals;
                                                    
                                                }
                                                
                                                
                                                String jsonResponse = JSON.serialize('Updated');
                                                return jsonResponse;
                                            }
                                            catch(Exception e)
                                            {
                                                System.debug('The following exception has occurred: ' + e.getMessage()); 
                                                String jsonResponse = JSON.serialize(e.getMessage());
                                                return jsonResponse;
                                            }
                                            
                                        }
    
}