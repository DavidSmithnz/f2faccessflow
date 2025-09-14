global with sharing class phsBatchWellnessUserQuestionSync
    implements Database.Batchable<SObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Batch Start: Preparing to query Contacts with App_Role__c != null');

        return Database.getQueryLocator([
            SELECT Id
            FROM Contact
            WHERE App_Role__c != null
        ]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> rawScope) {
        System.debug('Batch Execute: Scope size = ' + rawScope.size());

        if (rawScope.isEmpty()) {
            System.debug('No contacts in scope, returning early');
            return;
        }

        List<Contact> scope = (List<Contact>) rawScope;
        Set<Id> userIds = new Map<Id, Contact>(scope).keySet();
        System.debug('Contacts in scope: ' + userIds);

        // 1) Scoped cleanup
        List<phsUserSurveyQuestions__c> toDelete = [
            SELECT Id
            FROM phsUserSurveyQuestions__c
            WHERE User__c IN :userIds
              AND (UserAnswer__c = null OR UserAnswer__c = '')
        ];
        System.debug('Deleting ' + toDelete.size() + ' unanswered survey questions');
        if (!toDelete.isEmpty()) {
            Database.delete(toDelete, /* allOrNone */ false);
        }

        // 2) Deactivate answered rows
        List<phsUserSurveyQuestions__c> answered = [
            SELECT Id, IsActive__c, SurveyQuestionId__c, User__c
            FROM phsUserSurveyQuestions__c
            WHERE User__c IN :userIds
              AND UserAnswer__c != null
        ];
        System.debug('Found ' + answered.size() + ' answered survey questions');

        Map<Id, Set<Id>> userToAnsweredQIds = new Map<Id, Set<Id>>();
        for (phsUserSurveyQuestions__c a : answered) {
            a.IsActive__c = false;
            if (!userToAnsweredQIds.containsKey(a.User__c)) {
                userToAnsweredQIds.put(a.User__c, new Set<Id>());
            }
            userToAnsweredQIds.get(a.User__c).add(a.SurveyQuestionId__c);
        }
        if (!answered.isEmpty()) {
            update answered;
            System.debug('Updated ' + answered.size() + ' answered questions to inactive');
        }

        // 3) Load all Survey Questions
        List<Survey_Question__c> allQuestions = [
            SELECT Id, Question__c, Grouping__c, Category__c, Name
            FROM Survey_Question__c
        ];
        System.debug('Loaded ' + allQuestions.size() + ' total survey questions');

        if (allQuestions.isEmpty()) return;

        // 4) Assign new questions
        List<phsUserSurveyQuestions__c> toInsert = new List<phsUserSurveyQuestions__c>();

        for (Contact c : scope) {
            Set<Id> already = userToAnsweredQIds.get(c.Id);
            List<Survey_Question__c> candidates = new List<Survey_Question__c>();

            for (Survey_Question__c q : allQuestions) {
                if (already == null || !already.contains(q.Id)) {
                    candidates.add(q);
                }
            }
            System.debug('Contact ' + c.Id + ' has ' + candidates.size() + ' candidate questions');

            if (candidates.isEmpty()) continue;

            Integer pickCount = Math.min(3, candidates.size());
            System.debug('Picking ' + pickCount + ' new questions for contact ' + c.Id);

            // Shuffle and select
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
                toInsert.add(qobj);
            }
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
            System.debug('Inserted ' + toInsert.size() + ' new survey questions');
        } else {
            System.debug('No new survey questions to insert');
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch Finish: Updating phsCoachCheckIn__c records');

        List<phsCoachCheckIn__c> toUpdate = [
            SELECT Id, Checkin_required__c
            FROM phsCoachCheckIn__c
            WHERE Checkin_required__c = false
        ];
        System.debug('Found ' + toUpdate.size() + ' check-ins to flip back to required');

        if (!toUpdate.isEmpty()) {
            for (phsCoachCheckIn__c rec : toUpdate) {
                rec.Checkin_required__c = true;
            }
            update toUpdate;
            System.debug('Updated ' + toUpdate.size() + ' check-ins to required');
        }
    }
}