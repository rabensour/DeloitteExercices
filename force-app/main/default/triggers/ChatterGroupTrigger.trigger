trigger ChatterGroupTrigger on CollaborationGroupMember (after insert, after delete) {

    // Liste pour collecter les événements à publier
    List<ChatterGroupEvent__e> eventsToPublish = new List<ChatterGroupEvent__e>();

    // Récupérer les IDs des groupes Chatter référencés
    Set<Id> groupIds = new Set<Id>();
    if (Trigger.isInsert) {
        for (CollaborationGroupMember cgm : Trigger.new) {
            groupIds.add(cgm.CollaborationGroupId);
        }
    } else if (Trigger.isDelete) {
        for (CollaborationGroupMember cgm : Trigger.old) {
            groupIds.add(cgm.CollaborationGroupId);
        }
    }

    System.debug('Group IDs collected: ' + groupIds);

    // Charger les détails des groupes Chatter à partir de leurs IDs
    Map<Id, CollaborationGroup> groupMap = new Map<Id, CollaborationGroup>(
        [SELECT Id, Name FROM CollaborationGroup WHERE Id IN :groupIds]
    );

    System.debug('CollaborationGroup Map: ' + groupMap);

    // Gestion des insertions
    if (Trigger.isInsert) {
        System.debug('Processing Trigger.isInsert...');
        for (CollaborationGroupMember cgm : Trigger.new) {
            String groupName = groupMap.get(cgm.CollaborationGroupId)?.Name;
            System.debug('Processing new CollaborationGroupMember: ' + cgm.Id);
            System.debug('Group Name: ' + groupName);
            System.debug('User ID: ' + cgm.MemberId);

            eventsToPublish.add(new ChatterGroupEvent__e(
                Action__c = 'Add',
                ChatterGroupName__c = groupName,
                UserId__c = cgm.MemberId
            ));
        }
    }

    // Gestion des suppressions
    if (Trigger.isDelete) {
        System.debug('Processing Trigger.isDelete...');
        for (CollaborationGroupMember cgm : Trigger.old) {
            String groupName = groupMap.get(cgm.CollaborationGroupId)?.Name;
            System.debug('Processing deleted CollaborationGroupMember: ' + cgm.Id);
            System.debug('Group Name: ' + groupName);
            System.debug('User ID: ' + cgm.MemberId);

            eventsToPublish.add(new ChatterGroupEvent__e(
                Action__c = 'Remove',
                ChatterGroupName__c = groupName,
                UserId__c = cgm.MemberId
            ));
        }
    }

    // Publier les événements Platform Event
    if (!eventsToPublish.isEmpty()) {
        System.debug('Publishing events: ' + eventsToPublish);
        EventBus.publish(eventsToPublish);
    } else {
        System.debug('No events to publish.');
    }
}
