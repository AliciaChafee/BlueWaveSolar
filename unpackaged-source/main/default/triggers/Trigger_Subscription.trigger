trigger Trigger_Subscription on Subscription__c (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {
        
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                TriggerHelper_Subscription.checkForOverlappingDates(Trigger.New);
                TriggerHelper_Subscription.isSubscriptionActive(Trigger.New);
            } 
            if (Trigger.isUpdate) {
                TriggerHelper_Subscription.isSubscriptionActive(Trigger.New);
            }
            if (Trigger.isDelete) {
                // Call class logic here!
            }
        }
        
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                // Call class logic here!
            } 
            if (Trigger.isUpdate) {
                // Call class logic here!
            }
            if (Trigger.isDelete) {
                // Call class logic here!
            }
        }
    }