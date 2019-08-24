using Toybox.WatchUi;
using Toybox.System;

class SmartOpenerMenu2InputDelegate extends WatchUi.Menu2InputDelegate {
	hidden var controller;
    function initialize(controller) {
    	self.controller = controller;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        System.println(item.getId());
        controller.changeDeviceStateById(item.getId());
    }
}