global with sharing class phsBatchWellnessUserQSyncScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Run batch with scope size 200
        phsBatchWellnessUserQuestionSync batch = new phsBatchWellnessUserQuestionSync();
        Database.executeBatch(batch, 200);
    }
}