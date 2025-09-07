public without sharing class phsSurveyUserQuestionsController {

     @AuraEnabled() 
    public static string getUserQuestionList() {
        /*
        Date currentDate=Date.today();
        Date startDate=Date.newInstance(1900, 1, 7);
        Integer days = startDate.daysBetween(currentDate);
        days=Math.mod(days,7);
        return '';
		*/
        String userId=new phsUtilityController().getContactId();
        List<phsUserSurveyQuestions__c> qlist=new List<phsUserSurveyQuestions__c>();
        List<UserQuestionDetails> quserlist=new List<UserQuestionDetails>();
        try
        {
        qlist=[Select Id , Question__c,SurveyQuestionId__c,UserAnswer__c,Category__c from phsUserSurveyQuestions__c where User__c=:userId and IsActive__c=true  ];
            Integer count=0;
        for(phsUserSurveyQuestions__c q : qlist)
        {
            count++;
            UserQuestionDetails u=new UserQuestionDetails();
            u.rowNo=count;
            u.Id=q.Id;
            u.SurveyQuestionId=q.SurveyQuestionId__c;
            u.Question=q.Question__c;
            u.UserAnswer=q.UserAnswer__c;
            u.Category=q.Category__c;
            quserlist.add(u);    
        }
           
                String jsonResponse = JSON.serialize(quserlist);
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
    	public static string updateSurveyAnswer(String qid,String answer) {
           
            try
            {
           List<phsUserSurveyQuestions__c> a = [SELECT Id, UserAnswer__c from phsUserSurveyQuestions__c WHERE Id  =: qid Limit 1];
    								
                                        for(phsUserSurveyQuestions__c obj : a)
                                        {
                                        obj.UserAnswer__c = answer;
                                        
                                        }
                                       if(a.size()>0 && a !=null){
           									update a;

  										}
                String jsonResponse = JSON.serialize(true);
        return jsonResponse;
            }
            catch(Exception ex)
            {
               String jsonResponse = JSON.serialize(ex.getMessage());
        return jsonResponse; 
            }
    									
        }
    
    class UserQuestionDetails
    {
        public Integer rowNo;
        public string Id;
        public string SurveyQuestionId;
        public string Question;
        public string UserAnswer;
        public string Category;
        
    }
    
}