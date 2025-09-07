public class phsUserPerformanceController {
 @AuraEnabled(cacheable=true) 
    public static String getUserPerformanceDetails() {
        
        String userId=new phsUtilityController().getContactId();
        List<phsUGPerformance__c> userperformance = new List<phsUGPerformance__c>(); 
       // userId=new phsUtilityController ().decrypt(userId);
        uGPerformance obj=new uGPerformance();
      //  obj.successStories=userId;
        try
        {
        userperformance = [SELECT Id , StressLevel__c , SuccessStories__c  ,TimeInFlowState__c, FocusQuality__c, ChallengesFaced__c ,UserId__c
                            FROM phsUGPerformance__c where UserId__c =: userId ];
         if(userperformance.size() > 0)
          {
              obj.stressLevel=userperformance[0].StressLevel__c; 
              obj.timeInFlowState=userperformance[0].TimeInFlowState__c;
              obj.focusQuality=userperformance[0].FocusQuality__c;
              obj.successStories=userperformance[0].SuccessStories__c;
              obj.challengesFaced=userperformance[0].ChallengesFaced__c;
              obj.keyId=userperformance[0].Id;
          }
           
            
            List<Contact> c=[Select App_Role__c from Contact where Id=: userId];
            if(c.size()>0)
            {
                obj.appRole=c[0].App_Role__c;
            }
            
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());    
        }
        String jsonResponse = JSON.serialize(obj);
        return jsonResponse;
    }
    
    @AuraEnabled() 
    public static String getMyUserPerformanceDetails(String userId) {
        
      //  String userId=new phsUtilityController().getContactId();
        List<phsUGPerformance__c> userperformance = new List<phsUGPerformance__c>(); 
       // userId=new phsUtilityController ().decrypt(userId);
        uGPerformance obj=new uGPerformance();
      //  obj.successStories=userId;
        try
        {
        userperformance = [SELECT Id , StressLevel__c , SuccessStories__c  ,TimeInFlowState__c, FocusQuality__c, ChallengesFaced__c ,UserId__c
                            FROM phsUGPerformance__c where UserId__c =: userId ];
         if(userperformance.size() > 0)
          {
              obj.stressLevel=userperformance[0].StressLevel__c; 
              obj.timeInFlowState=userperformance[0].TimeInFlowState__c;
              obj.focusQuality=userperformance[0].FocusQuality__c;
              obj.successStories=userperformance[0].SuccessStories__c;
              obj.challengesFaced=userperformance[0].ChallengesFaced__c;
              obj.keyId=userperformance[0].Id;
          }
           
            
            List<Contact> c=[Select App_Role__c from Contact where Id=: userId];
            if(c.size()>0)
            {
                obj.appRole=c[0].App_Role__c;
            }
            
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage());    
        }
        String jsonResponse = JSON.serialize(obj);
        return jsonResponse;
    }
    
    
    class uGPerformance
    {
        public Decimal stressLevel;
        public Decimal timeInFlowState;
        public Decimal focusQuality;
        public String successStories;
        public String challengesFaced;
        public String keyId;
        public String appRole;
        
    }
    
       @AuraEnabled() 
    public static String updatePerformance(String upId, double stressLevel,double focusQuality, 
                                 double timeInFlowState,String challengesFaced, String successStories ) {
                                 
                                    try
                                    {
                                     

                                        List<phsUGPerformance__c> a = [SELECT Id, StressLevel__c , SuccessStories__c  ,TimeInFlowState__c, FocusQuality__c, ChallengesFaced__c from phsUGPerformance__c WHERE Id  =: upId Limit 1];
    								
                                        for(phsUGPerformance__c obj : a)
                                        {
                                        obj.StressLevel__c = stressLevel;
                                        obj.TimeInFlowState__c = timeInFlowState;
                                        obj.FocusQuality__c = focusQuality;
                                        obj.ChallengesFaced__c = challengesFaced;
                                        obj.SuccessStories__c = successStories;
                                        }
                                       if(a.size()>0 && a !=null){
           									update a;

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