public with sharing class phsCourseController {
    @AuraEnabled(cacheable=true)
    public static List<CourseWrapper> getCoursesWithModules() {
        List<phsCourses__c> courses = [
            SELECT Id, Name, Description__c, DisplayOrder__c,
                (SELECT Id, Name, Description__c, Duration__c, ModulePart__c, CreatedDate, Views__c
                 FROM phsCourseModules__r
                 ORDER BY ModulePart__c ASC)
            FROM phsCourses__c
            ORDER BY DisplayOrder__c ASC
        ];

        // Collect all module IDs to query their file links
        Set<Id> moduleIds = new Set<Id>();
        for (phsCourses__c course : courses) {
            for (phsCourseModule__c mod : course.phsCourseModules__r) {
                moduleIds.add(mod.Id);
            }
        }

        // Query ContentDocumentLink for all modules
        Map<Id, String> moduleIdToVideoUrl = new Map<Id, String>();
        if (!moduleIds.isEmpty()) {
            List<ContentDocumentLink> links = [
                SELECT ContentDocument.LatestPublishedVersionId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :moduleIds
            ];

            for (ContentDocumentLink link : links) {
                if (!moduleIdToVideoUrl.containsKey(link.LinkedEntityId)) {
                    // ✅ Return a RELATIVE shepherd path (no site/host hardcoding)
                   String prefix = Site.getPathPrefix();
                    if (prefix == null) prefix = ''; // safe default for non-site contexts

                    String videoUrl = prefix + '/sfc/servlet.shepherd/version/download/' +
                  link.ContentDocument.LatestPublishedVersionId;moduleIdToVideoUrl.put(link.LinkedEntityId, videoUrl);
                }
            }
        }

        // Wrap the data
        List<CourseWrapper> results = new List<CourseWrapper>();
        for (phsCourses__c course : courses) {
            List<ModuleWrapper> moduleList = new List<ModuleWrapper>();
            for (phsCourseModule__c mod : course.phsCourseModules__r) {
                String videoUrl = moduleIdToVideoUrl.containsKey(mod.Id) ? moduleIdToVideoUrl.get(mod.Id) : '';
                moduleList.add(new ModuleWrapper(mod, videoUrl));
            }
            results.add(new CourseWrapper(course.Id, course.Name, course.Description__c, course.DisplayOrder__c, moduleList));
        }
        return results;
    }

    public class CourseWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public List<ModuleWrapper> modules;
        @AuraEnabled public Decimal displayOrder;

        public CourseWrapper(Id id, String name, String description, Decimal displayOrder, List<ModuleWrapper> modules) {
            this.id = id;
            this.name = name;
            this.description = description;
            this.modules = modules;
            this.displayOrder = displayOrder;            
        }
    }

    public class ModuleWrapper {
        @AuraEnabled public Id id; 
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String duration;
        @AuraEnabled public String videoUrl;
        @AuraEnabled public Decimal modulePart;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Integer views;

        public ModuleWrapper(phsCourseModule__c mod, String videoUrl) {
            this.id = mod.Id;
            this.name = mod.Name;
            this.duration = mod.Duration__c;
            this.videoUrl = videoUrl;
            this.description = mod.Description__c;
            this.modulePart = mod.ModulePart__c;
            this.createdDate = mod.CreatedDate;
            this.views = (mod.Views__c == null ? 0 : Integer.valueOf(mod.Views__c));
        }
    }

    @AuraEnabled
    public static void saveRating(Id moduleId, Integer ratingValue) {
        phsUtilityController util = new phsUtilityController(); 
        Id currentUserId = util.getContactId();

        List<phsCourseModuleRating__c> existing = [
            SELECT Id FROM phsCourseModuleRating__c
            WHERE Contact__c = :currentUserId AND phsCourseModule__c = :moduleId
            LIMIT 1
        ];

        if (existing.isEmpty()) {
            phsCourseModuleRating__c rating = new phsCourseModuleRating__c();
            rating.phsCourseModule__c = moduleId;
            rating.Contact__c = currentUserId;
            rating.Rating__c = ratingValue;
            insert rating;
        } else {
            phsCourseModuleRating__c existingRating = existing[0];
            existingRating.Rating__c = ratingValue;
            update existingRating;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, Integer> getUserRatings() {
        phsUtilityController util = new phsUtilityController(); 
        Id userId = util.getContactId();

        Map<Id, Integer> result = new Map<Id, Integer>();

        for (phsCourseModuleRating__c rating : [
            SELECT phsCourseModule__c, Rating__c
            FROM phsCourseModuleRating__c
            WHERE Contact__c = :userId
        ]) {
            result.put(rating.phsCourseModule__c, Integer.valueOf(rating.Rating__c));
        }

        return result;
    }

    @AuraEnabled
    public static void incrementViewCount(Id moduleId) {
        if (String.isNotBlank(moduleId)) {
            List<phsCourseModule__c> modules = [
                SELECT Id, Views__c
                FROM phsCourseModule__c
                WHERE Id = :moduleId
                LIMIT 1
                FOR UPDATE
            ];

            if (!modules.isEmpty()) {
                phsCourseModule__c mod = modules[0];
                mod.Views__c = (mod.Views__c == null ? 1 : mod.Views__c + 1);
                update mod;
            }
        }
    }
}