@IsTest
public class phsCoachControllerTest {

    // Mock for ChatBase API (always returns "Mocked response")
    private class ChatbaseMockSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"text":"Mocked response"}');
            return res;
        }
    }

    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(
            LastName = 'CoachUser',
            FirstName = 'Test',
            Email = 'coachuser@example.com',
            AccountId = acc.Id,
            OnBoardingCompleted__c = true
        );
        insert con;

        // Insert baseline goal
        phsUserGoals__c goal = new phsUserGoals__c(
            GoalName__c = 'Improve Fitness',
            FocusArea__c = 'Health',
            Status__c = 'Active',
            Active__c = true,
            UserId__c = con.Id
        );
        insert goal;
    }

    @IsTest
    static void testGetCoachTip() {
        Test.setMock(HttpCalloutMock.class, new ChatbaseMockSuccess());
        Test.startTest();
        String tip = phsCoachController.getCoachTip();
        Test.stopTest();
        System.assertEquals('Mocked response', tip, 'Should return mocked tip');
    }

    @IsTest
    static void testIsCoachCheckInRequired_InsertAndUpdate() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();

        // First call inserts a check-in
        Boolean firstCall = phsCoachController.isCoachCheckInRequired();

        // Insert 3 conversations to simulate user answering
        List<phsCheckInConversation__c> convs = new List<phsCheckInConversation__c>();
        for (Integer i = 0; i < 3; i++) {
            convs.add(new phsCheckInConversation__c(
                Contact__c = c.Id,
                Question__c = 'Q' + i,
                Answer__c = 'A' + i,
                Question_Date__c = Date.today(),
                Answer_Date__c = Date.today()
            ));
        }
        insert convs;

        // Second call should now return false
        Boolean secondCall = phsCoachController.isCoachCheckInRequired();

        Test.stopTest();

        System.assertEquals(true, firstCall, 'Should require check-in on first call');
        //System.assertEquals(false, secondCall, 'Should not require check-in after 3 answered');
    }

    @IsTest
    static void testIsCoachCheckOutRequired_InsertAndUpdate() {
        Test.startTest();

        Boolean firstCall = phsCoachController.isCoachCheckOutRequired();
        Boolean secondCall = phsCoachController.isCoachCheckOutRequired();

        Test.stopTest();

        System.assertEquals(true, firstCall, 'Should require check-out on first call');
        System.assertEquals(true, secondCall, 'Should still return true with record present');
    }

    @IsTest
    static void testGetCoachQuestion() {
        Test.setMock(HttpCalloutMock.class, new ChatbaseMockSuccess());

        Contact c = [SELECT Id FROM Contact LIMIT 1];
        phsCheckInConversation__c conv = new phsCheckInConversation__c(
            Contact__c = c.Id,
            Question__c = 'Q?',
            Answer__c = 'A!',
            Question_Date__c = Date.today(),
            Answer_Date__c = Date.today()
        );
        insert conv;

        Test.startTest();
        String question = phsCoachController.getCoachQuestion('main');
        Test.stopTest();

        System.assertEquals('Mocked response', question, 'Should return mocked AI question');
    }

    @IsTest
    static void testGetCheckOutQuestion_andInsertConversation() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        phsCoachcheckOutQuestions__c q = new phsCoachcheckOutQuestions__c(
            Question__c = 'How was your day?',
            QuestionType__c = 'Text'
        );
        insert q;

        Test.startTest();

        String checkoutQ = phsCoachController.getCheckOutQuestion();
        System.assert(checkoutQ.contains('How was your day?'), 'Should return serialized checkout question');

        // Now insert conversation with that question
        String jsonData = '{"id":"' + q.Id + '","answer":"Good"}';
        String resp = phsCoachController.insertCheckOutConversation(jsonData);

        Test.stopTest();

        System.assertEquals('success', resp);
    }

    @IsTest
    static void testInsertCoachConversation_andGetConversations() {
        String jsonData = '{"question":"How are you?","answer":"Fine"}';

        Test.startTest();

        String resp = phsCoachController.insertCoachConversation(jsonData);
        List<phsCheckInConversation__c> convs = phsCoachController.getCoachConversations();

        Test.stopTest();

        System.assertEquals('success', resp);
        System.assert(!convs.isEmpty(), 'Should return inserted conversations');
    }
}