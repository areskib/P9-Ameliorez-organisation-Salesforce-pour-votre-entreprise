@isTest
private class UpdateAccountsTest {

    @isTest
    static void testTriggerUpdatesCAOnActivation() {
        Account acc = TestDataFactory.createAccount('Test Account CA');
        Order o = TestDataFactory.createActivatedOrderWithItem(acc.Id, 100, 5);

        Order refreshedOrder = [SELECT TotalAmount FROM Order WHERE Id = :o.Id];
        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];

        System.assertEquals(refreshedOrder.TotalAmount, result.Chiffre_d_affaire__c,
            'Le CA du compte aurait dû se mettre à jour au passage de la commande à Activated.');
    }

    @isTest
    static void testTriggerDoesNotFireOnNonActivationUpdate() {
        Account acc = TestDataFactory.createAccount('Test Account No Trigger');
        Order o = TestDataFactory.createDraftOrder(acc.Id);

        Test.startTest();
        o.Description = 'Une simple note, pas de changement de statut';
        update o;
        Test.stopTest();

        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(null, result.Chiffre_d_affaire__c,
            'Le CA ne doit pas changer si la commande ne passe pas à Activated.');
    }

    @isTest
    static void testBulkTriggerHandles200Orders() {
        Account acc = TestDataFactory.createAccount('Test Account Bulk 200');
        PricebookEntry pbe = TestDataFactory.createPricebookEntry('Produit Bulk', 50);

        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < 200; i++) {
            orders.add(new Order(
                AccountId = acc.Id,
                Status = 'Draft',
                EffectiveDate = Date.today(),
                Pricebook2Id = Test.getStandardPricebookId()
            ));
        }
        insert orders;

        List<OrderItem> items = new List<OrderItem>();
        for (Order o : orders) {
            items.add(new OrderItem(OrderId = o.Id, PricebookEntryId = pbe.Id, Quantity = 1, UnitPrice = 50));
        }
        insert items;

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