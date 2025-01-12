trigger ChatterGroupTrigger on CollaborationGroupMember (after insert, after delete) {
    System.debug('Trigger Context: ' + (Trigger.isInsert ? 'Insert' : Trigger.isDelete ? 'Delete' : 'Unknown'));

    if (Trigger.isInsert) {
        System.debug('Delegating insert logic to ChatterGroupHandler.');
        ChatterGroupHandler.handleInsert(Trigger.new);
    }

    if (Trigger.isDelete) {
        System.debug('Delegating delete logic to ChatterGroupHandler.');
        ChatterGroupHandler.handleDelete(Trigger.old);
    }
}
