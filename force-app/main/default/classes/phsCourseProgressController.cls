public with sharing class phsCourseProgressController {

    public class ProgressWrapper {
        @AuraEnabled public Id moduleId;
        @AuraEnabled public Decimal lastWatchedTime;
        @AuraEnabled public Decimal watchPercentage;
        @AuraEnabled public Boolean isCompleted;

        public ProgressWrapper(Id modId, Decimal lastWatchedTime, Decimal percent, Boolean done) {
            moduleId = modId;
            this.lastWatchedTime = lastWatchedTime;
            watchPercentage = percent;
            isCompleted = done;
        }
    }

    @AuraEnabled
    public static void saveVideoProgress(Id moduleId, Decimal secondsWatched, Decimal totalDuration) {
        if (String.isBlank(moduleId) || totalDuration <= 0) return;

        phsUtilityController util = new phsUtilityController();
        Id userId = util.getContactId();

        List<phsCourseProgress__c> existing = [
            SELECT Id, LastWatchedTime__c, WatchPercentage__c, IsCompleted__c
            FROM phsCourseProgress__c
            WHERE Contact__c = :userId AND CourseModule__c = :moduleId
            LIMIT 1
        ];

        Decimal percentage = (secondsWatched / totalDuration) * 100;
        Boolean completed = percentage >= 95;

        if (existing.isEmpty()) {
            phsCourseProgress__c progress = new phsCourseProgress__c();
            progress.Contact__c = userId;
            progress.CourseModule__c = moduleId;
            progress.LastWatchedTime__c = secondsWatched;
            progress.WatchPercentage__c = percentage;
            progress.IsCompleted__c = completed;
            insert progress;
        } else {
            phsCourseProgress__c progress = existing[0];
            progress.LastWatchedTime__c = secondsWatched;
            progress.WatchPercentage__c = percentage;
            progress.IsCompleted__c = completed;
            update progress;
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<ProgressWrapper> getVideoProgress() {
        phsUtilityController util = new phsUtilityController();
        Id userId = util.getContactId();

        List<ProgressWrapper> results = new List<ProgressWrapper>();

        for (phsCourseProgress__c p : [
            SELECT CourseModule__c, LastWatchedTime__c, WatchPercentage__c, IsCompleted__c
            FROM phsCourseProgress__c
            WHERE Contact__c = :userId
        ]) {
            results.add(new ProgressWrapper(
                p.CourseModule__c,
                p.LastWatchedTime__c,
                p.WatchPercentage__c,
                p.IsCompleted__c
            ));
        }

        return results;
    }
}