public without sharing class phsWellnessWaveController {
        
    @AuraEnabled(cacheable=true) 
    public static string getWellnessScoreTakenStatus() 
    {
        String userId=new phsUtilityController().getContactId();
        List<Contact> clist=new List<Contact>();
        clist=[Select Id, Most_Recent_Survey__c from Contact where Id=: userId ];
        if(clist[0].Most_Recent_Survey__c != null)
        {
            
            String jsonResponse = JSON.serialize(clist[0].Most_Recent_Survey__c);
            return jsonResponse;
        }
        else
        {
            String jsonResponse = JSON.serialize(null);
            return jsonResponse;
        }       
    }
    
    @AuraEnabled(cacheable=true) 
    public static string getWellnessScore() {
        
        String userId=new phsUtilityController().getContactId();
        List<phsUserSurveyQuestions__c> qlist=new List<phsUserSurveyQuestions__c>();
        List<Contact> clist=new List<Contact>();
        UserWellnessScore wellnessScore=new UserWellnessScore();
        try
        {            
            clist=[Select Id, Most_Recent_Survey__c from Contact where Id=: userId ];
            if(clist[0].Most_Recent_Survey__c != null)
            {
                wellnessScore.MostRecentSurvey=clist[0].Most_Recent_Survey__c;    
            }
            else
            {
                wellnessScore.MostRecentSurvey=null; 
            }
            
            qlist=[Select Id , User__c , Question__c,  UserAnswer__c,Category__c , IsActive__c from phsUserSurveyQuestions__c  where UserAnswer__c !='' and User__c =:userId];
            Integer count=0;
            for(phsUserSurveyQuestions__c q : qlist)
            {
                if(q.Category__c=='Technology') 
                {
                    wellnessScore.TechnologyCount+=1;
                    if(q.UserAnswer__c=='Strongly Disagree')
                    {
                        wellnessScore.Technology+=1; 
                    }
                    else if (q.UserAnswer__c=='Disagree')
                    {
                        wellnessScore.Technology+=2; 
                    }
                    else if (q.UserAnswer__c=='Neutral')
                    {
                        wellnessScore.Technology+=3; 
                    }
                    else if (q.UserAnswer__c=='Agree')
                    {
                        wellnessScore.Technology+=4; 
                    }
                    else if (q.UserAnswer__c=='Strongly Agree')
                    {
                        wellnessScore.Technology+=5; 
                    }
                }
                else if(q.Category__c=='Culture') 
                { 
                    wellnessScore.CultureCount+=1; 
                    if(q.UserAnswer__c=='Strongly Disagree')
                    {
                        wellnessScore.Culture+=1; 
                    }
                    else if (q.UserAnswer__c=='Disagree')
                    {
                        wellnessScore.Culture+=2; 
                    }
                    else if (q.UserAnswer__c=='Neutral')
                    {
                        wellnessScore.Culture+=3; 
                    }
                    else if (q.UserAnswer__c=='Agree')
                    {
                        wellnessScore.Culture+=4; 
                    }
                    else if (q.UserAnswer__c=='Strongly Agree')
                    {
                        wellnessScore.Culture+=5; 
                    }
                    
                }
                else if(q.Category__c=='Process') 
                {
                    wellnessScore.ProcessCount+=1; 
                    if(q.UserAnswer__c=='Strongly Disagree')
                    {
                        wellnessScore.Process+=1; 
                    }
                    else if (q.UserAnswer__c=='Disagree')
                    {
                        wellnessScore.Process+=2; 
                    }
                    else if (q.UserAnswer__c=='Neutral')
                    {
                        wellnessScore.Process+=3; 
                    }
                    else if (q.UserAnswer__c=='Agree')
                    {
                        wellnessScore.Process+=4; 
                    }
                    else if (q.UserAnswer__c=='Strongly Agree')
                    {
                        wellnessScore.Process+=5; 
                    }
                    
                }
                else if(q.Category__c=='Analytics') 
                {
                    wellnessScore.AnalyticsCount+=1; 
                    if(q.UserAnswer__c=='Strongly Disagree')
                    {
                        wellnessScore.Analytics+=1; 
                    }
                    else if (q.UserAnswer__c=='Disagree')
                    {
                        wellnessScore.Analytics+=2; 
                    }
                    else if (q.UserAnswer__c=='Neutral')
                    {
                        wellnessScore.Analytics+=3; 
                    }
                    else if (q.UserAnswer__c=='Agree')
                    {
                        wellnessScore.Analytics+=4; 
                    }
                    else if (q.UserAnswer__c=='Strongly Agree')
                    {
                        wellnessScore.Analytics+=5; 
                    }
                }
                else if(q.Category__c=='People') 
                {
                    wellnessScore.PeopleCount+=1; 
                    if(q.UserAnswer__c=='Strongly Disagree')
                    {
                        wellnessScore.People+=1; 
                    }
                    else if (q.UserAnswer__c=='Disagree')
                    {
                        wellnessScore.People+=2; 
                    }
                    else if (q.UserAnswer__c=='Neutral')
                    {
                        wellnessScore.People+=3; 
                    }
                    else if (q.UserAnswer__c=='Agree')
                    {
                        wellnessScore.People+=4; 
                    }
                    else if (q.UserAnswer__c=='Strongly Agree')
                    {
                        wellnessScore.People+=5; 
                    }
                }                                
            }
            if(wellnessScore.TechnologyCount > 0)
            {
                wellnessScore.Technology=wellnessScore.Technology/wellnessScore.TechnologyCount;
            }
            if(wellnessScore.PeopleCount > 0)
            {
                wellnessScore.People=wellnessScore.People/wellnessScore.PeopleCount;
            }
            if(wellnessScore.CultureCount > 0)
            {
                wellnessScore.Culture=wellnessScore.Culture/wellnessScore.CultureCount;
            }
            if(wellnessScore.AnalyticsCount > 0)
            {
                wellnessScore.Analytics=wellnessScore.Analytics/wellnessScore.AnalyticsCount;
            }
            if(wellnessScore.ProcessCount > 0)
            {
                wellnessScore.Process=wellnessScore.Process/wellnessScore.ProcessCount;    
            }
            double lowestvalue=wellnessScore.People;
            wellnessScore.LowScoreCategory='People' ;
            
            if(lowestvalue > wellnessScore.Technology)
            {
                wellnessScore.LowScoreCategory='Technology' ;
                lowestvalue= wellnessScore.Technology; 
            }
            if(lowestvalue > wellnessScore.Culture)
            {
                wellnessScore.LowScoreCategory='Culture' ;
                lowestvalue= wellnessScore.Culture; 
            }
            if(lowestvalue > wellnessScore.Process)
            {
                wellnessScore.LowScoreCategory='Process' ;
                lowestvalue= wellnessScore.Process; 
            }
            if(lowestvalue > wellnessScore.Analytics)
            {
                wellnessScore.LowScoreCategory='Analytics' ;
                lowestvalue= wellnessScore.Analytics; 
            }                        
            List<phsTips__c> qTips=new List<phsTips__c>();
            qTips=[Select Id , Name , Description__c, Category__c  from phsTips__c  where isActive__c=true ];
            phsTips__c obj =new phsTips__c();
            if(qTips.size()>1)
            {
                Integer randomNumber = Integer.valueof((Math.random() * qTips.size()-1));
                obj=qTips.get(randomNumber);
            }
            else if(qTips.size()==1)
            {
                obj=qTips.get(0);
            }
            
            wellnessScore.TipOfTheDay=obj.Description__c;
            
            String jsonResponse = JSON.serialize(wellnessScore);
            return jsonResponse;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
            String jsonResponse = JSON.serialize(e.getMessage());
            return jsonResponse;
        }        
    }
    class UserWellnessScore
    {
        public double Technology=0;
        public double TechnologyCount=0;
        public double People=0;
        public double PeopleCount=0;
        public double Culture=0;
        public double CultureCount=0;
        public double Analytics=0;
        public double AnalyticsCount=0;
        public double Process=0;
        public double ProcessCount=0;
        public String LowScoreCategory;
        public String TipOfTheDay;
        public String MostRecentSurvey;
        
    }
    
    class CategoryDescription
    {
        public String Technology;
        public String Process;
        public String People;
        public String Analytics;
        public String Culture;
    }
    
    @AuraEnabled(cacheable=true) 
    public static string getCategoryDescription() {
        
        CategoryDescription obj=new CategoryDescription();
        List<phsCoreElements__c> qCategory=new List<phsCoreElements__c>();
        qCategory=[Select Id , CoreElement__c,CoreElementDescription__c  from phsCoreElements__c ];
        for(phsCoreElements__c c : qCategory)
        {
            if(c.CoreElement__c=='Technology') 
            {
                obj.Technology=c.CoreElementDescription__c;
            } 
            if(c.CoreElement__c=='People') 
            {
                obj.People=c.CoreElementDescription__c;
            } 
            if(c.CoreElement__c=='Culture') 
            {
                obj.Culture=c.CoreElementDescription__c;
            } 
            if(c.CoreElement__c=='Process') 
            {
                obj.Process=c.CoreElementDescription__c;
            } 
            if(c.CoreElement__c=='Analytics') 
            {
                obj.Analytics=c.CoreElementDescription__c;
            } 
        }
        
        String jsonResponse = JSON.serialize(obj);
        return jsonResponse;        
    }    
}