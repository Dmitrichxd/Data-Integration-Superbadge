@isTest
public class ProjectCalloutServiceMockFailure implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest request) {
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setStatus('sovsem ne OK');
		response.setStatusCode(500);
		return response;
	}
}