import { LightningElement, wire, track } from 'lwc';
import fetchParties from '@salesforce/apex/PartyController.getParties';
import getUserInfo from '@salesforce/apex/UserController.getCurrentUserInfo';
import createNewParty from '@salesforce/apex/PartyController.createParty';
import saveVote from '@salesforce/apex/ChoiceController.saveChoice';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ElectionApp extends LightningElement {
    @track parties = [];
    @track selectedParty = null;
    @track showPartyForm = false;

    @track newPartyName = '';
    @track newPartyCode = '';
    @track newPartyDescription = '';
    @track newPartyLeader = '';

    userName = '';
    userId = '';

    // Fetch parties from the server
    @wire(fetchParties)
    wiredParties({ error, data }) {
        if (data) {
            this.parties = data;
        } else if (error) {
            console.error('Error fetching parties:', error);
        }
    }

    // Fetch current user info
    @wire(getUserInfo)
    wiredUserInfo({ error, data }) {
        if (data) {
            this.userId = data.userId;
            this.userName = data.userName;
        } else if (error) {
            console.error('Error fetching user info:', error);
        }
    }

    // Handle card click
    selectParty(event) {
        const partyId = event.currentTarget.dataset.id;
        this.selectedParty = partyId;
        this.highlightSelectedParty(partyId);
    }

    highlightSelectedParty(partyId) {
        this.template.querySelectorAll('.party-container').forEach((card) => {
            card.classList.remove('highlight');
            if (card.closest('[data-id]').dataset.id === partyId) {
                card.classList.add('highlight');
            }
        });
    }

    // Show/Hide the new party form
    togglePartyForm() {
        this.showPartyForm = !this.showPartyForm;
        console.log('showPartyForm', showPartyForm);
    }

    // Handle input changes for the new party form
    handleInputChange(event) {
        this[event.target.name] = event.target.value;
    }

    // Save new party and refresh the list
    async saveNewParty() {
        try {
            const result = await createNewParty({
                name: this.newPartyName,
                code: this.newPartyCode,
                description: this.newPartyDescription,
                leader: this.newPartyLeader
            });
            this.showToast('Success', 'Party added successfully!', 'success');
            this.parties = [...this.parties, result];
            this.clearNewPartyForm();
        } catch (error) {
            this.showToast('Error', 'Failed to add new party.', 'error');
            console.error('Error creating party:', error);
        }
    }

    clearNewPartyForm() {
        this.newPartyName = '';
        this.newPartyCode = '';
        this.newPartyDescription = '';
        this.newPartyLeader = '';
    }

    // Save user's selection
    async saveSelection() {
        try {
            await saveVote({
                partyId: this.selectedParty,
                userId: this.userId,
                userName: this.userName,
                choiceDate: new Date()
            });
            this.showToast('Success', 'Your selection has been saved!', 'success');
        } catch (error) {
            this.showToast('Error', 'Failed to save your selection.', 'error');
            console.error('Error saving selection:', error);
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}
