public with sharing class BillAPI {
    public static List<Bill__c> getBills() {
        // Set the Named Credential endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(' https://my-json-server.typicode.com/grizzleevelyn/231017_dev_clicked/bills');
        req.setMethod('GET');
        
        // Send the HTTP request
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // Check the response status
        if (res.getStatusCode() == 200) {
            // Deserialize the JSON response into a list of BillWrapper objects
            List<BillWrapper> bwList = (List<BillWrapper>)JSON.deserialize(res.getBody(), List<BillWrapper>.class);
            
            // Create a map of Active Accounts (Active__c = 'Yes')
            Map<String, Id> accountMap = new Map<String, Id>();
            for (Account acc : [SELECT Id, Name FROM Account WHERE Active__c = 'Yes']) {
                accountMap.put(acc.Name, acc.Id);
            }
            
            // Create a list to store the bills to insert
            List<Bill__c> billsToInsert = new List<Bill__c>();
            
            // Iterate over the list of BillWrappers
            for (BillWrapper bw : bwList) {
                // Match the Account Name in BillWrapper to Account Id in the map
                Id accountId = accountMap.get(bw.accountName);
                
                // Create a new Bill__c record and set its fields
                Bill__c billToInsert = new Bill__c();
                billToInsert.Bill_Id__c = bw.billId;
                billToInsert.Balance__c = Decimal.valueOf(bw.balance.replace('$', ''));
                billToInsert.Account__c = accountId;
                
                // Add the new bill to the list
                billsToInsert.add(billToInsert);
            }
            
            // Insert the bills
            insert billsToInsert;
            
            // Query for the inserted bills
            List<Bill__c> insertedBills = [SELECT Id, Bill_Id__c, Balance__c FROM Bill__c WHERE Id IN :billsToInsert];
            
            return insertedBills;
        } else {
            // Handle the HTTP request error
            System.debug('HTTP Request Error: ' + res.getStatusCode() + ' ' + res.getStatus());
            return new List<Bill__c>();
        }
    }
    
    // Define a wrapper class to match the structure of the JSON response
    public class BillWrapper {
        public String billId;
        public String accountName;
        public String balance;
    }
}