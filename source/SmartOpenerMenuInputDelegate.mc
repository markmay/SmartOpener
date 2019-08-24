using Toybox.WatchUi;
using Toybox.System;

class SmartOpenerMenuInputDelegate extends WatchUi.MenuInputDelegate {
	hidden var controller;
    function initialize(controller) {
    	self.controller = controller;
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {    
        System.println(item);
        controller.changeDeviceStateById(item);
    }
}