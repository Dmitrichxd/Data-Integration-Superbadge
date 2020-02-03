@RestResource(urlMapping='/project/*')
global with sharing class ProjectRESTService {
    @HttpPost
    global static String postProjectData(String ProjectRef, 
									     String ProjectName, 
									     String OpportunityId, 
									     Date StartDate, 
									     Date EndDate, 
									     Double Amount, 
									     String Status) {
    
    Savepoint savePoint = Database.setSavepoint();
    try {
			Project__c project = new Project__c(Name = ProjectName, 
										    ProjectRef__c = ProjectRef, 
										    Opportunity__c = Id.valueOf(OpportunityId), 
										    Start_Date__c = StartDate, 
										    End_Date__c = EndDate, 
										    Billable_Amount__c = Amount, 
										    Status__c = Status);
			Upsert project;
			Opportunity opp = [SELECT Id, DeliveryInstallationStatus__c
							   FROM Opportunity
							   WHERE Id =: OpportunityId];
			opp.DeliveryInstallationStatus__c = 'In Progress';
			update opp;
			return 'OK';
		} 
		catch(Exception e) {
            Database.rollback(savePoint);
			return e.getMessage();
		}
	}
}