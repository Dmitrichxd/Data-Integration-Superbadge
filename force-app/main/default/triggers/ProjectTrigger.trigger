trigger ProjectTrigger on Project__c (after update) {
    if (!System.isFuture() && Trigger.isAfter && Trigger.isUpdate) {
        BillingCalloutService.callBillingService(Trigger.new,Trigger.oldMap);
    }
}