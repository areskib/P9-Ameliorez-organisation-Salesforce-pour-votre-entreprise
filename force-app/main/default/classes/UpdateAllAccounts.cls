global class UpdateAllAccounts implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator('SELECT Id FROM Account');
    }

    global void execute(Database.BatchableContext info, List<Account> scope) {
        Set<Id> accountIds = (new Map<Id, SObject>(scope)).keySet();
        UpdateAccounts.updateChiffreAffaires(accountIds);
    }

    global void finish(Database.BatchableContext info) {
    }
}