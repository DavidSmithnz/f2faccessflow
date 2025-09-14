@IsTest
public class phsBatchWellnessUserQSyncSchedulerTest {

    @IsTest
    static void testSchedulerRunsBatch() {
        // Create minimal data so batch has something to process
        Account acc = new Account(Name = 'Sched Test Account');
        insert acc;

        Contact con = new Contact(
            LastName = 'SchedUser',
            FirstName = 'Test',
            Email = 'scheduser@example.com',
            AccountId = acc.Id,
            App_Role__c = 'Team Manager'
        );
        insert con;

        Survey__c survey = new Survey__c();
        insert survey;

        Survey_Question__c sq = new Survey_Question__c(
            Question__c = 'Sample Q',
            Grouping__c = 'General',
            Category__c = 'People',
            Survey__c = survey.Id
        );
        insert sq;

        Test.startTest();
        // Schedule the job to run once
        String jobId = System.schedule(
            'Test Wellness Scheduler',
            '0 0 0 ? * MON', // runs Monday at midnight (test uses immediate execution)
            new phsBatchWellnessUserQSyncScheduler()
        );
        Test.stopTest();

        // Validate that the scheduled job exists
        CronTrigger ct = [
            SELECT Id, CronJobDetail.Name, State
            FROM CronTrigger
            WHERE Id = :jobId
            LIMIT 1
        ];

        System.assertEquals('Test Wellness Scheduler', ct.CronJobDetail.Name, 'Job name should match');
        System.assertEquals('WAITING', ct.State, 'Scheduled job should be waiting or queued');
    }
}