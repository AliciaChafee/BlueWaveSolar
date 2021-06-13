public class TriggerHelper_Subscription {
    
    // determines if subscription is currently active on insert and update
    public static void isSubscriptionActive(List<Subscription__c> subscriptions) {
        Date todaysDate = date.today();
        for(Subscription__c sub : subscriptions) {
            if(todaysDate >= sub.Start_Date__c && todaysDate <= sub.End_Date__c) {
                sub.Active__c = true;
            } else {
                sub.Active__c = false;
            }
        }
        
    }
    
    public static void checkForOverlappingDates(List<Subscription__c> subscriptions) {        
        
        // loop through all subscriptions and get customer id and return list of customer Ids
        List<Id> customerIds = getCustomerIds(subscriptions);
        
        // query for all subscriptions related to customerIds and put in a map<Customer Id, List<Subs>>
        Map<Id, List<Subscription__c>> existingCustomerSubscriptionsMap = getExistingCustomerSubscriptionsMap(customerIds);
        
        
        // loop through subscriptions again and pull from existing customer map
        // If customer has no previous subscriptions, continue to next iteration, else
        // if any new subscription has the same customer, solar system, and is overlapping in dates, add an error
        for (Subscription__c newSub : subscriptions) {
            if(!existingCustomerSubscriptionsMap.containsKey(newSub.Customer__c)) {
                continue;
            }
            List<Subscription__c> existingCustomerSubs = existingCustomerSubscriptionsMap.get(newSub.Customer__c);
            
            System.debug(existingCustomerSubs.size());
            
            for (Subscription__c existingCustomerSubscription : existingCustomerSubs) {
                if (newSub.Shared_Solar_System__c == existingCustomerSubscription.Shared_Solar_System__c && 
                    newSub.Start_Date__c <= existingCustomerSubscription.End_Date__c && 
                    newSub.End_Date__c >= existingCustomerSubscription.Start_Date__c) {
                        
                        newSub.addError('Customer can not have overlapping dates for the same solar system.');
                        
                    }
            }
            
        }
        
        
        
    }
    
    
    public static List<Id> getCustomerIds(List<Subscription__c> subscriptions) {
        List<Id> customerIds = new List<Id>();
        
        for(Subscription__c sub : subscriptions) {
            customerIds.add(sub.Customer__c);
        }
        
        return customerIds;
        
    }
    
    
    public static Map<Id, List<Subscription__c>> getExistingCustomerSubscriptionsMap(List<Id> customerIds) {
        List<Subscription__c> customerMapSubs = new List<Subscription__c>();
        Map<Id, List<Subscription__c>> mapOfCustomerSubscriptions = new Map<Id, List<Subscription__c>>();
        
        List<Subscription__c> existingCustomerSubscriptions = [SELECT Id, Customer__c, Start_Date__c, End_Date__c, Shared_Solar_System__c 
                                                               FROM Subscription__c  
                                                               WHERE Customer__c IN :customerIds];
        
        for (Subscription__c customerSub : existingCustomerSubscriptions ) {
            customerMapSubs.add(customerSub);
            mapOfCustomerSubscriptions.put(customerSub.Customer__c, customerMapSubs);
        }
        
        return mapOfCustomerSubscriptions;
        
    }
    
}