global class WeeklyPriceUpdate implements Database.Batchable<sObject>, Database.Stateful {

    global Integer totalUpdated = 0;

    global Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator([
            SELECT Id, UnitPrice, Product2.Family
            FROM PricebookEntry
            WHERE IsActive = true
        ]);
    }

    global void execute(Database.BatchableContext info, List<PricebookEntry> scope) {
        List<PricebookEntry> entriesToUpdate = new List<PricebookEntry>();

        for (PricebookEntry entry : scope) {
            Decimal newPrice = calculateUpdatedPrice(entry);
            if (newPrice != entry.UnitPrice) {
                entriesToUpdate.add(new PricebookEntry(
                    Id = entry.Id,
                    UnitPrice = newPrice
                ));
            }
        }

        if (!entriesToUpdate.isEmpty()) {
            update entriesToUpdate;
            totalUpdated += entriesToUpdate.size();
        }
    }

    global void finish(Database.BatchableContext info) {
        System.debug('WeeklyPriceUpdate terminé. Fiches produits mises à jour : ' + totalUpdated);
    }

    // Logique de calcul du nouveau prix — isolée pour rester simple à faire évoluer
    // sans toucher au reste du batch.
    private static Decimal calculateUpdatedPrice(PricebookEntry entry) {
        return entry.UnitPrice;
    }
}