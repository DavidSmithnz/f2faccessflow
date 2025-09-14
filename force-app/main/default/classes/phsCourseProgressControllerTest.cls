@IsTest
public class phsCourseProgressControllerTest {
    private static phsCourseModule__c createCourseAndModule() {
        phsCourses__c course = new phsCourses__c(Name = 'Progress Course', DisplayOrder__c = 1);
        insert course;

        phsCourseModule__c module = new phsCourseModule__c(
            Name = 'Progress Module',
            phsCourses__c = course.Id,
            Duration__c = '200',
            ModulePart__c = 1
        );
        insert module;
        return module;
    }

    @IsTest static void testSaveVideoProgress_Insert() {
        phsCourseModule__c module = createCourseAndModule();

        Test.startTest();
        phsCourseProgressController.saveVideoProgress(module.Id, 100, 200);
        Test.stopTest();

        List<phsCourseProgress__c> progresses = [SELECT WatchPercentage__c, IsCompleted__c FROM phsCourseProgress__c WHERE CourseModule__c = :module.Id];
        System.assertEquals(50, progresses[0].WatchPercentage__c);
        System.assertEquals(false, progresses[0].IsCompleted__c);
    }

    @IsTest static void testSaveVideoProgress_UpdateToComplete() {
        phsCourseModule__c module = createCourseAndModule();

        // Insert first
        phsCourseProgressController.saveVideoProgress(module.Id, 100, 200);

        // Update to 95%+
        Test.startTest();
        phsCourseProgressController.saveVideoProgress(module.Id, 195, 200);
        Test.stopTest();

        phsCourseProgress__c updated = [SELECT WatchPercentage__c, IsCompleted__c FROM phsCourseProgress__c WHERE CourseModule__c = :module.Id];
        System.assert(updated.IsCompleted__c, 'Should be marked completed');
    }

    @IsTest static void testSaveVideoProgress_BlankOrZeroDuration() {
    Test.startTest();
    // Case 1: Null moduleId
    phsCourseProgressController.saveVideoProgress(null, 50, 0);

    // Case 2: Valid Id but totalDuration = 0
    phsCourseModule__c module = createCourseAndModule();
    phsCourseProgressController.saveVideoProgress(module.Id, 50, 0);
    Test.stopTest();

    // Verify nothing got created
    System.assertEquals(0, [SELECT COUNT() FROM phsCourseProgress__c], 'No records should be created');
}

    @IsTest static void testGetVideoProgress() {
        phsCourseModule__c module = createCourseAndModule();

        // Create progress
        phsCourseProgressController.saveVideoProgress(module.Id, 100, 200);

        Test.startTest();
        List<phsCourseProgressController.ProgressWrapper> results = phsCourseProgressController.getVideoProgress();
        Test.stopTest();

        System.assert(results.size() > 0, 'Progress should be returned');
        System.assertEquals(module.Id, results[0].moduleId);
    }
}