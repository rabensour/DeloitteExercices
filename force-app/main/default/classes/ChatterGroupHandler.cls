public class ChatterGroupHandler {
    public static void handleInsert(List<CollaborationGroupMember> newMembers) {
        List<ChatterGroupEvent__e> events = new List<ChatterGroupEvent__e>();

        System.debug('Handling insert operation in ChatterGroupHandler.');

        for (CollaborationGroupMember member : newMembers) {
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

        publishEvents(events);
    }

    public static void handleDelete(List<CollaborationGroupMember> oldMembers) {
        List<ChatterGroupEvent__e> events = new List<ChatterGroupEvent__e>();

        System.debug('Handling delete operation in ChatterGroupHandler.');

        for (CollaborationGroupMember member : oldMembers) {
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

        publishEvents(events);
    }

    private static void publishEvents(List<ChatterGroupEvent__e> events) {
        if (!events.isEmpty()) {
            System.debug('Publishing events: ' + events);
            try {
                List<Database.SaveResult> results = EventBus.publish(events);

                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event. Event ID: ' + sr.getId());
                    } else {
                        for (Database.Error err : sr.getErrors()) {
                            System.debug('Error publishing event: ' + err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('Error while publishing events: ' + e.getMessage());
            }
        } else {
            System.debug('No events to publish.');
        }
    }
}
