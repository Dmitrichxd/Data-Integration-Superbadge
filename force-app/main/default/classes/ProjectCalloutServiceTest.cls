@ isTest
private class ProjectCalloutServiceTest {
	@testSetup
	static void createTestData() {
		Account acc = new Account(Name = 'Acc1');
		insert acc;

		Opportunity validOpp = new Opportunity(Name = 'ValidTest', 
											   AccountId = acc.Id, 
											   Amount = 100000, 
											   CloseDate = Date.today(), 
											   Type = 'New Project', 
											   StageName = 'Prospecting');
		insert validOpp;

		Opportunity invalidOpp = new Opportunity(Name = 'InvalidTest', 
											     AccountId = acc.Id, 
											     Amount = 100000, 
											     CloseDate = Date.today(), 
											     Type = 'New Customer', 
											     StageName = 'Prospecting');
		insert invalidOpp;

		ServiceTokens__c token = new ServiceTokens__c();
		token.Name = 'ProjectServiceToken';
		token.Token__c = 'abcdefg';
		insert token;
	}

	@isTest
	static void testValidPostCallout() {
		Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
		Opportunity opp = [SELECT Id, Name, Account.Name, CloseDate, Amount
						   FROM Opportunity
						   WHERE Name = 'ValidTest'];
		String serviceToken = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;
		String jsonInput = '{\n' +
		' "opportunityId" : "' + opp.Id + '",\n' +
		' "opportunityName" : "' + opp.Name + '",\n' +
		' "accountName" : "' + opp.Account.Name + '",\n' +
		' "closeDate" : "' + String.ValueOf(opp.CloseDate).mid(0, 10) + '",\n' +
		' "amount" : "' + opp.Amount + '"\n}';
		Test.startTest();
		opp.StageName = 'Closed Won';
		update opp;
		ProjectCalloutService.postToPMS(serviceToken, jsonInput, opp.Id);
		Test.stopTest();
		opp = [SELECT Id, StageName FROM Opportunity WHERE Name = 'ValidTest'];
		System.assertEquals('Submitted Project', opp.StageName, 'not Submitted Project');
	}

	@isTest
	static void testInvalidPostCallout() {
		Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
		Opportunity opp = [SELECT Id, Name, Account.Name, CloseDate, Amount
						   FROM Opportunity
						   WHERE Name = 'InvalidTest'];
		String serviceToken = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;
		String jsonInput = '{\n' +
		' "opportunityId" : "' + opp.Id + '",\n' +
		' "opportunityName" : "' + opp.Name + '",\n' +
		' "accountName" : "' + opp.Account.Name + '",\n' +
		' "closeDate" : "' + String.ValueOf(opp.CloseDate).mid(0, 10) + '",\n' +
		' "amount" : "' + opp.Amount + '"\n}';
		Test.startTest();
		opp.StageName = 'Closed Won';
		update opp;
		ProjectCalloutService.postToPMS(serviceToken, jsonInput, opp.Id);
		Test.stopTest();
		opp = [SELECT Id, StageName FROM Opportunity WHERE id = :opp.Id];
		System.assertEquals('Resubmit Project', opp.StageName, 'not Resubmit Project');
	}
}