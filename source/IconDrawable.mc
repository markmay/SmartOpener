using Toybox.WatchUi;
using Toybox.Graphics;

class IconDrawable extends WatchUi.Drawable {
	hidden var device;
	hidden var iconX;
	hidden var iconY;

    function initialize(pDevice) {
    	self.device = pDevice;
        Drawable.initialize({});
        iconX = 0;
        iconY = 0;
    }
    
    function setXY(x, y) {
    	self.iconX = x;
    	self.iconY = y;
    }

    // Set the color for the current state and use dc.clear() to fill
    // the drawable area with that color
    function draw(dc) {
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    	var resourceId = null;
    	switch(device[:state]) {
    	/*	case "locked":
    			resourceId = Rez.Drawables.lockedIcon;
    			break;
    		case "unlocked":
    			resourceId = Rez.Drawables.unlockedIcon;
    			break;
    			*/
    		case "open":
    			resourceId = Rez.Drawables.openIcon;
    			break;
       		case "opening":
    			resourceId = Rez.Drawables.openingIcon;
    			break;
			case "closed":
    			resourceId = Rez.Drawables.closedIcon;
    			break;
			case "closing":
			default:
				resourceId = Rez.Drawables.closingIcon;
				break;
		}
				
		var icon = new WatchUi.Bitmap({
			:rezId => resourceId,
			:locX => iconX,
			:locY => iconY
		});
		
		if (iconY == -1) {
			var iconHeight = icon.height;
			var newY =  (dc.getHeight() - iconHeight) / 2;
			icon.setLocation(iconX, newY);
		}
		icon.draw(dc);
    }
}