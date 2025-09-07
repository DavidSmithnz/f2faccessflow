global with sharing class phsBatchWellnessUserQuestionSync
    implements Database.Batchable<SObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Contact
            WHERE App_Role__c != null
        ]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> rawScope) {
        if (rawScope.isEmpty()) return;

        List<Contact> scope = (List<Contact>) rawScope;
        Set<Id> userIds = new Map<Id, Contact>(scope).keySet();

        // 1) Scoped cleanup: delete unanswered rows for these users only
        List<phsUserSurveyQuestions__c> toDelete = [
            SELECT Id
            FROM phsUserSurveyQuestions__c
            WHERE User__c IN :userIds
              AND (UserAnswer__c = null OR UserAnswer__c = '')
        ];
        if (!toDelete.isEmpty()) {
            Database.delete(toDelete, /* allOrNone */ false);
        }

        // 2) Deactivate answered rows & collect answered question Ids
        List<phsUserSurveyQuestions__c> answered = [
            SELECT Id, IsActive__c, SurveyQuestionId__c, User__c
            FROM phsUserSurveyQuestions__c
            WHERE User__c IN :userIds
              AND UserAnswer__c != null
        ];

        Map<Id, Set<Id>> userToAnsweredQIds = new Map<Id, Set<Id>>();
        for (phsUserSurveyQuestions__c a : answered) {
            a.IsActive__c = false;

            // ---- FIX: no putIfAbsent in Apex ----
            if (!userToAnsweredQIds.containsKey(a.User__c)) {
                userToAnsweredQIds.put(a.User__c, new Set<Id>());
            }
            userToAnsweredQIds.get(a.User__c).add(a.SurveyQuestionId__c);
        }
        if (!answered.isEmpty()) {
            update answered;
        }

        // 3) Load all available Survey Questions once per execute
        List<Survey_Question__c> allQuestions = [
            SELECT Id, Question__c, Grouping__c, Category__c, Name
            FROM Survey_Question__c
        ];
        if (allQuestions.isEmpty()) return;

        // 4) For each user in scope, pick up to 3 random new questions not yet answered
        List<phsUserSurveyQuestions__c> toInsert = new List<phsUserSurveyQuestions__c>();

        for (Contact c : scope) {
            Set<Id> already = userToAnsweredQIds.get(c.Id);

            List<Survey_Question__c> candidates = new List<Survey_Question__c>();
            for (Survey_Question__c q : allQuestions) {
                if (already == null || !already.contains(q.Id)) {
                    candidates.add(q);
                }
            }
            if (candidates.isEmpty()) continue;

            Integer pickCount = Math.min(3, candidates.size());

            // Partial Fisher–Yates shuffle to get first N unique randoms
            for (Integer i = 0; i < pickCount; i++) {
                Integer remaining = candidates.size() - i;
                Integer offset = Integer.valueOf(Math.floor(Math.random() * remaining));
                Integer j = i + offset;
                Survey_Question__c tmp = candidates[i];
                candidates[i] = candidates[j];
                candidates[j] = tmp;
            }

            for (Integer i = 0; i < pickCount; i++) {
                Survey_Question__c sq = candidates[i];
                phsUserSurveyQuestions__c qobj = new phsUserSurveyQuestions__c();
                qobj.User__c = c.Id;
                qobj.SurveyQuestionId__c = sq.Id;
                qobj.Question__c = sq.Question__c;
                qobj.Grouping__c = sq.Grouping__c;
                qobj.Category__c = sq.Category__c;
                qobj.IsActive__c = true;
                // qobj.Name = sq.Name; // only if Name is a text field (not Auto-Number)
                toInsert.add(qobj);
            }
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Flip all phsCoachCheckIn__c where Checkin_required__c = false → true (once per batch)
        List<phsCoachCheckIn__c> toUpdate = [
            SELECT Id, Checkin_required__c
            FROM phsCoachCheckIn__c
            WHERE Checkin_required__c = false
        ];
        if (!toUpdate.isEmpty()) {
            for (phsCoachCheckIn__c rec : toUpdate) {
                rec.Checkin_required__c = true;
            }
            update toUpdate;
        }
    }
}





// global  class phsBatchWellnessUserQuestionSync implements Database.Batchable<sObject>
// {
// global Database.QueryLocator start(Database.BatchableContext BC)
//     {
//        // String query = 'SELECT Id,Name FROM Account';
       
//         return null;//Database.getQueryLocator(query);
//     }
//     global void execute(Database.BatchableContext BC, List<Account> scope)
//     {
//         List<phsUserSurveyQuestions__c> deletelist=new List<phsUserSurveyQuestions__c>();
//         deletelist=[Select Id from phsUserSurveyQuestions__c where UserAnswer__c=:'' or UserAnswer__c=:null ];
//         if(deletelist.size()>0)
//         {
//         delete deletelist;
//         }
//         List<Contact> userlist=new List<Contact>();
//         userlist=[Select Id , App_Role__c from contact where App_Role__c !=: null];
        
//         for(Contact c : userlist)
//         {
//             String userId=c.Id;
//             List<phsUserSurveyQuestions__c> answeredlist=new List<phsUserSurveyQuestions__c>();
//             answeredlist=[Select Id, IsActive__c, SurveyQuestionId__c  from phsUserSurveyQuestions__c where User__c =:userId and UserAnswer__c!=null];
            
            
            
            
//             Set<Id> qids=new Set<Id>();
//             for(phsUserSurveyQuestions__c q : answeredlist)
//             {
//                 qids.add(q.SurveyQuestionId__c);
//                 q.IsActive__c=false;
//             }
//             if(answeredlist.size()>0)
//             {
//               update answeredlist;
//             }
//             List<Survey_Question__c> results = [SELECT Id, Question__c , Grouping__c, Category__c FROM Survey_Question__c  WHERE Id  Not IN :qids];
            
//             List<Integer> qnumbers=new List<Integer>();
            
//             if(results.size()>0)
//             {
//             Integer randomNumber = Integer.valueof((Math.random() * results.size()-1));
// 			qnumbers.add(randomNumber);
//             Integer counter=0;
//             Integer loopnumber=0;
//             while(counter<3)
//             {
//                randomNumber = Integer.valueof((Math.random() * results.size()-1));
//                if( !qnumbers.contains(randomNumber))
//                {
//                    qnumbers.add(randomNumber);
//                    counter++;
//                }
//               	loopnumber++;
//                 if(counter == (results.size()-1))
//                 {
//                     counter=5;  
//                 }
//             }
//             }
//             List<phsUserSurveyQuestions__c> newqlist=new List<phsUserSurveyQuestions__c>();
   
//             for(Integer i : qnumbers)
//             {
//          		Survey_Question__c sq=   results.get(i);
//                 phsUserSurveyQuestions__c qobj=new phsUserSurveyQuestions__c();
//                 qobj.Category__c=sq.Category__c;
//                 qobj.Question__c=sq.Question__c;
//                 qobj.Grouping__c=sq.Grouping__c;
//                 qobj.SurveyQuestionId__c=sq.Id;
//                 qobj.User__c=userId;
//                 qobj.Name=sq.Name;
//                 qobj.IsActive__c=true;
//                 newqlist.add(qobj);       
//             }
//             insert newqlist;
//         }
//  }
//     global void finish(Database.BatchableContext BC) {
//     }
// }