@IsTest
public class phsHeaderControllerTest {
    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(
            LastName = 'Test',
            FirstName = 'Contact',
            Email = 'test@example.com',
            AccountId = acc.Id,
            OnBoardingCompleted__c = true
        );
        insert con;
    }

    @IsTest
    static void testGetContactDetails_HappyPath() {
        Contact c = [SELECT Id, Email FROM Contact LIMIT 1];

        Test.startTest();
        String jsonResponse = phsHeaderController.getContactDetails();
        Test.stopTest();

        System.assertNotEquals(null, jsonResponse, 'Should return JSON');
        System.assert(jsonResponse.contains(c.Id), 'Should include contact Id');
        System.assert(jsonResponse.contains(c.Email), 'Should include contact email');
        System.assert(jsonResponse.contains('chatBaseHash'), 'Should include hash');
        System.assert(jsonResponse.contains('pendoApiKey'), 'Should include Pendo key');
    }

    @IsTest
    static void testGetContactDetails_NoContact() {
        // Remove all contacts to force empty query
        delete [SELECT Id FROM Contact];

        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            phsHeaderController.getContactDetails();
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = true;
        }
        System.assertEquals(true, exceptionThrown, 'Should throw when no contact found');
    }

    @IsTest
    static void testGetContactDetails_NullSafety() {
        // Utility method will inject dummy secret/key under Test context
        Test.startTest();
        String result = phsHeaderController.getContactDetails();
        Test.stopTest();

        System.assert(result.contains('pendoApiKey'), 'Should contain Pendo API key');
        System.assert(result.contains('chatBaseHash'), 'Should contain hash');
    }
}