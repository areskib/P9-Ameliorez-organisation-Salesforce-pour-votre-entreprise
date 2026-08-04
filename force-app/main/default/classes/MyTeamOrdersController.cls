public with sharing class MyTeamOrdersController {

    @AuraEnabled(cacheable=true)
    public static Decimal getSumOrdersByAccount(Id accountId) {
        AggregateResult result = [
            SELECT SUM(TotalAmount) total
            FROM Order
            WHERE AccountId = :accountId AND Status = 'Activated'
        ];
        Decimal total = (Decimal) result.get('total');
        return total != null ? total : 0;
    }
}