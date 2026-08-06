@isTest
private class MyTeamOrdersControllerTest {

    @isTest
    static void testReturnsSumOfActivatedOrdersOnly() {
        Account acc = TestDataFactory.createAccount('Test Account LWC');
        Order activatedOrder = TestDataFactory.createActivatedOrderWithItem(acc.Id, 100, 5);
        TestDataFactory.createDraftOrder(acc.Id);

        Order refreshedActivated = [SELECT TotalAmount FROM Order WHERE Id = :activatedOrder.Id];

        Test.startTest();
        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
        Test.stopTest();

        System.assertEquals(refreshedActivated.TotalAmount, total,
            'Seule la commande Activated devrait être comptée, pas la Draft.');
    }

    @isTest
    static void testReturnsZeroWhenNoOrders() {
        Account acc = TestDataFactory.createAccount('Test Account Empty');

        Test.startTest();
        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
        Test.stopTest();

        System.assertEquals(0, total, 'Devrait renvoyer 0 si aucune commande n\'existe pour ce compte.');
    }

    @isTest
    static void testDoesNotSumOrdersFromOtherAccounts() {
        Account acc1 = TestDataFactory.createAccount('Account 1');
        Account acc2 = TestDataFactory.createAccount('Account 2');

        Order o1 = TestDataFactory.createActivatedOrderWithItem(acc1.Id, 100, 5);
        TestDataFactory.createActivatedOrderWithItem(acc2.Id, 100, 5);

        Test.startTest();
        Decimal totalAcc1 = MyTeamOrdersController.getSumOrdersByAccount(acc1.Id);
        Test.stopTest();

        Order refreshedOrder1 = [SELECT TotalAmount FROM Order WHERE Id = :o1.Id];
        System.assertEquals(refreshedOrder1.TotalAmount, totalAcc1,
            'Le total ne devrait inclure que les commandes du compte demandé, pas celles d\'un autre compte.');
    }
}