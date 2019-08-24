/*
using Toybox.Communications;

class AugustCommunicator {
	//hidden var notify;
	private var securityToken = "";
	private var tokenRetry = 0;
	private var validDevices = {};
	private var accountId;
	private var controller;
	
	function initialize(pController, user, password, token) {
		self.controller = pController;
	}
	
	const userAgent = "Chambrlain/3.73";
	const apiVersion = "4.1";
	const culture = "en";
	const applicationId = "OA9I/hgmPHFp9RYKJqCKfwnhh28uqLJzZ9KOJf1DXoo8N2XAaVX6A1wcLYyWsnnv";
	const baseUrl = "https://api.myqdevice.com/api/v5/";
	const apiDetails = {
		:validate => {
			:url => "Login",
			:method => Communications.HTTP_REQUEST_METHOD_POST,
			:contentType => Communications.REQUEST_CONTENT_TYPE_JSON,
			:retry => 1
		},
		:getAccounts => {
			:url => "accounts",
			:method => Communications.HTTP_REQUEST_METHOD_GET,
		},
		:list => {
			:url => "accounts/$1$/Devices",
			:method => Communications.HTTP_REQUEST_METHOD_GET,
		},
		:setState => {
			:url => "accounts/$1$/Devices/$2$/actions",
			:method => Communications.HTTP_REQUEST_METHOD_PUT,
			:contentType => Communications.REQUEST_CONTENT_TYPE_JSON,
		},
	};
	
	const myq_state_toggle = [
							   { :fromStates => ["open"], :action => "close", :state => "closed", :newState => "closing" },
    						   { :fromStates => ["closed"], :action => "open", :state => "opened", :newState => "opening" }
    						 ];
	
	function loadDevices() {
		var testDevices = {
			1 => { :type => :august, :name => "Garage 1", :id => 1, :state => "open" },
			2 => { :type => :august, :name => "Garage 2", :id => 2, :state => "closed" },
			3 => { :type => :august, :name => "Gate", :id => 3, :state => "closed" }	
		};
		var testDevices2 = {
			1 => { :type => :august, :name => "Garage Door", :id => 1, :state => "closed" },
		};
		controller.devicesLoaded(testDevices2);
		//getSecurityToken(method(:getAccountsRequest));	
	}
	
	function getAccountsRequest(r, d) {
		makeRequest(:getAccounts, {}, method(:getAccountsResponse));
	}
	
	function getAccountsResponse(response, data) {
		if (response  == 200) {
			accountId = data["Items"][0]["Id"];
			listDevicesRequest();
		}
	}
	
	function listDevicesRequest() {
		var params = { };
		makeRequest(:list, params, method(:listDeviceResponse));
	}
	
	function changeDeviceState(device) {
		System.println("device state changing from:" + device[:state]);
		System.println(device);
		if (device[:state].equals("closed") || device[:state].equals("closing")) { 
			device[:state] = "opening"; 
		} else {
			device[:state] = "closing";
		}
		return true;
		//controller.deviceStateChange();
	}
	
	function toggleState(device, stateInfo) {
		device[:state] = stateInfo[:newState];
		setStateRequest(stateInfo[:action], device[:id]);
	    var timer = new Timer.Timer();
    	timer.start(method(:listDevicesRequest), 20000, false);
	}
	
	function setStateRequest(state, deviceId) {
		var params = {
			"action_type" => state, 
		};
		makeRequest2(:setState, params, method(:setStateResponse), null, deviceId);
	}
	
	function setStateResponse(response, data) {
		if (response == 204) {
			controller.deviceStateChange();
			System.println("device state changed");
		}
		else {
			controller.error("failed to change");
			System.println("error changing state, response:" + response);
		}
	}
	
	function listDeviceResponse(response, data) {
		if (response == 200) {
			//notify.invoke("devicelist");
			var devices = data["items"];
			var deviceCount = devices.size();
			for (var i = 0; i < deviceCount; i++) {
				var device = devices[i];
				if (validDevice(device)) {
					var deviceId = device["serial_number"];
					var status = device["state"]["door_state"];
					var desc = device["name"];
					if (validDevices[deviceId] != null) {
						validDevices[deviceId][:state] = status;
						validDevices[deviceId][:name] = desc;
					} else {
						validDevices[deviceId] = { :type => :myQ,  :name => desc, :id => deviceId, :state => status };
					}
				} 
			}
		}
		
		controller.devicesLoaded(validDevices);
		System.println("devices: ");
		System.println(validDevices);
	}
	
	function validDevice(device) {
		var deviceState = device["state"];
		if (deviceState["online"]) {
			if(deviceState["is_unattended_open_allowed"]) {
				return true;
			}
		}
		return false;
	}
	
	function getSecurityToken(callback) {
		var user = Application.getApp().getProperty("myQUserName");
		var password = Application.getApp().getProperty("myQPassword");
		if (self.securityToken.equals("")) {	
	       var body = {
				"username" => user,
				"password" => password
			};
			
			makeRequestCB(:validate, body, method(:securityTokenCallback), callback);
		} else {
			callback.invoke();
		}
    }
    
    function makeRequest(type, params, callback) {
    	return makeRequest2(type, params, callback, null, null);
    }
        
    function makeRequestCB(type, params, callback, successCallback) {
    	return makeRequest2(type, params, callback, successCallback, null);
    }
    
    function makeRequest2(type, params, callback, successCallback, deviceId) {
    	var data = apiDetails[type];
    	var url = baseUrl + Lang.format(data[:url], [ self.accountId, deviceId ]);
    	var method = data[:method];
    	var contentType = data[:contentType];
    	if (contentType == null) { contentType = Communications.HTTP_RESPONSE_CONTENT_TYPE_URL_ENCODED; }
    	var options = {
           :method => data[:method],     
           :headers => {
           		"Content-Type" => contentType,
                "User-Agent" => userAgent,
                "MyQApplicationId" => applicationId,
                "Culture" => culture,
                "ApiVersion" => apiVersion,
                "SecurityToken" => securityToken
           },
           :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON 
       };
       var retry = data[:retry];
       if (!(retry instanceof Toybox.Lang.Number)) {
       		retry = 0;
       }
       
		var wrapper = new CommunicationWrapper(url, params, options, callback, successCallback, retry);
		wrapper.makeRequest();
    }
        
    function securityTokenCallback(responseCode, data) {
    	switch(responseCode) {
    		case 200:
    			loginSuccess(data);
    			return true;
    			break;
    		case 203:
    			invalidCredentials(data);
    			break;
    		default:
    			failedLogin(data);
    			break;
    			
    	}
    	return false;
    }
    
    hidden function loginSuccess(data) {
    	//notify.invoke("logged in!");
    	securityToken = data["SecurityToken"];	
    }
    
    hidden function invalidCredentials(data) {
    	System.println("invalid credentials");
    }
    
    hidden function failedLogin(data) {
    	System.println("failed to login");
    }
 }
/**/ 