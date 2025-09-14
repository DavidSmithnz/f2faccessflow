public without sharing class phsGoalController {
    
    @AuraEnabled() 
    public static String getGoalList(String role ) {
   
        List<CommonGoal> allGoals=new  List<CommonGoal>();
        List<phsGoals__c> goals = new List<phsGoals__c>();         
        try
        {
            goals = [SELECT Id , Name, Name__c    ,FocusAreaId__r.Name__c, Role__c FROM phsGoals__c where Role__c =: role];
            for (phsGoals__c g: goals) {
                CommonGoal obj=new CommonGoal();
                obj.goalId=g.Id;
                obj.goalName=g.Name__c;
                obj.goalType='Standard';
                obj.focusAreaName=g.FocusAreaId__r.Name__c;
                allGoals.add(obj);
                
            }
            String jsonResponse = JSON.serialize(allGoals);
            return jsonResponse;
        }
        catch(Exception e){
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
    }
}