public with sharing class UpdateAccounts {

    public static void updateChiffreAffaires(Set<Id> accountIds) {
        if (accountIds.isEmpty()) {
            return;
        }

        Map<Id, Decimal> caByAccountId = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT AccountId acc, SUM(TotalAmount) total
            FROM Order
            WHERE AccountId IN :accountIds AND Status = 'Activated'
            GROUP BY AccountId
        ]) {
            caByAccountId.put((Id) ar.get('acc'), (Decimal) ar.get('total'));
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountIds) {
            accountsToUpdate.add(new Account(
                Id = accId,
                Chiffre_d_affaire__c = caByAccountId.containsKey(accId) ? caByAccountId.get(accId) : 0
            ));
        }

        update accountsToUpdate;
    }
}