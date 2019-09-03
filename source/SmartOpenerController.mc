using Toybox.Communications;
using Toybox.Application.Storage;

class SmartOpenerController {
	hidden var viewWeak;
	hidden var communicators;
	hidden var devices;
	hidden var currentDevice;
	
	function initialize() { }
	
	function dirtyInitialize(view, pCommunicators) {
		self.viewWeak = view.weak();
		self.communicators = pCommunicators;
		loadDevices();
	}	
	
	function loadDevices() {
		var view = viewWeak.get();
		if (isConnectionAvailable()) {
			view.setConnectionStatus(true);
			devices = getStoredDevices();
			currentDevice = null;
			view.notify("Loading");
			var keys = communicators.keys();
			var size = keys.size();
			if (size == 0) { 
				view.notify("No User /\nPassword\nsetup"); 
			}
			for (var i = 0; i < size; i++) {
				var key = keys[i];
				var communicator = communicators[key];
				communicator.loadDevices();
			}
		} else {
			view.notify("Unavailable");
			view.setConnectionStatus(false);
		}
	}
	
	function isConnectionAvailable() {
		var info = System.getDeviceSettings();
		if (info has :connectionAvailable) {
			return info.connectionAvailable;
		}
		return info.phoneConnected;
	}
	
	function getStoredDevices() {
		/*if (Storage has :getValue) {
			System.println("retreiving devices");
			var storedDevices = Toybox.Application.Storage.getValue("devices");
			System.println("saved value:" + storedDevices);
			if (storedDevices instanceof Toybox.Lang.Dictionary) {
				return storedDevices;
			}
		}*/
		return {};
	}
	
	function saveStoredDevices() {
	/*
		if (Storage has :setValue) {
			//System.println("Devices stored");
			//Toybox.Application.Storage.setValue("devices", devices);
		}
		*/
	}
	
	function devicesLoaded(loadedDevices) {
		var view = viewWeak.get();
		var keys = loadedDevices.keys();
		var size = keys.size();
		for (var i = 0; i < size; i++) {
			var key = keys[i];
			var device = loadedDevices[key];
			devices[key] = device;
		}
		
		view.notify("devices loaded");
		view.devicesLoaded(devices);
		displayDeviceStates();
		saveStoredDevices();
	}
	
	function displayDeviceStates() {
		var view = viewWeak.get();
		var keys = devices.keys();
		var deviceDetails = "";
		for (var i = 0; i < keys.size(); i++) {
			var key = keys[i];
			var device = devices[key];
			deviceDetails += device[:name] + "\n" + device[:state] + "\n";
		}
		view.notify(deviceDetails);
	}
	
	function selectPressed() {
		if (devices.size() == 1) {
			var device = devices[devices.keys()[0]];
			changeDeviceState(device);
		} else {
			var view = viewWeak.get();
			view.showMenu();
		}
	}
	
	function changeDeviceStateById(deviceId) {
		System.println("deviceId to change: " + deviceId);
		changeDeviceState(getDeviceById(deviceId));
	}
	
	function getDeviceById(deviceId) {
		var deviceKeys = devices.keys();
		for(var i = 0; i < deviceKeys.size(); i++) {
			var device = devices[deviceKeys[i]];
			if (device[:id].equals(deviceId)) {
				return device;
			}
		}
		System.println("device not found: " + deviceId);
		return false;
	}
	
	function changeDeviceState(device) {
		var communicator = communicators[device[:type]];
		var view = viewWeak.get();
		System.println(communicator);
		if (communicator.changeDeviceState(device)) {
			System.println("request submitted");
			view.update();				
		} else {
			System.println("cannot make request");
		}
	}
	
	function error(message) {
		var view = viewWeak.get();
		view.notify(message);
	}
	
	function deviceStateChange() {
		var view = viewWeak.get();
		view.notify("Device state changed");
		view.update();
	}
}