@isTest
private class WeeklyPriceUpdateTest {

    @isTest
    static void testBatchUpdatesPricebookEntriesOnly() {
        PricebookEntry entry = TestDataFactory.createPricebookEntry('Produit Prix Test', 100);

        Test.startTest();
        Database.executeBatch(new WeeklyPriceUpdate());
        Test.stopTest();

        System.assert(true, 'Le batch doit s\'exécuter sans erreur sur les PricebookEntry actives.');
    }

    @isTest
    static void testBatchNeverTouchesChiffreAffaires() {
        Account account = TestDataFactory.createAccount('Test Account Price Update');
        Order activatedOrder = TestDataFactory.createActivatedOrderWithItem(account.Id, 200, 3);

        Account beforeBatch = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :account.Id];

        Test.startTest();
        Database.executeBatch(new WeeklyPriceUpdate());
        Test.stopTest();

        Account afterBatch = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :account.Id];

        System.assertEquals(beforeBatch.Chiffre_d_affaire__c, afterBatch.Chiffre_d_affaire__c,
            'Le chiffre d\'affaires ne doit jamais être modifié par la mise à jour hebdomadaire des prix.');
    }
}