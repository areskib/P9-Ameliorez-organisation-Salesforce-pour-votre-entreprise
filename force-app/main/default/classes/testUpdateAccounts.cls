@isTest
private class testUpdateAccounts {

    private static void createOrderItemForOrder(Id orderId) {
        Product2 pd = new Product2(Name = 'Produit Test', Family = 'Chemise');
        insert pd;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pd.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        insert new OrderItem(OrderId = orderId, PricebookEntryId = pbe.Id, Quantity = 5, UnitPrice = 100);
    }

    @isTest
    static void testTriggerUpdatesCAOnActivation() {
        Account acc = new Account(Name = 'Test Account CA');
        insert acc;

        Order o = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;
        createOrderItemForOrder(o.Id);

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

        Order o = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;

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
        Account acc = new Account(Name = 'Test Account Bulk 200');
        insert acc;

        Product2 pd = new Product2(Name = 'Produit Bulk', Family = 'Chemise');
        insert pd;
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pd.Id,
            UnitPrice = 50,
            IsActive = true
        );
        insert pbe;

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