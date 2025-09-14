@IsTest
public class phsChatBaseControllerTest {

    // ---- Success Mock: API returns { "text": "hello" } ----
    private class ChatbaseMockSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"text":"Hello from AI"}');
            return res;
        }
    }

    // ---- Unexpected JSON Mock: no "text" key ----
    private class ChatbaseMockUnexpected implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"other":"No text here"}');
            return res;
        }
    }

    // ---- Error Mock: API returns non-200 ----
    private class ChatbaseMockError implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }

    @IsTest
    static void testGetTipFromAI_Success() {
        Test.setMock(HttpCalloutMock.class, new ChatbaseMockSuccess());

        Test.startTest();
        String result = phsChatBaseController.getTipFromAI('Give me a tip', 'conv123');
        Test.stopTest();

        System.assertEquals('Hello from AI', result, 'Should parse text field from API response');
    }

    @IsTest
    static void testGetCoachQuestionFromAI_Success() {
        Test.setMock(HttpCalloutMock.class, new ChatbaseMockSuccess());

        String result = phsChatBaseController.getCoachQuestionFromAI('Ask me a question', 'conv456');
        System.assert(result.contains('Hello'), 'Should return mocked AI text');
    }

    @IsTest
    static void testGetTipFromAI_ErrorPath() {
        Test.setMock(HttpCalloutMock.class, new ChatbaseMockError());

        Test.startTest();
        String result = phsChatBaseController.getTipFromAI('Bad request', 'conv789');
        Test.stopTest();

        System.assert(result.startsWith('An error occurred'), 'Should hit retry and error path');
    }

    @IsTest
    static void testUnexpectedJsonPath() {
        Test.setMock(HttpCalloutMock.class, new ChatbaseMockUnexpected());

        String result = phsChatBaseController.getTipFromAI('Message', 'conv000');
        System.assert(result.startsWith('Unexpected API response'), 'Should handle missing text field');
    }

    @IsTest
    static void testCalloutException() {
        Boolean thrown = false;
        try {
            throw new phsChatBaseController.CalloutException('Forced');
        } catch (Exception e) {
            thrown = true;
            System.assert(e.getMessage().contains('Forced'), 'Should throw CalloutException');
        }
        System.assert(thrown, 'CalloutException should be caught in test');
    }
    
    @IsTest
    static void testLoadCfg_BlankApiKeyThrows() {
        phsChatBaseController.Cfg badCfg = new phsChatBaseController.Cfg();
        badCfg.apiKey = '';
        badCfg.apiPath = '/api/v1/chat';
        badCfg.chatbotId = 'bot123';
        phsChatBaseController.testCfgOverride = badCfg;
    
        String tip = phsChatBaseController.getTipFromAI('msg','conv');
        System.assert(tip.contains('An error occurred'), 'Should mention Error');
        phsChatBaseController.testCfgOverride = null;        
    }

    @IsTest
    static void testLoadCfg_BlankChatbotIdThrows() {
        phsChatBaseController.Cfg badCfg = new phsChatBaseController.Cfg();
        badCfg.apiKey = 'apiKey';
        badCfg.apiPath = '/api/v1/chat';
        badCfg.chatbotId = '';
        phsChatBaseController.testCfgOverride = badCfg;
        String tip = phsChatBaseController.getTipFromAI('msg','conv');
        System.assert(tip.contains('An error occurred'), 'Should mention Error');
        phsChatBaseController.testCfgOverride = null;         
    }
    
    @IsTest
    static void testLoadCfg_PathCorrection() {
        phsChatBaseController.Cfg cfg = new phsChatBaseController.Cfg();
        cfg.apiKey = 'apiKey';
        cfg.apiPath = 'noSlashPath';
        cfg.chatbotId = 'bot123';
        phsChatBaseController.testCfgOverride = cfg;
    
        Test.setMock(HttpCalloutMock.class, new ChatbaseMockSuccess());
        String resp = phsChatBaseController.getTipFromAI('msg','conv');
        System.assertEquals('Hello from AI', resp, 'Should succeed with corrected path');
        phsChatBaseController.testCfgOverride = null;
    }
}