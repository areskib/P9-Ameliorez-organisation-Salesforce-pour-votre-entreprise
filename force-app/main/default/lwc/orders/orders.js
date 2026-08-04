import { LightningElement, api, wire } from 'lwc';
import getSumOrdersByAccount from '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount';

export default class Orders extends LightningElement {

    @api recordId;
    sumOrdersOfCurrentAccount;

    @wire(getSumOrdersByAccount, { accountId: '$recordId' })
    wiredSum({ data, error }) {
        if (data !== undefined) {
            this.sumOrdersOfCurrentAccount = data;
        } else if (error) {
            this.sumOrdersOfCurrentAccount = 0;
        }
    }

    get hasOrders() {
        return this.sumOrdersOfCurrentAccount > 0;
    }
}