@isTest
public class TestDataFactory {

    public static Account createAccount(String accountName) {
        Account account = new Account(Name = accountName);
        insert account;
        return account;
    }

    public static PricebookEntry createPricebookEntry(String productName, Decimal unitPrice) {
        Product2 product = new Product2(Name = productName, Family = 'Chemise');
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = unitPrice,
            IsActive = true
        );
        insert pricebookEntry;
        return pricebookEntry;
    }

    public static Order createDraftOrder(Id accountId) {
        Order order = new Order(
            AccountId = accountId,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order;
        return order;
    }

    public static OrderItem createOrderItem(Id orderId, Id pricebookEntryId, Integer quantity, Decimal unitPrice) {
        OrderItem orderItem = new OrderItem(
            OrderId = orderId,
            PricebookEntryId = pricebookEntryId,
            Quantity = quantity,
            UnitPrice = unitPrice
        );
        insert orderItem;
        return orderItem;
    }

    public static Order createActivatedOrderWithItem(Id accountId, Decimal unitPrice, Integer quantity) {
        PricebookEntry pricebookEntry = createPricebookEntry('Produit Test', unitPrice);
        Order order = createDraftOrder(accountId);
        createOrderItem(order.Id, pricebookEntry.Id, quantity, unitPrice);

        order.Status = 'Activated';
        update order;
        return order;
    }
}