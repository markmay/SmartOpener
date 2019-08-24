using Toybox.Communications;
using Toybox.WatchUi;

class SmartOpenerBehaviorDelegate extends WatchUi.BehaviorDelegate {
    hidden var controller;

    // Handle menu button press
    function onMenu() {
       // makeRequest();
        return true;
    }

    function onSelect() {
    	System.println("select pressed");
        controller.selectPressed();
        return true;
    }

    // Set up the callback to the view
    function initialize(controller) {
        WatchUi.BehaviorDelegate.initialize();
		self.controller = controller;
    }
}