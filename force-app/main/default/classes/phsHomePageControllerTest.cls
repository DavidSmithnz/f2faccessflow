@IsTest
public class phsHomePageControllerTest {
    
    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact con = new Contact(
            LastName = 'Tester',
            FirstName = 'Survey',
            AccountId = acc.Id
        );
        insert con;

        
        // Survey with Decimal fields
        Survey__c survey = new Survey__c(
            PDFID__c = 'http://example.com/pdf',
            people__c = 5.0,
            culture__c = 4.0,
            process__c = 3.0,
            technology__c = 2.0,
            analytics__c = 1.0,
            Contact__c = con.Id
        );
        insert survey;
        
        con.Most_Recent_Survey__c = survey.Id;
        update con;
        
        // Slideshow
        phsHomeSlideShow__c slide = new phsHomeSlideShow__c(
            Active__c = true,
            Desktop_Image__c = '<img src="desktop.png">',
            Mobile_Image__c = '<img src="mobile.png">',
            Image_Sequence__c = '1'
        );
        insert slide;
        
        // Tips
        insert new List<phsTips__c>{
            new phsTips__c(Description__c = 'Tip number one'),
            new phsTips__c(Description__c = 'Tip number two')
        };
    }
    
    @IsTest
    static void testGetSurveyDetails_WithSurvey() {
        String resp = phsHomePageController.getSurveyDetails();
        System.assert(resp.contains('http://example.com/pdf'), 'Should include PDF link');
        System.assert(resp.contains('Tester'), 'Should include Contact LastName');
    }
    
    @IsTest
    static void testGetSurveyDetails_NoSurvey() {
        // Remove survey link
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        c.Most_Recent_Survey__c = null;
        update c;
        
        String resp = phsHomePageController.getSurveyDetails();
        System.assertNotEquals(null, resp, 'Should return JSON even without survey');
    }
    
    @IsTest
    static void testGetSurveyDetails_NoPdf() {
        // Create a Survey with blank PDFID
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Survey__c survey = new Survey__c(
            people__c = 1.0,
            culture__c = 1.0,
            process__c = 1.0,
            technology__c = 1.0,
            analytics__c = 1.0,
            Contact__c = c.Id
        );
        insert survey;
        
        c.Most_Recent_Survey__c = survey.Id;
        update c;
        
        String resp = phsHomePageController.getSurveyDetails();
        System.assert(resp.contains('peopleScore'), 'Should include people score in JSON');
    }
    
    @IsTest
    static void testGetSlideShowDetails() {
        List<phsHomeSlideShow__c> slides = phsHomePageController.getSlideShowDetails();
        System.assertEquals(1, slides.size(), 'Should return 1 slide');
        System.assert(slides[0].Desktop_Image__c.contains('class="card-image"'));
        System.assert(slides[0].Mobile_Image__c.contains('class="card-image"'));
    }
    
    @IsTest
    static void testGetTipOfTheDay_Fallback() {
        String tip = phsHomePageController.getTipOfTheDay();
        System.assertNotEquals(null, tip, 'Tip should not be null');
        System.assert(
            tip.contains('Tip number one') || tip.contains('Tip number two'),
            'Tip should match fallback records'+tip
        );
    }
}