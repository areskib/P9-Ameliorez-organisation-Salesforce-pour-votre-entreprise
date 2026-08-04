@isTest
private class testUpdateAccounts {

    @isTest
    static void testTriggerUpdatesCAOnActivation() {
        Account acc = new Account(Name = 'Test Account CA');
        insert acc;

        Order o = new Order(AccountId = acc.Id, Status = 'Draft', EffectiveDate = Date.today());
        insert o;

        Test.startTest();
        o.Status = 'Activated';
        update o;
        Test.stopTest();

        Order refreshedOrder = [SELECT TotalAmount FROM Order WHERE Id = :o.Id];
        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];

        System.assertEquals(refreshedOrder.TotalAmount, result.Chiffre_d_affaire__c,
            'Le CA du compte aurait dû se mettre à jour au passage de la commande à Activated.');
    }

    @isTest
    static void testTriggerDoesNotFireOnNonActivationUpdate() {
        Account acc = new Account(Name = 'Test Account No Trigger');
        insert acc;

        Order o = new Order(AccountId = acc.Id, Status = 'Draft', EffectiveDate = Date.today());
        insert o;

        Test.startTest();
        o.Description = 'Une simple note, pas de changement de statut';
        update o;
        Test.stopTest();

        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, result.Chiffre_d_affaire__c,
            'Le CA ne doit pas changer si la commande ne passe pas à Activated.');
    }

    @isTest
    static void testBulkTriggerHandles200Orders() {
        Account acc = new Account(Name = 'Test Account Bulk 200');
        insert acc;

        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < 200; i++) {
            orders.add(new Order(AccountId = acc.Id, Status = 'Draft', EffectiveDate = Date.today()));
        }
        insert orders;

        for (Order o : orders) {
            o.Status = 'Activated';
        }

        Test.startTest();
        update orders;
        Test.stopTest();

        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        System.assertNotEquals(null, result.Chiffre_d_affaire__c,
            'Le CA aurait dû être calculé même avec 200 commandes activées en une seule transaction.');
    }
}