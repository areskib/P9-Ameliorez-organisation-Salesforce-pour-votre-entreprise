trigger CalculMontant on Order (before update) {
    for (Order newOrder : Trigger.new) {
        Decimal total = newOrder.TotalAmount != null ? newOrder.TotalAmount : 0;
        Decimal shipment = newOrder.ShipmentCost__c != null ? newOrder.ShipmentCost__c : 0;
        newOrder.NetAmount__c = total - shipment;
    }
}