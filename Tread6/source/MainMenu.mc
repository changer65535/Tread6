//
// Copyright 2018 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi;
using Toybox.Graphics;

// This is delegate for the main page of our application that pushes the menu
// when the onMenu() behavior is received.
class MainMenuDelegate extends WatchUi.Menu2InputDelegate 
{
	var _treadmillProfile = null;
    function initialize(tp) 
    {
    	
       Menu2InputDelegate.initialize();
       _treadmillProfile = tp;
       
        
    }

    function onSelect(item) 
    {
    	if( item.getId().equals("workouts_fartlek") )
    	{
    		var fartlekView = new FartlekView(_treadmillProfile);
        	var fartlekDelegate = new FartlekDelegate(_treadmillProfile);
        	fartlekDelegate.parentView = fartlekView;
        	WatchUi.pushView(fartlekView, fartlekDelegate, WatchUi.SLIDE_UP);
    	}
    	
        if( item.getId().equals("workouts") ) 
        {
        	// Generate a new SUBMenu with a drawable Title
	        var menu = new WatchUi.Menu2({:title=>new DrawableMenuTitle(_treadmillProfile,"Workouts")});
	        menu.addItem(new WatchUi.MenuItem("Fartlek", null, "workouts_fartlek", null));
		    menu.addItem(new WatchUi.MenuItem("5K", null, "workouts_fiveK", null));
		    menu.addItem(new WatchUi.MenuItem("10K", null, "workouts_tenK", null));
		    menu.addItem(new WatchUi.MenuItem("Bruce", null, "workouts_bruce", null));
		    menu.addItem(new WatchUi.MenuItem("Gerber", null, "workouts_gerber", null));
	        
	        WatchUi.pushView(menu, new MainMenuDelegate(_treadmillProfile), WatchUi.SLIDE_UP );
	        
           
           
        }
        if (item.getId().equals("connect"))
        {
        	var connectView = new ConnectView(_treadmillProfile);
        	var connectDelegate = new ConnectViewDelegate(_treadmillProfile);
        	WatchUi.pushView(connectView, connectDelegate, WatchUi.SLIDE_UP);
        	
        	
        }
        if (item.getId().equals("freeRun"))
        {
        	var freerunView = new FreerunView(_treadmillProfile);
        	var freerunDelegate = new FreerunDelegate(_treadmillProfile);
        	freerunDelegate._parentView = freerunView;
        	WatchUi.pushView(freerunView, freerunDelegate, WatchUi.SLIDE_UP);
        	
        	
        }
        
    } 
}
class AppDelegate extends WatchUi.BehaviorDelegate 
{
	var _treadmillProfile = null;
    function initialize() 
    {
        BehaviorDelegate.initialize();  //The one and only!!
        _treadmillProfile = new TreadmillProfile();
        
        
    }

	function onSelect()
	{
		var q = 67;
	}
    function onMenu() 
    {
        
		// Generate a new Menu with a drawable Title
        var menu = new WatchUi.Menu2({:title=>new DrawableMenuTitle(_treadmillProfile,"Tread")});
        // Add menu items for demonstrating toggles, checkbox and icon menu items
        menu.addItem(new WatchUi.MenuItem("Connect", "to treadmill", "connect", null));
        menu.addItem(new WatchUi.MenuItem("Free Run", null, "freeRun", null));
            
        menu.addItem(new WatchUi.MenuItem("Workouts", null, "workouts", null));
        menu.addItem(new WatchUi.MenuItem("Settings", null, "settings", null));
        
        WatchUi.pushView(menu, new MainMenuDelegate(_treadmillProfile), WatchUi.SLIDE_UP );
        return true;
    }
}
