using Toybox.Communications;
using Toybox.Time;
using Toybox.Time.Gregorian;

class MyQCommunicator {
	//hidden var notify;
	private var securityToken = "";
	private var tokenRetry = 0;
	private var validDevices = {};
	private var accountId;
	private var controller;
	private var user;
	private var password;
	private var applicationId;
	
	function initialize(pController, pUser, pPassword, pBrand) {
		self.controller = pController;
		self.user = pUser;
		self.password = pPassword;
		var brand=0;
		if (pBrand != null) { brand = pBrand; }
		self.applicationId = brands[brand];
	}
	
	const brands = {
			0 => "OA9I/hgmPHFp9RYKJqCKfwnhh28uqLJzZ9KOJf1DXoo8N2XAaVX6A1wcLYyWsnnv", //Chamberlain
    		1 => "eU97d99kMG4t3STJZO/Mu2wt69yTQwM0WXZA5oZ74/ascQ2xQrLD/yjeVhEQccBZ", //craftsman
    		2 => "NWknvuBd7LoFHfXmKNMBcgajXtZEgKUh4V7WNzMidrpUUluDpVYVZx+xT4PCM5Kx", //liftmaster
    		3 => "3004cac4e920426c823fa6c2ecf0cc28ef7d4a7b74b6470f8f0d94d6c39eb718" //merlin
  	};
	
	const userAgent = "Chambrlain/3.73";
	const apiVersion = "4.1";
	const culture = "en";
	//const applicationId = "OA9I/hgmPHFp9RYKJqCKfwnhh28uqLJzZ9KOJf1DXoo8N2XAaVX6A1wcLYyWsnnv";
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
		getSecurityToken(method(:getAccountsRequest));	
	}
	
	function getAccountsRequest(r, d) {
		System.println("getaccountsrequest new:");
		makeRequest(:getAccounts, {}, method(:getAccountsResponse));
	}
	
	function getAccountsResponse(response, data) {
		System.println("accounts response: " + response);
		if (response  == 200) {
			accountId = data["Items"][0]["Id"];
			listDevicesRequest();
		} else {
			System.println("shouldn't be here if 200");
		}
	}
	
	function listDevicesRequest() {
		System.println("listDevicesRequest");
		makeRequest(:list, {}, method(:listDeviceResponse));
	}
	
	function changeDeviceState(device) {
		System.println("device state changing from:" + device[:state]);
		System.println(device);
		var stateToggle = null;
		for(var i = 0; i < myq_state_toggle.size(); i++) {
			var stateDetail = myq_state_toggle[i];
			for (var j = 0; j < stateDetail[:fromStates].size(); j++) {
				if (stateDetail[:fromStates][j].equals(device[:state])) {
					stateToggle = stateDetail;
				}
			}
		}
		
		if (stateToggle == null) {
			System.println("unknown action");
			return false;
			//controller.actionFailed();
		}
		
		toggleState(device, stateToggle);
		return true;
		//controller.deviceStateChange();
	}
	
	function toggleState(device, stateInfo) {
		device[:state] = stateInfo[:newState];
		//uncomment to work	
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
			controller.error("failed to submit request");
			System.println("error changing state, response:" + response);
		}
	}
	
	function listDeviceResponse(response, data) {
		System.println("list device response: " + response);
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
					var lastUpdate = getDateDifference(device["state"]["last_update"]);
					if (validDevices[deviceId] != null) {
						validDevices[deviceId][:state] = status;
						validDevices[deviceId][:name] = desc;
					} else {
						validDevices[deviceId] = { 
							:type => :myQ,  
							:name => desc, 
							:id => deviceId, 
							:state => status,
							:lastUpdate => lastUpdate
						};
					}
				} 
			}
		}

		System.println("devices: ");		
		controller.devicesLoaded(validDevices);
		System.println(validDevices);
	}
	
	function getDateDifference(formatDate) {
		System.println("formatDate:" + formatDate);
		var moment = convertToMoment(formatDate);
		var now = Time.now();
		var diff = now.subtract(moment);
		System.println("diff: " + diff);
		return diff;
	}
	
	function convertToMoment(formatDate) {
		//2019-08-28T01:55:20.8072708Z"
		System.println("year:" + formatDate.substring(0, 4).toNumber());
		System.println("month:" + formatDate.substring(5, 7).toNumber());
		System.println("day:" + formatDate.substring(8, 10).toNumber());
		System.println("hour:" + formatDate.substring(11, 13).toNumber());
		System.println("minute::" + formatDate.substring(14, 16).toNumber());
		System.println("second:" + formatDate.substring(17, 19).toNumber());
		
		var options = {
			:year => formatDate.substring(0, 4).toNumber(),
			:month => formatDate.substring(5, 7).toNumber(),
			:day => formatDate.substring(8, 10).toNumber(),
			:hour => formatDate.substring(11, 13).toNumber(),
			:minute => formatDate.substring(14, 16).toNumber(),
			:second => formatDate.substring(17, 19).toNumber(),
		};
		System.println("options:" + options);
		return Gregorian.moment(options);
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
    		case 401:
    			invalidCredentials(data);
    			break;
    		default:
    			failedLogin(responseCode, data);
    			break;
    			
    	}
    	return false;
    }
    
    hidden function loginSuccess(data) {
    	//notify.invoke("logged in!");
    	securityToken = data["SecurityToken"];	
    }
    
    hidden function invalidCredentials(data) {
    	System.println("Invalid login");
    	controller.error("Invalid User /\nPassword /\nBrand /\nCombination");
    }
    
    hidden function failedLogin(response, data) {
       	System.println("failed to login[" + response + "]: " + data);
    	controller.error("login failed\n" + response);
    }
 }