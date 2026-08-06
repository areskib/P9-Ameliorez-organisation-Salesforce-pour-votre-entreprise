@isTest
private class CalculMontantTest {

    @isTest
    static void testNetAmountCalculatedOnSingleOrder() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Order o = new Order(AccountId = acc.Id, Status = 'Draft', EffectiveDate = Date.today());
        insert o;

        o.ShipmentCost__c = 50;
        Test.startTest();
        update o;
        Test.stopTest();

        Order result = [SELECT NetAmount__c, TotalAmount, ShipmentCost__c FROM Order WHERE Id = :o.Id];
        System.assertEquals(result.TotalAmount - result.ShipmentCost__c, result.NetAmount__c,
            'NetAmount__c devrait être égal à TotalAmount - ShipmentCost__c.');
    }

    @isTest
    static void testNetAmountCalculatedOnMultipleOrdersBulk() {
        Account acc = new Account(Name = 'Test Account Bulk');
        insert acc;

        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < 5; i++) {
            orders.add(new Order(AccountId = acc.Id, Status = 'Draft', EffectiveDate = Date.today()));
        }
        insert orders;

        for (Order o : orders) {
            o.ShipmentCost__c = 20;
        }

        Test.startTest();
        update orders;
        Test.stopTest();

        List<Order> results = [SELECT NetAmount__c, TotalAmount, ShipmentCost__c FROM Order WHERE Id IN :orders];
        for (Order result : results) {
            System.assertEquals(result.TotalAmount - result.ShipmentCost__c, result.NetAmount__c,
                'Chaque commande du lot devrait avoir NetAmount__c correctement calculé, pas seulement la première.');
        }
    }
}