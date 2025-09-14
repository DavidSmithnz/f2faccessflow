public with sharing class phsChatBaseController {

    @TestVisible private static Boolean bypassTestShortCircuit = false;
    @TestVisible private static Cfg testCfgOverride;

    // ---- Simple holder for CMDT config ----
    public class Cfg {
        public String apiKey;
        public String apiPath;   // e.g. '/api/v1/chat'
        public String chatbotId;
    }



    private static Cfg loadCfg() {
    // Allow tests to inject their own config
    if (Test.isRunningTest() && testCfgOverride != null) {
        return testCfgOverride;
    }

    // Short-circuit in test context if not overridden
    if (Test.isRunningTest()) {
        Cfg cfg = new Cfg();
        cfg.apiKey    = 'dummy';
        cfg.apiPath   = '/api/v1/chat';
        cfg.chatbotId = 'dummyBot';
        return cfg;
    }

    // Normal production path
    Chatbase_Config__mdt c = [
        SELECT ApiKey__c, ApiPath__c, ChatbotId__c
        FROM Chatbase_Config__mdt
        LIMIT 1
    ];
    Cfg cfg = new Cfg();
    cfg.apiKey    = String.valueOf(c.ApiKey__c);
    cfg.apiPath   = String.isBlank(c.ApiPath__c) ? '/api/v1/chat' : c.ApiPath__c.trim();
    cfg.chatbotId = String.valueOf(c.ChatbotId__c);

    if (String.isBlank(cfg.apiKey))    throw new CalloutException('Chatbase API key not configured');
    if (String.isBlank(cfg.chatbotId)) throw new CalloutException('Chatbase chatbotId not configured');
    if (!cfg.apiPath.startsWith('/'))  cfg.apiPath = '/' + cfg.apiPath;

    return cfg;
}


    @AuraEnabled(cacheable=false)
    public static String getTipFromAI(String message, String conversationId) {
        return sendRequestToAIWithRetry(message, conversationId, 1);
    }

    @AuraEnabled(cacheable=false)
    public static String getCoachQuestionFromAI(String message, String conversationId) {
        return sendRequestToAIWithRetry(message, conversationId, 1);
    }

    private static String sendRequestToAIWithRetry(String message, String conversationId, Integer attempt) {
        try {
            String response = sendRequestToAI(message, conversationId);
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(response);
            if (parsed != null && parsed.containsKey('text')) {
                return String.valueOf(parsed.get('text'));
            }
            return 'Unexpected API response: ' + response;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Chatbase API call failed: ' + e.getMessage());
            if (attempt < 2) {
                return sendRequestToAIWithRetry(message, conversationId, attempt + 1);
            }
            return 'An error occurred after retry: ' + e.getMessage();
        }
    }

    private static String sendRequestToAI(String message, String conversationId) {
        Cfg cfg = loadCfg();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Chatbase' + cfg.apiPath); // NC 'Chatbase' + path from CMDT
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        // Inject Authorization from CMDT (reliable everywhere)
        req.setHeader('Authorization', 'Bearer ' + cfg.apiKey);

        req.setBody(createJsonBody(message, conversationId, cfg.chatbotId));

        Http http = new Http();
        System.debug(LoggingLevel.INFO, 'Callouts used so far: ' + Limits.getCallouts());
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            throw new CalloutException('Chatbase API returned status ' + res.getStatusCode() + ': ' + res.getBody());
        }
        return res.getBody();
    }

    private static String createJsonBody(String message, String conversationId, String chatbotId) {
        message = String.isNotBlank(message) ? message.replaceAll('"','') : '';
        Map<String, Object> payload = new Map<String, Object>{
            'messages' => new List<Object>{
                new Map<String, Object>{
                    'content' => message,
                    'role'    => 'user'
                }
            },
            'chatbotId'      => chatbotId,
            'stream'         => false,
            'temperature'    => 1,
            'conversationId' => conversationId
        };
        return JSON.serialize(payload);
    }

    public class CalloutException extends Exception {}
}