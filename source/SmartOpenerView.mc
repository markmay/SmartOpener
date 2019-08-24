using Toybox.Graphics;
using Toybox.WatchUi;

class SmartOpenerView extends WatchUi.View {
    hidden var mMessage = "";
    hidden var connectionStatus;
    hidden var mModel;
    hidden var controller;
    hidden var menu;
    hidden var devices;

    function initialize(controller) {
        WatchUi.View.initialize();
        self.controller = controller;
    }
    
    function setConnectionStatus(status) {
    	connectionStatus = status;       
    }
    
    function showMenu() {
    	if (devices == null) { return; }
    	if (WatchUi has :CustomMenu) {
    	    menu = new CustomMenu(60, Graphics.COLOR_BLACK, {:focusItemHeight  => 70});
	        var delegate;
	        var keys = devices.keys();
	        for(var i = 0; i < keys.size(); i++) {
	        	var deviceKey = keys[i];
	        	var device = devices[deviceKey];
	        	System.println( device);
				menu.addItem(deviceMenu2Item(device));
	        }
	       
	        delegate = new SmartOpenerMenu2InputDelegate(controller); // a WatchUi.Menu2InputDelegate
	        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
	        return true;
        }
        else {
        	System.println("backup menu");
   	        menu = new WatchUi.Menu(); 
   	        menu.setTitle("Smart Opener");
	        var delegate;
	        var keys = devices.keys();
	        for(var i = 0; i < keys.size(); i++) {
	        	var deviceKey = keys[i];
	        	var device = devices[deviceKey];
	        	System.println( device);
				menu.addItem(
				       device[:name] + "\n" + device[:state],
				       device[:id]
				);
	        }
	       
	        delegate = new SmartOpenerMenuInputDelegate(controller); // a WatchUi.Menu2InputDelegate
	        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
	        return true;       
        }
    }
    
    function deviceMenu2Item(device) {
    	var icon = new IconDrawable(device);
    	return new CustomImagesItem(device);
    }

    // Load your resources here
    function onLayout(dc) {
        return true;
    }
    
    function devicesLoaded(devices) {
    	self.devices = devices;
    	WatchUi.requestUpdate();
    }

    // Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    	dc.clear();
    	if (!connectionStatus) {
    		showNoConnection(dc);
    	} 
    	if (devices == null) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        	dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_MEDIUM, mMessage, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
        	displayAllDevices(dc);
        }
	}
	
	function showNoConnection(dc) {
	 	dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_BLACK);
	 	dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight() / 6);
	 	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_DK_RED); 
		dc.drawText(dc.getWidth()/2, dc.getHeight()/12, Graphics.FONT_SMALL, "!", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);	
	}
	
	function displayAllDevices(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var deviceKeys = devices.keys();
        var deviceCount = deviceKeys.size();
        for(var i = 0; i < deviceCount; i++) {
        	var deviceKey = deviceKeys[i];
        	var device = devices[deviceKey];
        	displayDevice(dc, device, i, deviceCount);
        }
    }
    
    function displayDevice(dc, device, i, deviceCount) {
    	var yOffset = dc.getHeight() / 6;
    	var imageX = dc.getWidth() / 7;
    	//var x = dc.getWidth() / 2;
    	var y = yOffset + dc.getHeight() * i / 6;
    	var imageY = y + 6;

		var icon = new IconDrawable(device);
		icon.setXY(imageX, imageY);
		icon.draw(dc);
		
    	var textX = imageX + 34; //icon.width + 10;
    	var text = device[:name];// + "\n" + device[:state];
   		dc.drawText(textX, y, Graphics.FONT_MEDIUM, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

    // Called when this View is removed from the screen. Save the
    // state of your app here.
    function onHide() {
    }
    
    function update() {
    	WatchUi.requestUpdate();
    }

    function notify(args) {
        if (args instanceof Lang.String) {
            mMessage = args;
            System.println("notify: " + mMessage);
        }
        else if (args instanceof Dictionary) {
            // Print the arguments duplicated and returned by jsonplaceholder.typicode.com
            var keys = args.keys();
            mMessage = "";
            for( var i = 0; i < keys.size(); i++ ) {
                mMessage += Lang.format("$1$: $2$\n", [keys[i], args[keys[i]]]);
            }
        }
        WatchUi.requestUpdate();
    }
}
