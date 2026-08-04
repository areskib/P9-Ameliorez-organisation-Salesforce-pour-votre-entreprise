trigger UpdateAccountCA on Order (after update) {
    Set<Id> accountIds = new Set<Id>();

    for (Integer i = 0; i < Trigger.new.size(); i++) {
        Order newOrder = Trigger.new[i];
        Order oldOrder = Trigger.oldMap.get(newOrder.Id);

        if (newOrder.Status == 'Activated' && oldOrder.Status != 'Activated') {
            accountIds.add(newOrder.AccountId);
        }
    }

    if (!accountIds.isEmpty()) {
        UpdateAccounts.updateChiffreAffaires(accountIds);
    }
}