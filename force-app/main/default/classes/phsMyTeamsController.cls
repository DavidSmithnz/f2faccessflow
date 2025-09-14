public without sharing  class phsMyTeamsController {
    
    
    @AuraEnabled() 
    public static string getMyTeamList() {
        try
        {
            phsUtilityController utility=new phsUtilityController();
            String userId=utility.getContactId();
            
            List<Contact> clist=new List<Contact>();
            List<myTeam> myteamlist=new List<myTeam>();
            clist=[SELECT Id , Title , Name FROM Contact where ReportsToId  =: userId ];
            
            for(Contact c : clist)
            {
                myTeam mt=new myTeam();
                mt.Id=c.Id;
                mt.Title=c.Title;
                mt.Name=c.Name;
                List<phsUGPerformance__c> uglist=new List<phsUGPerformance__c>();
                
                uglist=[Select Id, TimeInFlowState__c, StressLevel__c, FocusQuality__c  from phsUGPerformance__c where  UserId__c =: mt.Id];
                for(phsUGPerformance__c u :uglist )
                {
                    
                    mt.StressLevel=u.StressLevel__c;
                    mt.FocusQuality=u.FocusQuality__c;
                    mt.TimeInFlowState=u.TimeInFlowState__c;
                }
                myteamlist.add(mt);
            }
            String jsonResponse = JSON.serialize(myteamlist);
            return jsonResponse;
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred: ' + e.getMessage()); 
            String jsonResponse = JSON.serialize(e.getMessage());
            return jsonResponse;
        }
    }
    
    public class myTeam
    {
        public String Id;
        public STring Title;
        public String Name;
        public double StressLevel=0;
        public double FocusQuality=0;
        public double TimeInFlowState=0;
        
    }
    
}