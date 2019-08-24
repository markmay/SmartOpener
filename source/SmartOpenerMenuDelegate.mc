using Toybox.WatchUi;
using Toybox.System;

class SmartOpenerMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        System.println(item.getId());
    }
}