using Toybox.Communications;

class CommunicationWrapper {

	hidden var url;
	hidden var parameters;
	hidden var options;
	hidden var responseCallback;
	hidden var successCallback;
	hidden var retryCount;
	hidden var attempts = 0;
	
	function initialize(url, parameters, options, responseCallback, successCallback, retryCount) {
		self.url = url;
		self.parameters = parameters;
		self.options = options;
		self.responseCallback = responseCallback;
		self.successCallback = successCallback;
		self.retryCount = retryCount;
	}
	
	function makeRequest() {
		attempts = 0;
		makeCommunicationRequest();
	}
	
	hidden function makeCommunicationRequest() {
		attempts++;
		
		System.println( "Making Request to: " + url );
		//System.println( "Parameters: " + parameters );
		//System.println( "options: " + options );
		System.println("");
		
		Communications.makeWebRequest(url, parameters, options, method(:wrappingCallback));
	}
	
	function wrappingCallback(response, data) {
		System.println("response:" + response);
	//	System.println(data);
		if (responseCallback.invoke(response, data)) {
			if (successCallback != null) {
				successCallback.invoke(response, data);
			}
		} else {
			if (retryCount >= attempts) {
				makeCommunicationRequest();
			}	
		}
	}
}

class CommunicationWrapper2 {

	hidden var requests;
	hidden var url;
	hidden var parameters;
	hidden var options;
	hidden var responseCallback;
	hidden var successCallback;
	hidden var retryCount;
	hidden var commIndex; 
	//attempts = 0;
	
	function initialize(requests) {
	//url, parameters, options, responseCallback, successCallback, retryCount) {
		self.requests = requests;
		self.parameters = parameters;
		self.options = options;
		self.responseCallback = responseCallback;
		self.successCallback = successCallback;
		self.retryCount = retryCount;
	}
	
	function makeRequest() {
		attempts = 0;
		makeCommunicationRequest();
	}
	
	hidden function makeCommunicationRequest() {
		var request = requests[commIndex];
		request[:attempts]++;
		//attempts++;
		
		System.println( "Making Request to: " + request[:url] );
		System.println( "Parameters: " + request[:parameters] );
		System.println( "options: " + request[:options] );
		
		Communications.makeWebRequest(request[:url], request[:parameters], requests[:options], method(:wrappingCallback));
	}
	
	function wrappingCallback(response, data) {
		var request = requests[commIndex];
		var responseCallback = request[:responseCallback];

		System.println("response:" + response);
		System.println(data);
		if (request[:responseCallback].invoke(response, data)) {
			if (successCallback != null) {
				successCallback.invoke(response, data);
			}
		} else {
			if (retryCount >= attempts) {
				makeCommunicationRequest();
			}	
		}
	}
}