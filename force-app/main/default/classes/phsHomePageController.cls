public  class phsHomePageController {

    @AuraEnabled(cacheable=true)
    public static String getSurveyDetails() {
       
        phsUtilityController util = new phsUtilityController();        
        String contactId = util.getContactId();
        List<Contact> recentSurveyContact=[Select Most_Recent_Survey__c,FirstName,LastName  from Contact where Id = : contactId  ];
        SurveyDetails sd = new SurveyDetails();
        if(recentSurveyContact != null && recentSurveyContact.size()>0 && recentSurveyContact[0].Most_Recent_Survey__c!=null )
        {
               List<Survey__c> survey = [select PDFID__c,people__c,culture__c,process__c,technology__c,Analytics__c,contact__r.FirstName, contact__r.LastName from survey__c where Id =: recentSurveyContact[0].Most_Recent_Survey__c];
        
        if(survey[0].PDFID__c != null && survey[0].PDFID__c != ''){ sd.pdfDownloadLink = survey[0].PDFID__c; }
        sd.peopleScore = survey[0].people__c;
        sd.cultureScore = survey[0].culture__c;
        sd.processScore = survey[0].process__c;
        sd.technologyScore = survey[0].technology__c;
        sd.analyticsScore = survey[0].analytics__c;
        }
         sd.firstName = recentSurveyContact[0].FirstName;
        sd.lastName = recentSurveyContact[0].LastName;
     
        
        // Serializing the list of accounts to JSON
        
		String jsonResponse = JSON.serialize(sd);
        return jsonResponse;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<phsHomeSlideShow__c> getSlideShowDetails() {                
        List<phsHomeSlideShow__c> ss = [select id, desktop_image__c, mobile_image__c,Image_Sequence__c from phsHomeSlideShow__c where active__c = true order by Image_Sequence__c]; 
        // Serializing the list of accounts to JSON
        for(phsHomeSlideShow__c s : ss)
        {
            s.desktop_image__c = s.desktop_image__c.replace('<img','<img class="card-image" style="width:100%; min-height: 300px;" ');
            s.mobile_image__c = s.mobile_image__c.replace('<img','<img class="card-image" style="width:100%; min-height: 300px;" ');
        }
        return ss;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getTipOfTheDay() {
        String tip ='';
        try{
            String message = 'give me a new tip in around 20 words. This tip must not be given to me earlier';
            phsUtilityController util = new phsUtilityController();        
            String contactId = util.getContactId();
            phsChatBaseController ctrl = new phsChatBaseController();
            tip = phsChatBaseController.getTipFromAI(message, contactId);
        }
        catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
        
        if(tip == '')
        {   
        //Commented is the logic to get tip from tip object
            phsTips__c[] tipList=[SELECT id, description__c FROM phsTips__c];
            integer theChosenIndex=math.round(math.random()*tipList.size());
            if(theChosenIndex > (tipList.size()-1))
            {
              theChosenIndex  = theChosenIndex -1;
            }   
            tip = tipList[theChosenIndex].description__c;
        }
        return tip;
    }
    
  class SurveyDetails {
      public String pdfDownloadLink;
      public String firstName;
      public String lastName;
      public Decimal cultureScore;
      public Decimal peopleScore;
      public Decimal processScore;
      public Decimal technologyScore;
      public Decimal analyticsScore;
  }
}