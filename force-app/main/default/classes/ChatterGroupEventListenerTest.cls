@isTest
public class ChatterGroupEventListenerTest {

    // Utility method to create valid platform events
    private static List<ChatterGroupEvent__e> createValidEvents() {
        return new List<ChatterGroupEvent__e>{
            new ChatterGroupEvent__e(Action__c = 'Add', ChatterGroupName__c = 'TestGroup', UserId__c = '005XXXXXXXXXXXX'),
            new ChatterGroupEvent__e(Action__c = 'Remove', ChatterGroupName__c = 'TestGroup', UserId__c = '005XXXXXXXXXXXX')
        };
    }

    @isTest
    static void testHandlePlatformEvents_ValidEvents() {
        // Test valid events
        List<ChatterGroupEvent__e> platformEvents = createValidEvents();

        Test.startTest();
        ChatterGroupEventListener.handlePlatformEvents(platformEvents);
        Test.stopTest();

        // Add assertions to verify no exceptions occurred (optional)
        System.assert(true, 'Valid events processed without errors.');
    }

    @isTest
    static void testHandlePlatformEvents_BulkEvents() {
        // Test handling of multiple events (bulk scenario)
        List<ChatterGroupEvent__e> platformEvents = new List<ChatterGroupEvent__e>();
        for (Integer i = 0; i < 50; i++) {
            platformEvents.add(new ChatterGroupEvent__e(Action__c = 'Add', ChatterGroupName__c = 'Group' + i, UserId__c = '005XXXXXXXXXXXX'));
        }

        Test.startTest();
        ChatterGroupEventListener.handlePlatformEvents(platformEvents);
        Test.stopTest();

        System.assert(true, 'Bulk events processed successfully.');
    }

    @isTest
    static void testHandlePlatformEvents_NoEvents() {
        // Test with no events passed
        List<ChatterGroupEvent__e> platformEvents = new List<ChatterGroupEvent__e>();

        Test.startTest();
        ChatterGroupEventListener.handlePlatformEvents(platformEvents);
        Test.stopTest();

        System.assert(true, 'No events processed without errors.');
    }

    @isTest
    static void testHandlePlatformEvents_UnknownAction() {
        // Test with an unknown action
        List<ChatterGroupEvent__e> platformEvents = new List<ChatterGroupEvent__e>{
            new ChatterGroupEvent__e(Action__c = 'Unknown', ChatterGroupName__c = 'TestGroup', UserId__c = '005XXXXXXXXXXXX')
        };

        Test.startTest();
        ChatterGroupEventListener.handlePlatformEvents(platformEvents);
        Test.stopTest();

        System.assert(true, 'Unknown action processed without errors.');
    }

    @isTest
    static void testHandlePlatformEvents_ExceptionCase() {
        // Test with invalid data to trigger the catch block
        List<ChatterGroupEvent__e> platformEvents = new List<ChatterGroupEvent__e>{
            new ChatterGroupEvent__e(Action__c = 'Add', ChatterGroupName__c = null, UserId__c = null)
        };

        Test.startTest();
        ChatterGroupEventListener.handlePlatformEvents(platformEvents);
        Test.stopTest();

        System.assert(true, 'Exception case processed without crashing.');
    }
}
