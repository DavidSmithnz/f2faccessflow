@IsTest
public class phsUtilityControllerTest {
    
    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'UtilTest Account');
        insert acc;

        // Manager contact
        Contact manager = new Contact(
            LastName = 'Manager',
            AccountId = acc.Id
        );
        insert manager;

        // Child contact with ReportsToId set
        Contact subordinate = new Contact(
            LastName = 'Subordinate',
            AccountId = acc.Id,
            ReportsToId = manager.Id
        );
        insert subordinate;
    }
    
    @IsTest
    static void testEncryptDecrypt() {
        phsUtilityController util = new phsUtilityController();
        String original = 'MySecretText';
        
        String encrypted = util.encrypt(original);
        System.assertNotEquals(original, encrypted, 'Encrypted value should differ from original');
        
        String decrypted = util.decrypt(encrypted);
        System.assertEquals(original, decrypted, 'Decrypted value should match original');
    }
    
    @IsTest
    static void testGetContactIdAndReportId_HappyPath() {
        phsUtilityController util = new phsUtilityController();

        // Because Test.isRunningTest(), getContactId() should return first Contact inserted
        String contactId = util.getContactId();
        System.assertNotEquals(null, contactId, 'Expected non-null ContactId from test data');

        // Get ReportsToId branch
        String reportId = util.getReportId();
        System.assertEquals(null, reportId, 'Expected ReportsToId to be null');
    }
    
    @IsTest
    static void testGetContactIdAndReportId_NoContacts() {
        phsUtilityController util = new phsUtilityController();

        // Delete all contacts to hit null branch
        delete [SELECT Id FROM Contact];

        String contactId = util.getContactId();
        System.assertEquals(null, contactId, 'Should return null when no contacts exist');

        Boolean exceptionThrown = false;
        try {
            util.getReportId(); // should fail due to null contactId
        } catch (Exception e) {
            exceptionThrown = true;
        }
        System.assertEquals(true, exceptionThrown, 
            'Expected exception when calling getReportId with null contactId');
    }
    
    @IsTest
    static void testThrowUserException() {
        phsUtilityController util = new phsUtilityController();
        CalloutException ex = util.throwUserException('401', 'Unauthorized');
        
        System.assertNotEquals(null, ex, 'Exception should not be null');
        System.assert(ex.getMessage().contains('ErrorCode : 401'), 'Should contain error code');
        System.assert(ex.getMessage().contains('Unauthorized'), 'Should contain error description');
    }

    @IsTest
    static void testDecryptInvalidInput() {
        phsUtilityController util = new phsUtilityController();
        Boolean exceptionThrown = false;
        try {
            util.decrypt('NotAValidBase64String'); // should fail
        } catch (Exception e) {
            exceptionThrown = true;
        }
        System.assertEquals(true, exceptionThrown, 'Decrypt should throw on invalid input');
    }

    @IsTest
    static void testErrorInfoCoverage() {
        phsUtilityController.errorInfo info = new phsUtilityController.errorInfo();
        info.errorCode = '500';
        info.errorDesc = 'Server Error';
        System.assertEquals('500', info.errorCode);
        System.assertEquals('Server Error', info.errorDesc);
    }
}