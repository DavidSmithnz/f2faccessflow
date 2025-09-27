public class phsTestJob {

    public static void TestJob()
    {
       
           List<phsUserSurveyQuestions__c> deletelist=new List<phsUserSurveyQuestions__c>();
        deletelist=[Select Id from phsUserSurveyQuestions__c where UserAnswer__c=:'' or UserAnswer__c=:null ];
        if(deletelist.size()>0)
        {
        delete deletelist;
        }
        List<Contact> userlist=new List<Contact>();
        userlist=[Select Id , App_Role__c from contact where App_Role__c !=: null];
        
        for(Contact c : userlist)
        {
            String userId=c.Id;
            List<phsUserSurveyQuestions__c> answeredlist=new List<phsUserSurveyQuestions__c>();
            answeredlist=[Select Id, IsActive__c, SurveyQuestionId__c  from phsUserSurveyQuestions__c where User__c =:userId and UserAnswer__c!=:null];

            Set<Id> qids=new Set<Id>();
            for(phsUserSurveyQuestions__c q : answeredlist)
            {
                qids.add(q.SurveyQuestionId__c);
                q.IsActive__c=false;
            }
            if(answeredlist.size()>0)
            {
              update answeredlist;
            }
            List<Survey_Question__c> results = [SELECT Id, Question__c , Grouping__c, Category__c,Name FROM Survey_Question__c  WHERE Id  Not IN :qids];
            
            List<Integer> qnumbers=new List<Integer>();
            
            if(results.size()>0)
            {
            Integer randomNumber = Integer.valueof((Math.random() * results.size()-1));
			qnumbers.add(randomNumber);
            Integer counter=0;
            Integer loopnumber=0;
            while(counter<2)
            {
               randomNumber = Integer.valueof((Math.random() * results.size()-1));
               if( !qnumbers.contains(randomNumber))
               {
                   qnumbers.add(randomNumber);
                   counter++;
               }
              	loopnumber++;
                if(counter == (results.size()-1))
                {
                    counter=5;  
                }
            }
            }
            List<phsUserSurveyQuestions__c> newqlist=new List<phsUserSurveyQuestions__c>();
   
            for(Integer i : qnumbers)
            {
         		Survey_Question__c sq=   results.get(i);
                phsUserSurveyQuestions__c qobj=new phsUserSurveyQuestions__c();
                qobj.Category__c=sq.Category__c;
                qobj.Question__c=sq.Question__c;
                qobj.Grouping__c=sq.Grouping__c;
                qobj.SurveyQuestionId__c=sq.Id;
                qobj.User__c=userId;
                qobj.Name=sq.Name;
                qobj.IsActive__c=true;
                newqlist.add(qobj);       
            }
            insert newqlist;
        }
    }
}