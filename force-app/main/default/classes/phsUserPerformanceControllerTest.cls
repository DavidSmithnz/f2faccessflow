@IsTest
public class phsUserPerformanceControllerTest {

    @testSetup
    static void setupData() {
        // Create Account + Contact
        Account acc = new Account(Name = 'Perf Test Account');
        insert acc;

        Contact con = new Contact(
            LastName = 'PerfUser',
            FirstName = 'Test',
            Email = 'perfuser@example.com',
            AccountId = acc.Id,
            App_Role__c = 'Team Manager'
        );
        insert con;

        // Create initial performance record
        phsUGPerformance__c perf = new phsUGPerformance__c(
            UserId__c = con.Id,
            StressLevel__c = 2,
            TimeInFlowState__c = 3,
            FocusQuality__c = 4,
            SuccessStories__c = 'Initial story',
            ChallengesFaced__c = 'Initial challenge'
        );
        insert perf;
    }

    @IsTest
    static void testGetUserPerformanceDetails() {
        Test.startTest();
        String resp = phsUserPerformanceController.getUserPerformanceDetails();
        Test.stopTest();

        System.assertNotEquals(null, resp, 'Response should not be null');
        System.assert(resp.contains('successStories'), 'Should include success stories');
        System.assert(resp.contains('challengesFaced'), 'Should include challenges');
        System.assert(resp.contains('appRole'), 'Should include App_Role__c');
    }

    @IsTest
    static void testGetMyUserPerformanceDetails() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        String resp = phsUserPerformanceController.getMyUserPerformanceDetails(c.Id);
        Test.stopTest();

        System.assert(resp.contains('stressLevel'), 'JSON should contain stress Level');
    }

    @IsTest
    static void testUpdatePerformance() {
        phsUGPerformance__c perf = [SELECT Id FROM phsUGPerformance__c LIMIT 1];

        Test.startTest();
        String resp = phsUserPerformanceController.updatePerformance(
            perf.Id,
            5, // stressLevel
            4, // focusQuality
            6, // timeInFlowState
            'New challenge',
            'New success'
        );
        Test.stopTest();

        System.assert(resp.contains('Updated'), 'Should return Updated message');

        phsUGPerformance__c updated = [
            SELECT StressLevel__c, FocusQuality__c, TimeInFlowState__c,
                   ChallengesFaced__c, SuccessStories__c
            FROM phsUGPerformance__c
            WHERE Id = :perf.Id
        ];
        System.assertEquals(5, updated.StressLevel__c);
        System.assertEquals(4, updated.FocusQuality__c);
        System.assertEquals(6, updated.TimeInFlowState__c);
        System.assertEquals('New challenge', updated.ChallengesFaced__c);
        System.assertEquals('New success', updated.SuccessStories__c);
    }
}