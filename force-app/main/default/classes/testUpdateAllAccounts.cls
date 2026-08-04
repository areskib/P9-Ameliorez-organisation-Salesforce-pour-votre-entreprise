@isTest
private class testUpdateAllAccounts {

    @isTest
    static void testBatchUpdatesChiffreAffaires() {
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise');
        insert pd1;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        insert pbe;

        Order o1 = new Order(
            AccountId = acc1.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o1;

        OrderItem oi1 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity = 10, UnitPrice = 150);
        insert oi1;
        OrderItem oi2 = new OrderItem(OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity = 20, UnitPrice = 1000);
        insert oi2;

        o1.Status = 'Activated';
        update o1;

        Order refreshedOrder = [SELECT TotalAmount FROM Order WHERE Id = :o1.Id];

        Test.startTest();
        Database.executeBatch(new UpdateAllAccounts());
        Test.stopTest();

        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc1.Id];
        System.assertEquals(refreshedOrder.TotalAmount, result.Chiffre_d_affaire__c,
            'Le chiffre d\'affaires aurait dû correspondre au TotalAmount de la commande activée.');
    }

    @isTest
    static void testBatchIgnoresNonActivatedOrders() {
        Account acc2 = new Account(Name = 'Test Account 2');
        insert acc2;

        Order o2 = new Order(
            AccountId = acc2.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o2;

        Test.startTest();
        Database.executeBatch(new UpdateAllAccounts());
        Test.stopTest();

        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc2.Id];
        System.assertEquals(0, result.Chiffre_d_affaire__c,
            'Une commande non Activated ne doit pas être comptée dans le chiffre d\'affaires.');
    }
}