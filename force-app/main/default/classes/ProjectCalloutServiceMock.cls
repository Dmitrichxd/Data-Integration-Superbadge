@isTest
public class ProjectCalloutServiceMock implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest request) {
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setStatus('OK');
		response.setStatusCode(201);
		return response;
	}
}