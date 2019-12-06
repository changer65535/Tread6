using Toybox.WatchUi;
using Toybox.Graphics;
// This is the custom drawable we will use for our main menu title
class DrawableMenuTitle extends WatchUi.Drawable 
{
    
    var _title = null;
    var _treadmillProfile = null;

    function initialize(tp,title) 
    {
    	Drawable.initialize({});
    	_title = title;
    	_treadmillProfile = tp;
        
    }
    


    
    // Draw the application icon and main menu title
    function draw(dc) 
    {
        var spacing = 2;
        var appIcon = WatchUi.loadResource(Rez.Drawables.TreadIcon);
        if (_treadmillProfile != null)
        {
        	if (_treadmillProfile.isConnected() == true)
        	{
        		appIcon = WatchUi.loadResource(Rez.Drawables.TreadConnectedIcon);
        	}
        }
        
        
        var bitmapWidth = appIcon.getWidth();
        var labelWidth = dc.getTextWidthInPixels(_title, Graphics.FONT_MEDIUM);

        var bitmapX = (dc.getWidth() - (bitmapWidth + spacing + labelWidth)) / 2;
        var bitmapY = (dc.getHeight() - appIcon.getHeight()) / 2;
        var labelX = bitmapX + bitmapWidth + spacing;
        var labelY = dc.getHeight() / 2;

        var bkColor = Graphics.COLOR_BLACK;
        dc.setColor(bkColor, bkColor);
        dc.clear();

        dc.drawBitmap(bitmapX, bitmapY, appIcon);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(labelX, labelY, Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}