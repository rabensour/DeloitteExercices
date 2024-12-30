public with sharing class ChatterGroupEventListener {
    @InvocableMethod
    public static void handlePlatformEvents(List<ChatterGroupEvent__e> platformEvents) {
        // Vérifier si des événements ont été reçus
        if (platformEvents == null || platformEvents.isEmpty()) {
            System.debug('No Platform Events to process.');
            return;
        }

        Set<String> groupNames = new Set<String>();
        Set<Id> userIds = new Set<Id>();

        // Collecter les informations nécessaires
        for (ChatterGroupEvent__e event : platformEvents) {
            if (!String.isBlank(event.ChatterGroupName__c)) {
                groupNames.add(event.ChatterGroupName__c);
            }
            if (event.UserId__c != null) {
                userIds.add(event.UserId__c);
            }
        }

        System.debug('Collected Group Names: ' + groupNames);
        System.debug('Collected User IDs: ' + userIds);

        // Charger les groupes existants
        Map<String, Group> publicGroupMap = new Map<String, Group>();
        for (Group grp : [SELECT Id, Name FROM Group WHERE Name IN :groupNames AND Type = 'Regular']) {
            publicGroupMap.put(grp.Name, grp);
        }

        System.debug('Loaded Public Groups: ' + publicGroupMap);

        List<Group> groupsToInsert = new List<Group>();
        List<GroupMember> membersToInsert = new List<GroupMember>();
        List<GroupMember> membersToDelete = new List<GroupMember>();

        // Traiter chaque événement
        for (ChatterGroupEvent__e event : platformEvents) {
            try {
                System.debug('--- Processing Platform Event ---');
                System.debug('Event Action: ' + event.Action__c);
                System.debug('Event ChatterGroupName: ' + event.ChatterGroupName__c);
                System.debug('Event UserId: ' + event.UserId__c);

                Group publicGroup = publicGroupMap.get(event.ChatterGroupName__c);

                // Créer le groupe s'il n'existe pas
                if (publicGroup == null && event.Action__c == 'Add') {
                    publicGroup = new Group(Name = event.ChatterGroupName__c, DeveloperName = event.ChatterGroupName__c, Type = 'Regular');
                    groupsToInsert.add(publicGroup);
                    publicGroupMap.put(event.ChatterGroupName__c, publicGroup);
                    System.debug('Public Group to Create: ' + publicGroup.Name);
                }

                // Ajouter ou supprimer le membre
                if (event.Action__c == 'Add' && publicGroup != null) {
                    membersToInsert.add(new GroupMember(GroupId = publicGroup.Id, UserOrGroupId = event.UserId__c));
                    System.debug('User to Add: ' + event.UserId__c + ' to Group: ' + publicGroup.Name);
                } else if (event.Action__c == 'Remove' && publicGroup != null) {
                    GroupMember existingMember = [SELECT Id FROM GroupMember WHERE GroupId = :publicGroup.Id AND UserOrGroupId = :event.UserId__c LIMIT 1];
                    if (existingMember != null) {
                        membersToDelete.add(existingMember);
                        System.debug('User to Remove: ' + event.UserId__c + ' from Group: ' + publicGroup.Name);
                    } else {
                        System.debug('User not found in Public Group for Removal: ' + event.UserId__c);
                    }
                }
            } catch (Exception ex) {
                System.debug('Error processing Platform Event: ' + ex.getMessage());
            }
        }

        // Exécuter les insertions et suppressions
        try {
            if (!groupsToInsert.isEmpty()) {
                insert groupsToInsert;
                System.debug('Groups Created: ' + groupsToInsert);
            }
        } catch (Exception ex) {
            System.debug('Error creating Public Groups: ' + ex.getMessage());
        }

        try {
            if (!membersToInsert.isEmpty()) {
                insert membersToInsert;
                System.debug('Members Added: ' + membersToInsert);
            }
        } catch (Exception ex) {
            System.debug('Error adding Members: ' + ex.getMessage());
        }

        try {
            if (!membersToDelete.isEmpty()) {
                delete membersToDelete;
                System.debug('Members Deleted: ' + membersToDelete);
            }
        } catch (Exception ex) {
            System.debug('Error deleting Members: ' + ex.getMessage());
        }

        System.debug('Platform Event processing completed.');
    }
}
