@isTest
private class UpdateAllAccountsTest {

    @isTest
    static void testBatchUpdatesChiffreAffaires() {
        Account acc1 = TestDataFactory.createAccount('Test Account 1');
        Order o1 = TestDataFactory.createActivatedOrderWithItem(acc1.Id, 150, 10);

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
        Account acc2 = TestDataFactory.createAccount('Test Account 2');
        TestDataFactory.createDraftOrder(acc2.Id);

        Test.startTest();
        Database.executeBatch(new UpdateAllAccounts());
        Test.stopTest();

        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc2.Id];
        System.assertEquals(null, result.Chiffre_d_affaire__c,
            'Un compte sans commande Activated n\'est plus traité par le batch optimisé, son CA reste donc inchangé (null).');
    }
}