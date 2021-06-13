@isTest
public class TriggerTest_Subscription {
    
    public static Id customerRecId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('BlueWave_Customer').getRecordTypeId();
    
    @testSetup 
    static void testSetup() {
        
        List<Contact> customers = new List<Contact>();
        
        Contact customer1 = new Contact(FirstName = 'Test1', LastName = 'Customer1', RecordTypeId = customerRecId);
        customers.add(customer1);
        
        insert customers;
        
        List<Shared_Solar_System__c> solarSystems = new List<Shared_Solar_System__c>();
        
        Shared_Solar_System__c system1 = new Shared_Solar_System__c(Name = 'Solar System 1 Trigger Test');
        solarSystems.add(system1);
        
        insert solarSystems;
        
        List<Subscription__c> subscriptions = new List<Subscription__c>();
        
        Subscription__c sub1 = new Subscription__c(Customer__c = customer1.Id, Shared_Solar_System__c = system1.Id, 
                                                   Start_Date__c = date.today(), End_Date__c = date.today().addDays(10));
        
        subscriptions.add(sub1);
        
        Subscription__c sub2 = new Subscription__c(Customer__c = customer1.Id, Shared_Solar_System__c = system1.Id, 
                                                   Start_Date__c = date.today().addDays(30), End_Date__c = date.today().addDays(40));
        
        subscriptions.add(sub2);
        
        insert subscriptions;      
        
    }
    
    @isTest
    public static void isSubscriptionActiveTest() {
        List<Subscription__c> subs = [SELECT Id, Start_Date__c, End_Date__c, Active__c FROM Subscription__c ORDER BY Start_Date__c];
        System.assertEquals(subs[0].Active__c, true);
        System.assertEquals(subs[1].Active__c, false);
    }
    
    @isTest
    public static void checkForOverlappingDatesTest() {
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Id solarSystemId = [SELECT Id FROM Shared_Solar_System__c LIMIT 1].Id;
        
        try {
            Subscription__c overlappingSub = new Subscription__c(Customer__c = contactId, Shared_Solar_System__c = solarSystemId, 
                                                   Start_Date__c = date.today(), End_Date__c = date.today().addDays(30));
            
            insert overlappingSub;
            
        } catch(Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('Customer can not have overlapping dates for the same solar system.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);            
        }
        
    }
}