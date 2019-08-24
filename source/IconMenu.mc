using Toybox.WatchUi;
using Toybox.Graphics;
/*
class IconMenu extends WatchUi.CustomMenu {
    function initialize(itemHeight, backgroundColor, options) {
        CustomMenu.initialize(itemHeight, backgroundColor, options);
    }

    function drawTitle(dc) {
        if( Toybox.WatchUi.CustomMenu has :isTitleSelected ) {
            if( isTitleSelected() ) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
                dc.clear();
            }
        }
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        dc.setPenWidth(3);
        dc.drawLine(0, dc.getHeight()-2, dc.getWidth(), dc.getHeight() - 2);
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_LARGE, "Smart Opener", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
*/
class CustomImagesItem extends WatchUi.CustomMenuItem {
    var device;

    function initialize(pDevice) {
    	self.device = pDevice;
    	var id = device[:id];
        CustomMenuItem.initialize(id, {});
      //  mLabel = label;
      //  mBitmap = bitmap;
      //  mBitmapOffset = 0 - bitmap.getWidth() / 2;
    }

    // draw the item string at the center of the item.
    function draw(dc) {
        var font;
       // var bmXY = dc.getHeight()/2 + mBitmapOffset;
        if( isFocused() ) {
            font = Graphics.FONT_LARGE;
        } else {
            font = Graphics.FONT_SMALL;
        }

        if(isSelected()) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
            dc.clear();
        }
        
        var icon = new IconDrawable(device);
        icon.setXY(20, -1);
        icon.draw(dc);

        //dc.drawBitmap(0, 0, mBitmap);
        var label = device[:name];
        var subLabel = device[:state];

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getHeight(), 0, font, label, Graphics.TEXT_JUSTIFY_LEFT) ;// | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(dc.getHeight(), dc.getHeight()/2, Graphics.FONT_TINY, subLabel, Graphics.TEXT_JUSTIFY_LEFT);// | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
