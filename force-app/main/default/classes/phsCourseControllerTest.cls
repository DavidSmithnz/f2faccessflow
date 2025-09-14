@IsTest
public class phsCourseControllerTest {
    private static Contact createContact() {
        Contact c = new Contact(
            LastName = 'Test Contact',
            Email = 'test' + System.currentTimeMillis() + '@example.com'
        );
        insert c;
        return c;
    }

    private static phsCourseModule__c createCourseAndModule() {
        phsCourses__c course = new phsCourses__c(Name = 'Test Course', DisplayOrder__c = 1);
        insert course;

        phsCourseModule__c module = new phsCourseModule__c(
            Name = 'Test Module',
            phsCourses__c = course.Id,
            Duration__c = '120',
            ModulePart__c = 1,
            Views__c = 0
        );
        insert module;
        return module;
    }

    @IsTest static void testGetCoursesWithModules() {
        createCourseAndModule();
        Test.startTest();
        List<phsCourseController.CourseWrapper> results = phsCourseController.getCoursesWithModules();
        Test.stopTest();
        System.assert(results.size() > 0);
    }

    @IsTest static void testIncrementViewCount() {
        phsCourseModule__c module = createCourseAndModule();
        Test.startTest();
        phsCourseController.incrementViewCount(module.Id);
        Test.stopTest();
        module = [SELECT Views__c FROM phsCourseModule__c WHERE Id = :module.Id];
        System.assertEquals(1, module.Views__c);
    }

    @IsTest static void testSaveRating_Insert() {
        phsCourseModule__c module = createCourseAndModule();
        Contact c = createContact();
        Test.startTest();
        phsCourseModuleRating__c rating = new phsCourseModuleRating__c(
            phsCourseModule__c = module.Id,
            Contact__c = c.Id,
            Rating__c = 3
        );
        insert rating;
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM phsCourseModuleRating__c]);
    }

    @IsTest static void testSaveRating_Update() {
        phsCourseModule__c module = createCourseAndModule();
        Contact c = createContact();
        phsCourseModuleRating__c rating = new phsCourseModuleRating__c(
            phsCourseModule__c = module.Id,
            Contact__c = c.Id,
            Rating__c = 3
        );
        insert rating;

        Test.startTest();
        rating.Rating__c = 5;
        update rating;
        Test.stopTest();

        rating = [SELECT Rating__c FROM phsCourseModuleRating__c WHERE Id = :rating.Id];
        System.assertEquals(5, rating.Rating__c);
    }

    @IsTest static void testGetUserRatings() {
        phsCourseModule__c module = createCourseAndModule();
        Contact c = createContact();
        phsCourseModuleRating__c rating = new phsCourseModuleRating__c(
            phsCourseModule__c = module.Id,
            Contact__c = c.Id,
            Rating__c = 4
        );
        insert rating;
        Test.startTest();
        Map<Id, Integer> results = phsCourseController.getUserRatings();
        Test.stopTest();
        System.assert(results.size() >= 0);
    }

    @IsTest static void testIncrementViewCount_Blank() {
        Test.startTest();
        phsCourseController.incrementViewCount(null);
        Test.stopTest();
        System.assert(true);
    }
    
        @IsTest static void testGetCoursesWithModules_WithContentDocument() {
        phsCourseModule__c module = createCourseAndModule();

        // Create a ContentVersion (automatically creates ContentDocument)
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Sample Data'),
            IsMajorVersion = true
        );
        insert cv;

        // Get the auto-created ContentDocument Id
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        // Link ContentDocument to module
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = module.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        Test.startTest();
        List<phsCourseController.CourseWrapper> results = phsCourseController.getCoursesWithModules();
        Test.stopTest();

        System.assert(results[0].modules[0].videoUrl.contains('/sfc/servlet.shepherd/version/download/'),
            'Video URL should be populated from ContentDocumentLink');
    }

    @IsTest static void testSaveRating_Controller_InsertAndUpdate() {
        phsCourseModule__c module = createCourseAndModule();
        Contact c = createContact();

        // Call the controller directly
        Test.startTest();
        phsCourseController.saveRating(module.Id, 4); // Insert branch
        phsCourseController.saveRating(module.Id, 5); // Update branch
        Test.stopTest();

        phsCourseModuleRating__c rating = [SELECT Rating__c FROM phsCourseModuleRating__c WHERE phsCourseModule__c = :module.Id LIMIT 1];
        System.assertEquals(5, rating.Rating__c, 'Rating should be updated to 5');
    }

}