@isTest
public class TestDataFactory {

    public static Account createAccount(String name) {
        Account acc = new Account(Name = name);
        insert acc;
        return acc;
    }

    public static PricebookEntry createPricebookEntry(String productName, Decimal unitPrice) {
        Product2 pd = new Product2(Name = productName, Family = 'Chemise');
        insert pd;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pd.Id,
            UnitPrice = unitPrice,
            IsActive = true
        );
        insert pbe;
        return pbe;
    }

    public static Order createDraftOrder(Id accountId) {
        Order o = new Order(
            AccountId = accountId,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;
        return o;
    }

    public static OrderItem createOrderItem(Id orderId, Id pricebookEntryId, Integer quantity, Decimal unitPrice) {
        OrderItem oi = new OrderItem(
            OrderId = orderId,
            PricebookEntryId = pricebookEntryId,
            Quantity = quantity,
            UnitPrice = unitPrice
        );
        insert oi;
        return oi;
    }

    public static Order createActivatedOrderWithItem(Id accountId, Decimal unitPrice, Integer quantity) {
        PricebookEntry pbe = createPricebookEntry('Produit Test', unitPrice);
        Order o = createDraftOrder(accountId);
        createOrderItem(o.Id, pbe.Id, quantity, unitPrice);

        o.Status = 'Activated';
        update o;
        return o;
    }
}