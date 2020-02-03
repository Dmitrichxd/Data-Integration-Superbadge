@ isTest
private class BillingCalloutServiceTest {
	@testSetup static void createTestData() {
		ServiceCredentials__c credentials = new ServiceCredentials__c(Name = 'BillingServiceCredential');
		credentials.Username__c = 'TestName';
		credentials.Password__c = 'TestPwd';
		insert credentials;
		Opportunity opp = new Opportunity(Name = 'TestOpp', 
									      CloseDate= Date.today(), 
									      StageName= 'Submitted Project');
		insert opp;
		List<Project__c> projects = new List<Project__c>();
		for (Integer i = 0; i < 100; i ++) {
			Project__c p = new Project__c(Name = 'TestProj ' + i, 
								      Opportunity__c= opp.Id, 
								      Status__c= 'Running', 
								      ProjectRef__c= 'EXT_ID_' + i, 
								      Billable_Amount__c= 100000, 
								      Start_Date__c = Date.today(), 
								      End_Date__c = Date.today().addDays(30));
			projects.add(p);
		}
		insert projects;
	}

	@isTest
	static void testSOAPCalloutSuccess() {
		Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());

		List<Project__c> projects = new List<Project__c>([SELECT Status__c
												      FROM Project__c
												      WHERE Name like 'TestProj%']);
		for (Project__c p :projects) {
			p.Status__c = 'Billable';
		}
		Test.startTest();
		update projects;
		Test.stopTest();

		projects = new List<Project__c>([SELECT Status__c
								     FROM Project__c
								     WHERE Name like 'TestProj%']);
		for (Project__c p :projects) {
			System.assertEquals('Billed', p.Status__c);
		}
	}

	@isTest
	static void testSOAPCalloutFail() {
		Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
		List<Project__c> projects = new List<Project__c>([SELECT Status__c
												      FROM Project__c
												      WHERE Name like 'TestProj%']);
		for (Project__c p :projects) {
			p.Status__c = 'Billable';
		}
		Test.startTest();
		update projects;
		Test.stopTest();
		projects = new List<Project__c>([SELECT Status__c FROM Project__c WHERE Name like 'TestProj%']);
		for (Project__c p :projects) {
			System.assertEquals('Billable', p.Status__c);
		}
	}
}