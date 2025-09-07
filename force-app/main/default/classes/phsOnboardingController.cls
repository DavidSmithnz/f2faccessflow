public without sharing  class phsOnboardingController {

      @AuraEnabled(cacheable=true) 
    public static string getOnBoardingQuestions() {
       
        //String userId=new phsUtilityController().getContactId();
        List<OnboardingQuestion> qlistresp=new List<OnboardingQuestion>();
         List<phsUserOnboardingQuestion__c> qlist=new List<phsUserOnboardingQuestion__c>();
        try
        {
        qlist=[Select Id , Question__c , IsMultiChoice__c ,Category__c from phsUserOnboardingQuestion__c where Enable__c=true ];  
        for(phsUserOnboardingQuestion__c c : qlist)
        {
            OnboardingQuestion obj=new OnboardingQuestion();
           	obj.Id=c.Id;
            obj.Question=c.Question__c;
            obj.IsMultiChoice=c.IsMultiChoice__c;
            obj.Category=c.Category__c;
            obj.UserAnswer='';
            
            List<phsUserOnboardingAnswerOptions__c> olist=new List<phsUserOnboardingAnswerOptions__c>();
            olist  = [Select Id , Option__c , phsUserOnboardingQuestion__c from phsUserOnboardingAnswerOptions__c where Enable__c=true and phsUserOnboardingQuestion__c=:c.Id  ];  
          	obj.options=new List<OnboardingQuestionOptions>();
            
            for(phsUserOnboardingAnswerOptions__c o : olist)
            {
                OnboardingQuestionOptions oobj=new OnboardingQuestionOptions();
                oobj.Id=o.Id;
                oobj.QId=o.phsUserOnboardingQuestion__c;
                oobj.Option=o.Option__c;
                oobj.QId_OptionId=o.phsUserOnboardingQuestion__c+':'+o.Id;
     			obj.Options.add(oobj);
            }
            
            
            qlistresp.add(obj);
        } 
        String jsonResponse = JSON.serialize(qlistresp);
        return jsonResponse;
        }
           catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
             String jsonResponse = JSON.serialize('Error : '+e.getMessage());
       return jsonResponse;
        }  
    }
     class OnboardingQuestion
    {
        public String Id;
        public String Question;
        public boolean IsMultiChoice;
        public List<OnboardingQuestionOptions> Options;
        public String Category;
        public String UserAnswer;
	}
    
      @AuraEnabled(cacheable=true) 
    public static string getOnBoardingAnswerOptions() {
       
       // String userId=new phsUtilityController().getContactId();
        List<OnboardingQuestionOptions> olistresp=new List<OnboardingQuestionOptions>();
         List<phsUserOnboardingAnswerOptions__c> olist=new List<phsUserOnboardingAnswerOptions__c>();
        try
        {
        olist=[Select Id , Option__c , phsUserOnboardingQuestion__c from phsUserOnboardingAnswerOptions__c where Enable__c=true ];  
        for(phsUserOnboardingAnswerOptions__c c : olist)
        {
            OnboardingQuestionOptions obj=new OnboardingQuestionOptions();
           	obj.Id=c.Id;
            obj.QId=c.phsUserOnboardingQuestion__c;
             obj.Option=c.Option__c;
            
          	olistresp.add(obj);
        } 
        String jsonResponse = JSON.serialize(olistresp);
        return jsonResponse;
        }
           catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
             String jsonResponse = JSON.serialize('Error : '+e.getMessage());
       return jsonResponse;
        }  
    }
    
        class OnboardingQuestionOptions
    {
        public String Id;
        public String QId;
        public String Option;
        public String QId_OptionId;
	}
    
  @AuraEnabled(cacheable=true) 
    public static string getOnBoardingUserAnswer() {
       
        String userId=new phsUtilityController().getContactId();
        List<OnboardingUserAnswer> ulistresp=new List<OnboardingUserAnswer>();
         List<phsOnboardingUserAnswer__c> ulist=new List<phsOnboardingUserAnswer__c>();
        try
        {
        ulist=[Select Id , QuestionId__c, UserAnswer__c ,UserAnswerId__c, ContactId__c  from phsOnboardingUserAnswer__c where ContactId__c=:userId ];  
        for(phsOnboardingUserAnswer__c c : ulist)
        {
            OnboardingUserAnswer obj=new OnboardingUserAnswer();
           	obj.Id=c.Id;
            obj.QId=c.QuestionId__c;
             obj.OId=c.UserAnswerId__c;
             obj.UserOption=c.UserAnswer__c;
          	ulistresp.add(obj);
        } 
        String jsonResponse = JSON.serialize(ulistresp);
        return jsonResponse;
        }
           catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
             String jsonResponse = JSON.serialize('Error : '+e.getMessage());
       return jsonResponse;
        }  
    }
       class OnboardingUserAnswer
    {
        public String Id;
        public String QId;
        public String OId;
        public String UserOption;
	}
    
    
     @AuraEnabled() 
    	public static String getOnBoardingStatus()
        {
             phsUtilityController utility=new phsUtilityController();
       		String userId=new phsUtilityController().getContactId(); 
            List<Contact> clist=new List<Contact>();
        	clist=[Select Id , OnBoardingCompleted__c  from Contact where  Id=: userId  and OnBoardingCompleted__c=false ];
            if(clist.size()>0)
            {
                 String jsonResponse = JSON.serialize(false);
        	return jsonResponse;
            }
            else
            {
                 String jsonResponse = JSON.serialize(true);
        	return jsonResponse;
            }
                
        }
    
          class UserAnswer
    {
        public String QId;
        public String OId;
        public String UserAnswer;
      
	}

      @AuraEnabled() 
    	public static String addUpdateOnBoardingUserAnswer(String userAnswerList) {
        try
        {
            phsUtilityController utility=new phsUtilityController();
       		String userId=new phsUtilityController().getContactId();
             List<UserAnswer> userAnswerListData = (List<UserAnswer>)JSON.deserialize(userAnswerList, List<UserAnswer>.class);

            for(UserAnswer u : userAnswerListData)
            {
            
			List<phsOnboardingUserAnswer__c> ulist=new List<phsOnboardingUserAnswer__c>();
        	ulist=[Select Id , QuestionId__c, UserAnswer__c ,UserAnswerId__c, ContactId__c  from phsOnboardingUserAnswer__c where ContactId__c=:userId And QuestionId__c=: u.QId  ];
            if(ulist.size()>0)
            {
            	 ulist[0].UserAnswerId__c= u.OId;
                 ulist[0].UserAnswer__c= u.UserAnswer;
                 update ulist;
            }
        	else
        	{
            	phsOnboardingUserAnswer__c obj =new phsOnboardingUserAnswer__c();
                
                obj.UserAnswerId__c= u.OId;
                obj.UserAnswer__c= u.UserAnswer;
                 obj.QuestionId__c= u.QId;
                 obj.ContactId__c= userId;
                insert obj;
        	}
         }
            List<Contact> clist=new List<Contact>();
            clist=[Select Id , OnBoardingCompleted__c  from Contact where Id=:userId And OnBoardingCompleted__c=false ];
            if(clist.size()>0)
            {
            	 clist[0].OnBoardingCompleted__c= true;
                 update clist;
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
    	public static String updateOnBoardingStatus()
        {
             phsUtilityController utility=new phsUtilityController();
       		String userId=new phsUtilityController().getContactId(); 
            List<Contact> clist=new List<Contact>();
        	clist=[Select Id , OnBoardingCompleted__c  from Contact where  Id=: userId  ];
            if(clist.size()>0)
            {
                clist[0].OnBoardingCompleted__c=true;
                update clist;
                 String jsonResponse = JSON.serialize(true);
        	return jsonResponse;
            }
            else
            {
                 String jsonResponse = JSON.serialize(false);
        	return jsonResponse;
            }
                
        }
    
    
}