using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Sensor;
using Toybox.Timer;
using Toybox.Application.Storage;

class FartlekDelegate extends WatchUi.BehaviorDelegate 
{
	var _treadmillProfile;
	var parentView = null;
	function initialize(tp)
	{
		BehaviorDelegate.initialize();
		_treadmillProfile = tp;
		//heart rate stuff maybe
		
		Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
    	Sensor.enableSensorEvents(method(:onSensor));
		
	}
	function onSensor(sensorInfo) 
	{
	    //System.println("Heart Rate: " + sensorInfo.heartRate);
	    parentView.heartRate = sensorInfo.heartRate;
	}
/*function timerCallback() 
{
    if (parentView.currentInterval == FartlekView.currentIntervalFast)
	{
		
		
	}
	else
	{
		
		
	}
}*/
	function onSelect () //the top right button, for changing field
	{
		parentView.cursor++;
		if (parentView.cursor > FartlekView.cursorSlowGrade) 
		{
			parentView.cursor = FartlekView.cursorExit;
		}
		WatchUi.requestUpdate();
		return true;
	}
	
	function onBack ()
	{
		
		System.println("Select pressed");
		parentView.currentInterval++;
		if (parentView.currentInterval > FartlekView.currentIntervalFast)
		{
		
			parentView.currentInterval = FartlekView.currentIntervalSlow;
		}
		
		if (parentView.currentInterval == FartlekView.currentIntervalFast)
		{
			_treadmillProfile.setSpeed(parentView.fastSpeed);
			_treadmillProfile.setIncline(parentView.fastGrade);
			
		}
		else
		{
			_treadmillProfile.setSpeed(parentView.slowSpeed);
			_treadmillProfile.setIncline(parentView.slowGrade);
			
		}
		//var myTimer = new Timer.Timer();
    	//myTimer.start(method(:timerCallback), 2000, false);
		
		return (true);	
	}
	function onPreviousPage ()
	{
		if (parentView.cursor == FartlekView.cursorExit) 
		{
			Storage.setValue("fastSpeed",parentView.fastSpeed);
			Storage.setValue("fastGrade",parentView.fastGrade);
			Storage.setValue("slowSpeed",parentView.slowSpeed);
			Storage.setValue("slowGrade",parentView.slowGrade);
			WatchUi.popView(WatchUi.SLIDE_UP);
			return;
		}
		if (parentView.cursor == FartlekView.cursorFastSpeed) 
		{
			parentView.fastSpeed -=0.1;
			if (parentView.currentInterval == FartlekView.currentIntervalFast) {_treadmillProfile.setSpeed(parentView.fastSpeed);}
			
		}
		if (parentView.cursor == FartlekView.cursorFastGrade) 
		{
			parentView.fastGrade -=0.1;
			if (parentView.currentInterval == FartlekView.currentIntervalFast) {_treadmillProfile.setIncline(parentView.fastGrade);}
			
		}
		if (parentView.cursor == FartlekView.cursorSlowSpeed) 
		{
			parentView.slowSpeed -=0.1;
			if (parentView.currentInterval == FartlekView.currentIntervalSlow) {_treadmillProfile.setSpeed(parentView.slowSpeed);}
			
		}
		if (parentView.cursor == FartlekView.cursorSlowGrade) 
		{
			parentView.slowGrade -=0.1;
			if (parentView.currentInterval == FartlekView.currentIntervalSlow) {_treadmillProfile.setIncline(parentView.slowGrade);}
		}
		WatchUi.requestUpdate();
	}
	
