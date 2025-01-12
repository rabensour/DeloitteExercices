trigger ChatterGroupEventTrigger on ChatterGroupEvent__e (after insert) {
    
    System.debug('=== ChatterGroupEventTrigger Fired ===');

    // Check if any events have been received
    if (Trigger.new == null || Trigger.new.isEmpty()) {
        System.debug('No events received in ChatterGroupEventTrigger.');
        return;
    }

    System.debug('Received Events: ' + Trigger.new);

    // Pass the events to the handler class for processing
    try {
        ChatterGroupEventHandler.handlePlatformEvents(Trigger.new);
    } catch (Exception e) {
        System.debug('Error in ChatterGroupEventTrigger: ' + e.getMessage());
    }

    System.debug('=== Exiting ChatterGroupEventTrigger ===');
}
