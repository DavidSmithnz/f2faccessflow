@IsTest
public class phsBatchWellnessUserQuestionSyncTest {

    @testSetup
    static void setupData() {
        // Create Account + Contact with App_Role__c (required for batch scope)
        Account acc = new Account(Name = 'Batch Test Account');
        insert acc;

        Contact con = new Contact(
            LastName = 'BatchUser',
            FirstName = 'Test',
            Email = 'batchuser@example.com',
            AccountId = acc.Id,
            App_Role__c = 'Team Manager'
        );
        insert con;

        // ⚡ Fix: Create a Survey record because Survey__c is required
        Survey__c survey = new Survey__c();
        insert survey;

        // Create Survey Questions (for assignment) linked to Survey__c
        List<Survey_Question__c> surveyQuestions = new List<Survey_Question__c>();
        for (Integer i = 0; i < 5; i++) {
            surveyQuestions.add(new Survey_Question__c(
                Question__c = 'Question ' + i,
                Grouping__c = 'Group ' + i,
                Category__c = 'People',
                Survey__c = survey.Id   // ✅ required field fixed
            ));
        }
        insert surveyQuestions;

        // Create phsUserSurveyQuestions__c unanswered for deletion
        phsUserSurveyQuestions__c unanswered = new phsUserSurveyQuestions__c(
            User__c = con.Id,
            SurveyQuestionId__c = surveyQuestions[0].Id,
            Question__c = surveyQuestions[0].Question__c,
            Grouping__c = surveyQuestions[0].Grouping__c,
            Category__c = surveyQuestions[0].Category__c,
            IsActive__c = true
        );
        insert unanswered;

        // Create phsUserSurveyQuestions__c answered for update
        phsUserSurveyQuestions__c answered = new phsUserSurveyQuestions__c(
            User__c = con.Id,
            SurveyQuestionId__c = surveyQuestions[1].Id,
            Question__c = surveyQuestions[1].Question__c,
            Grouping__c = surveyQuestions[1].Grouping__c,
            Category__c = surveyQuestions[1].Category__c,
            IsActive__c = true,
            UserAnswer__c = 'Yes'
        );
        insert answered;

        // Create a phsCoachCheckIn__c with Checkin_required__c = false (for finish)
        phsCoachCheckIn__c checkIn = new phsCoachCheckIn__c(
            Contact__c = con.Id,
            Checkin_required__c = false,
            Last_checkin_date__c = System.now()
        );
        insert checkIn;
    }

    @IsTest
    static void testBatchExecution() {
        Test.startTest();
        phsBatchWellnessUserQuestionSync batch = new phsBatchWellnessUserQuestionSync();
        Database.executeBatch(batch, 50);
        Test.stopTest();

        // Assert answered question updated to inactive
        phsUserSurveyQuestions__c ans = [
            SELECT IsActive__c FROM phsUserSurveyQuestions__c
            WHERE UserAnswer__c != null
            LIMIT 1
        ];
        System.assertEquals(false, ans.IsActive__c, 'Answered question should be inactive');

        // Assert new questions inserted
        Integer newQCount = [
            SELECT COUNT() FROM phsUserSurveyQuestions__c
            WHERE UserAnswer__c = null
        ];
        System.assert(newQCount > 0, 'Should insert new survey questions');

        // Assert phsCoachCheckIn__c updated
        phsCoachCheckIn__c checkIn = [
            SELECT Checkin_required__c FROM phsCoachCheckIn__c LIMIT 1
        ];
        System.assertEquals(true, checkIn.Checkin_required__c, 'Checkin_required__c should be set to true');
    }
}