	function onNextPage ()
	{
		if (parentView.cursor == FartlekView.cursorExit) 
		{
			Storage.setValue("fastSpeed",parentView.fastSpeed);
			Storage.setValue("fastGrade",parentView.fastGrade);
			Storage.setValue("slowSpeed",parentView.slowSpeed);
			Storage.setValue("slowGrade",parentView.slowGrade);
			WatchUi.popView(WatchUi.SLIDE_UP);
		}
		if (parentView.cursor == FartlekView.cursorFastSpeed) 
		{
			parentView.fastSpeed +=0.1;
			if (parentView.currentInterval == FartlekView.currentIntervalFast) {_treadmillProfile.setSpeed(parentView.fastSpeed);}
		}
		if (parentView.cursor == FartlekView.cursorFastGrade) 
		{
			parentView.fastGrade +=0.1;
			if (parentView.currentInterval == FartlekView.currentIntervalFast) {_treadmillProfile.setIncline(parentView.fastGrade);}
		}
		if (parentView.cursor == FartlekView.cursorSlowSpeed) 
		{
			parentView.slowSpeed +=0.1;
			if (parentView.currentInterval == FartlekView.currentIntervalSlow) {_treadmillProfile.setSpeed(parentView.slowSpeed);}
		}
		if (parentView.cursor == FartlekView.cursorSlowGrade) 
		{
			parentView.slowGrade +=0.1;
			if (parentView.currentInterval == FartlekView.currentIntervalSlow) {_treadmillProfile.setSpeed(parentView.slowGrade);}
		}
		WatchUi.requestUpdate();
		
	}
	
	
}
class FartlekView extends WatchUi.View 
{
	private var _treadmillProfile;
	var heartRate;
	var slowSpeed = (Storage.getValue("slowSpeed") == null) ? 3.0f : Storage.getValue("slowSpeed");
	var slowGrade = (Storage.getValue("slowGrade") == null) ? 1.0f : Storage.getValue("slowGrade");
	var fastSpeed = (Storage.getValue("fastSpeed") == null) ? 7.0f : Storage.getValue("fastSpeed");
	var fastGrade = (Storage.getValue("fastGrade") == null) ? 3.0f : Storage.getValue("fastGrade");
	
	
	enum {currentIntervalSlow,currentIntervalFast}
	var currentInterval = currentIntervalSlow;
	enum {cursorExit,cursorFastSpeed,cursorFastGrade,cursorSlowSpeed,cursorSlowGrade}
	var cursor = cursorSlowGrade;
	
	
    function initialize(tp) 
    {
    	View.initialize();
    	_treadmillProfile = tp;
    	
        
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
        var padding = 2;
        var statusString = "EXIT";
        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_WHITE );
        dc.clear();
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var centerLeft = centerX / 2;
        var centerRight = (dc.getWidth() + centerX) / 2;
        var firstLine = centerY-70;
        var secondLine = firstLine + (dc.getHeight() - firstLine) / 3;
        var thirdLine =  firstLine + (dc.getHeight() - firstLine) * 2 / 3;
        dc.drawLine(0,firstLine,dc.getWidth(),firstLine);
        dc.drawLine(0,secondLine,dc.getWidth(),secondLine);
        dc.drawLine(0,thirdLine,dc.getWidth(),thirdLine);
        dc.drawLine(centerX,firstLine,centerX,dc.getHeight());
        //Text Stuff
        var fastFontSize = Graphics.FONT_NUMBER_MEDIUM;
        var slowFontSize = Graphics.FONT_SMALL;
        
        
        if (currentInterval == currentIntervalSlow)
        {
        	fastFontSize = Graphics.FONT_SMALL;
        	slowFontSize = Graphics.FONT_NUMBER_MEDIUM;
        }
        
        dc.drawText(centerX,(0 + firstLine) / 2,Graphics.FONT_SMALL,statusString,Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        dc.setColor( Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT );
        //labels
        dc.drawText(centerX-10,firstLine,Graphics.FONT_XTINY,"MPH",Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(centerX+10,firstLine,Graphics.FONT_XTINY,"Grade %",Graphics.TEXT_JUSTIFY_LEFT );
        
        dc.drawText(centerX-10,8+(firstLine + secondLine) / 2,fastFontSize,fastSpeed.format("%.1f"),Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX+10,8+(firstLine + secondLine) / 2,fastFontSize,fastGrade.format("%.1f"),Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        dc.setColor( Graphics.COLOR_RED, Graphics.COLOR_WHITE );
        //labels
        dc.drawText(centerX-10,secondLine,Graphics.FONT_XTINY,"MPH",Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(centerX+10,secondLine,Graphics.FONT_XTINY,"Grade %",Graphics.TEXT_JUSTIFY_LEFT);
        
        dc.drawText(centerX-10,8+(secondLine + thirdLine) / 2,slowFontSize,slowSpeed.format("%.1f"),Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX+10,8+(secondLine+ thirdLine) / 2,slowFontSize,slowGrade.format("%.1f"),Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_WHITE );
        dc.drawText(centerX-10,thirdLine ,Graphics.FONT_SMALL,"17:42",Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(centerX+10,thirdLine ,Graphics.FONT_SMALL,"HR: 67",Graphics.TEXT_JUSTIFY_LEFT);
        //handle the cursor
        var cursorX0 = 0,cursorY0 = 0,cursorX1 = 0,cursorY1 = 0;
        if (cursor == cursorExit)
        {
        	cursorX0 = centerX - 50;cursorY0=5;cursorX1=centerX + 50;cursorY1=firstLine - padding;
        }
        if (cursor == cursorFastSpeed)
        {
        	cursorX0 = centerX - 100;cursorY0=firstLine + padding;cursorX1=centerX -padding;cursorY1=secondLine - padding;
        }
        if (cursor == cursorFastGrade)
        {
        	cursorX0 = centerX + padding;cursorY0=firstLine + padding;cursorX1=centerX + 100;cursorY1=secondLine - padding;
        }
        if (cursor == cursorSlowSpeed)
        {
        	cursorX0 = centerX - 100;cursorY0=secondLine + padding;cursorX1=centerX - padding;cursorY1=thirdLine - padding;
        }
        if (cursor == cursorSlowGrade)
        {
        	cursorX0 = centerX + padding;cursorY0=secondLine + padding;cursorX1=centerX + 100;cursorY1=thirdLine - padding;
        }
        dc.setPenWidth(3);
        dc.drawRectangle(cursorX0,cursorY0,cursorX1-cursorX0+1,cursorY1-cursorY0+1);
        dc.setPenWidth(1);
        
        
    }

    // onHide() is called when this View is removed from the screen
    function onHide() 
    {
    }
}

    