using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Sensor;

class FreerunDelegate extends WatchUi.BehaviorDelegate 
{
	var _treadmillProfile;
	var _parentView = null;
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
	    System.println("Heart Rate: " + sensorInfo.heartRate);
	    _parentView.heartRate = sensorInfo.heartRate;
	}
		



	
	function onSelect () //the top right button, for changing field
	{
		System.println("Select pressed");
		_parentView.selectedField++;
		if (_parentView.selectedField > FreerunView.selectedFieldIncline)
		{
			_parentView.selectedField = FreerunView.selectedFieldSpeed;
		}
		WatchUi.requestUpdate();
		return (true);
		
	}
	
	function onNextPage ()
	{
		System.println("Next pressed");
		if (_parentView.selectedField == _parentView.selectedFieldSpeed)
		{
			_treadmillProfile.setSpeed(_treadmillProfile.getSpeed() + 1);
		}
		if (_parentView.selectedField == _parentView.selectedFieldIncline)
		{
			_treadmillProfile.setIncline(_treadmillProfile.getIncline() + 1);
		}
		
	}
	function onPreviousPage ()
	{
		System.println("Previous Page pressed");
		if (_parentView.selectedField == _parentView.selectedFieldSpeed)
		{
			_treadmillProfile.setSpeed(_treadmillProfile.getSpeed() - 1);
		}
		if (_parentView.selectedField == _parentView.selectedFieldIncline)
		{
			_treadmillProfile.setIncline(_treadmillProfile.getIncline() - 1);
		}
		
	}
	
}
class FreerunView extends WatchUi.View 
{
	private var _treadmillProfile;
	enum {selectedFieldSpeed,selectedFieldIncline}
	
    var selectedField = selectedFieldSpeed;

	var cursor = 0;
	var heartRate = 0;
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
        var bkgnd;
        var statusString;
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var centerLeft = centerX / 2;
        var centerRight = (dc.getWidth() + centerX) / 2;
        var firstLine = centerY-70;
        var secondLine = centerY+15;
        var thirdLine = secondLine+30;
        

        if( _treadmillProfile.isConnected() ) 
        {
            statusString = "Treadmill OK";
        }
        else 
        {
            statusString = "Disconnected";
        }

        dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_WHITE );
        dc.clear();

        dc.drawText( dc.getWidth() / 2,13,Graphics.FONT_SMALL,statusString,Graphics.TEXT_JUSTIFY_CENTER);
		dc.drawLine (0,centerY+12,dc.getWidth(),centerY+12);
			dc.drawLine (0,thirdLine,dc.getWidth(),thirdLine);
			dc.drawLine (centerX,40,centerX,centerY+12);
        if( _treadmillProfile.isConnected() ) 
        {
           
			if (selectedField == selectedFieldSpeed) 
			{
			    dc.setColor( Graphics.COLOR_GREEN, Graphics.COLOR_WHITE );
			}
			else
			{
				dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_WHITE );
			}
			dc.drawText(centerLeft,firstLine,Graphics.FONT_SYSTEM_NUMBER_HOT,_treadmillProfile.getSpeed().format("%.1f"),Graphics.TEXT_JUSTIFY_CENTER);
			dc.drawText(centerLeft,firstLine + 55,Graphics.FONT_TINY,"mph",Graphics.TEXT_JUSTIFY_CENTER);
			
			if (selectedField == selectedFieldIncline) 
			{
			    dc.setColor( Graphics.COLOR_GREEN, Graphics.COLOR_WHITE );
			}
			else
			{
				dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_WHITE );
			}
			dc.drawText(centerRight,firstLine,Graphics.FONT_SYSTEM_NUMBER_HOT,_treadmillProfile.getIncline().format("%.1f"),Graphics.TEXT_JUSTIFY_CENTER);
			dc.drawText(centerRight,firstLine + 55,Graphics.FONT_TINY,"pct",Graphics.TEXT_JUSTIFY_CENTER);
			dc.setColor( Graphics.COLOR_BLACK, Graphics.COLOR_WHITE );
			dc.drawText(centerLeft,secondLine,Graphics.FONT_SYSTEM_SMALL,_treadmillProfile.getTotalDistance().format("%.1f")+ " miles",Graphics.TEXT_JUSTIFY_CENTER);
			
			dc.drawText(centerRight,secondLine,Graphics.FONT_SYSTEM_SMALL,_treadmillProfile.getElevationGain().format("%.1f")+ " ft",Graphics.TEXT_JUSTIFY_CENTER);
			
			dc.drawText(centerX,thirdLine,Graphics.FONT_SYSTEM_SMALL,
			_treadmillProfile.getRunningMets().format("%.1f") + " METs, " + "HR: " + heartRate
			,Graphics.TEXT_JUSTIFY_CENTER);
			
			
        }
        
    }

    // onHide() is called when this View is removed from the screen
    function onHide() 
    {
    }
}

    