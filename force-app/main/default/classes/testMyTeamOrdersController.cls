@isTest
private class testMyTeamOrdersController {

    private static void createOrderItemForOrder(Id orderId) {
        Product2 pd = new Product2(Name = 'Produit Test LWC', Family = 'Chemise');
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
    static void testReturnsSumOfActivatedOrdersOnly() {
        Account acc = new Account(Name = 'Test Account LWC');
        insert acc;

        Order activatedOrder = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert activatedOrder;
        createOrderItemForOrder(activatedOrder.Id);
        activatedOrder.Status = 'Activated';
        update activatedOrder;

        Order draftOrder = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert draftOrder;

        Order refreshedActivated = [SELECT TotalAmount FROM Order WHERE Id = :activatedOrder.Id];

        Test.startTest();
        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
        Test.stopTest();

        System.assertEquals(refreshedActivated.TotalAmount, total,
            'Seule la commande Activated devrait être comptée, pas la Draft.');
    }

    @isTest
    static void testReturnsZeroWhenNoOrders() {
        Account acc = new Account(Name = 'Test Account Empty');
        insert acc;

        Test.startTest();
        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
        Test.stopTest();

        System.assertEquals(0, total, 'Devrait renvoyer 0 si aucune commande n\'existe pour ce compte.');
    }

    @isTest
    static void testDoesNotSumOrdersFromOtherAccounts() {
        Account acc1 = new Account(Name = 'Account 1');
        insert acc1;
        Account acc2 = new Account(Name = 'Account 2');
        insert acc2;

        Order o1 = new Order(
            AccountId = acc1.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o1;
        createOrderItemForOrder(o1.Id);
        o1.Status = 'Activated';
        update o1;

        Order o2 = new Order(
            AccountId = acc2.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o2;
        createOrderItemForOrder(o2.Id);
        o2.Status = 'Activated';
        update o2;

        Test.startTest();
        Decimal totalAcc1 = MyTeamOrdersController.getSumOrdersByAccount(acc1.Id);
        Test.stopTest();

        Order refreshedOrder1 = [SELECT TotalAmount FROM Order WHERE Id = :o1.Id];
        System.assertEquals(refreshedOrder1.TotalAmount, totalAcc1,
            'Le total ne devrait inclure que les commandes du compte demandé, pas celles d\'un autre compte.');
    }
}