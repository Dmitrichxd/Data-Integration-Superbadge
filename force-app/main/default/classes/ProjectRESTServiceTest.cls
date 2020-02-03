@ isTest
private class ProjectRESTServiceTest {
	@testSetup
	static void createTestData() {
		Opportunity opp = new Opportunity(Name = 'Test', 
									      CloseDate= Date.today(), 
									      StageName= 'Submitted Project');
		insert opp;
	}

	@isTest
	static void successfulProjectRestServiceTest() {
		RestRequest request = new RestRequest();
		request.requestUri = '/services/apexrest/project/';
		request.httpMethod = 'POST';
		RestContext.request = request;
		Opportunity opp = [SELECT Id
						   FROM Opportunity
						   WHERE Name = 'Test'
						   LIMIT 1];
		String response = ProjectRESTService.postProjectData('271828', 
														     'Test Project 1', 
														     opp.Id, 
														     Date.today(), 
														     Date.today().addDays(30), 
														     100000, 
														     'Running');

		Project__c proj = [SELECT Name, ProjectRef__c FROM Project__c WHERE Opportunity__c = :opp.Id];
		System.assertEquals('271828', proj.ProjectRef__c, 'incorrect proj ref');
		System.assertEquals('OK', response, 'The response should be OK');
	}

	@isTest
	static void failureProjectRestServiceTest() {
		RestRequest request = new RestRequest();
		request.requestUri = '/services/apexrest/project/';
		request.httpMethod = 'POST';
		RestContext.request = request;
		String response = ProjectRESTService.postProjectData('271828', 
														     'Test Project 1', 
														     '123456', 
														     Date.today(), 
														     Date.today().addDays(30), 
														     100000, 
														     'Running');

		System.assertEquals('Invalid id: ' + '123456', response);
	}
}