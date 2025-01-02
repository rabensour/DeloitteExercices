trigger ChatterGroupTrigger on CollaborationGroupMember (after insert, after delete) {
    
    List<ChatterGroupEvent__e> events = new List<ChatterGroupEvent__e>();

    System.debug('Trigger Context: ' + (Trigger.isInsert ? 'Insert' : Trigger.isDelete ? 'Delete' : 'Unknown'));

    // Handling Insert Events
    if (Trigger.isInsert) {
        System.debug('Processing Inserted Records: ' + Trigger.new);
        for (CollaborationGroupMember member : Trigger.new) {
            try {
                String chatterGroupName = [
                    SELECT Name FROM CollaborationGroup WHERE Id = :member.CollaborationGroupId LIMIT 1
                ].Name;
                System.debug('Chatter Group Name Retrieved: ' + chatterGroupName);

                ChatterGroupEvent__e event = new ChatterGroupEvent__e(
                    Action__c = 'add',
                    ChatterGroupName__c = chatterGroupName,
                    UserId__c = member.MemberId
                );

                events.add(event);
                System.debug('Event Prepared for Add: ' + event);
            } catch (Exception e) {
                System.debug('Error while processing insert for member: ' + member + '. Error: ' + e.getMessage());
            }
        }
    }

    // Handling Delete Events
    if (Trigger.isDelete) {
        System.debug('Processing Deleted Records: ' + Trigger.old);
        for (CollaborationGroupMember member : Trigger.old) {
            try {
                String chatterGroupName = [
                    SELECT Name FROM CollaborationGroup WHERE Id = :member.CollaborationGroupId LIMIT 1
                ].Name;
                System.debug('Chatter Group Name Retrieved: ' + chatterGroupName);

                ChatterGroupEvent__e event = new ChatterGroupEvent__e(
                    Action__c = 'remove',
                    ChatterGroupName__c = chatterGroupName,
                    UserId__c = member.MemberId
                );

                events.add(event);
                System.debug('Event Prepared for Remove: ' + event);
            } catch (Exception e) {
                System.debug('Error while processing delete for member: ' + member + '. Error: ' + e.getMessage());
            }
        }
    }

    // Publishing Events
    if (!events.isEmpty()) {
        try {
            List<Database.SaveResult> results = EventBus.publish(events);
            for(Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event. Event ID: ' + sr.getId());
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error publishing event: ' + err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error while publishing events: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}
