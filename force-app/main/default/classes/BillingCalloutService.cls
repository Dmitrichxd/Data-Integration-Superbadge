public with sharing class BillingCalloutService {
	public static void callBillingService(List<Project__c> projects, Map<Id, Project__c> oldProjMap) {
		List<Project__c> validProjects = new List<Project__c>();

		// valid if project status is changed to 'Billable'
		for (Project__c proj :projects) {
			if(proj.Status__c == 'Billable' && oldProjMap.get(proj.Id).Status__c != 'Billable') {
				validProjects.add(proj);
			}
        }
        callSOAPService(JSON.serialize(validProjects));
    }

		@Future(callout = true)public static void callSOAPService(String jsonProjectList) {
			// get SOAP credentials
			final String USERNAME = ServiceCredentials__c.getInstance('BillingServiceCredential').Username__c;
			final String PASSWORD = ServiceCredentials__c.getInstance('BillingServiceCredential').Password__c;

			// list of valid projects passed from the trigger handler
			List<Project__c> validProjects = (List<Project__c>) JSON.deserialize(jsonProjectList, List<Project__c>.class);

			// projects that will be updated if the callout was successfully made
			List<Project__c> projectsToUpdate = new List<Project__c>();
			for (Project__c proj :validProjects) {
				BillingServiceProxy.project project = new BillingServiceProxy.project();
				project.projectid = proj.ProjectRef__c;
				project.billAmount = proj.Billable_Amount__c;
				project.username = USERNAME;
				project.password = PASSWORD;

				// make the SOAP callout
				String soapResponse = (new BillingServiceProxy.InvoicesPortSoap11()).billProject(project);

				// use '==' for case-insensitive string comparison
				if(soapResponse == 'OK') {
					//Project__c p = [SELECT Id, Status__c FROM Project__c WHERE ProjectRef__c = :project.projectid];
					proj.Status__c = 'Billed';
					projectsToUpdate.add(proj);
				}
			}

			if(projectsToUpdate.size() > 0) {
				update projectsToUpdate;
			}
		}
	}