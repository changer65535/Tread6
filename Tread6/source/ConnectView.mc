using Toybox.WatchUi;
using Toybox.Graphics;

class ConnectViewDelegate extends WatchUi.InputDelegate 
{
	var _treadmillProfile;
	function initialize(tp)
	{
		InputDelegate.initialize();
		_treadmillProfile = tp;
	}
}
class ConnectView extends WatchUi.View 
{
	private var _treadmillProfile;
    function initialize(tp) 
    {
    	View.initialize();
    	_treadmillProfile = tp;
        _treadmillProfile.scanFor(_treadmillProfile.FITNESS_MACHINE_SERVICE);
    }
    

    // Resources are loaded here
    function onLayout(dc) 
    {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // onShow() is called when this View is brought to the foreground
    function onShow() 
    {
    }

    // onUpdate() is called periodically to update the View
    function onUpdate(dc) 
    {
        View.onUpdate(dc);
        var backgroundColor = Graphics.COLOR_RED;
        var message = "Connecting";
        if (_treadmillProfile.isConnected())
        {
        	backgroundColor = Graphics.COLOR_GREEN;
        	message = "Connected!";
        	WatchUi.popView(WatchUi.SLIDE_UP);
        }
        dc.setColor(Graphics.COLOR_WHITE, backgroundColor);
        dc.clear();
        dc.drawText(dc.getWidth() / 2,dc.getHeight() / 2,Graphics.FONT_LARGE,message,Graphics.TEXT_JUSTIFY_CENTER);
    }

    // onHide() is called when this View is removed from the screen
    function onHide() 
    {
    }
}

    