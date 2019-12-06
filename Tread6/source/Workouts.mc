using Toybox.WatchUi;
class WorkoutsMenuDelegate extends WatchUi.Menu2InputDelegate 
{
	private var _treadmillProfile = null;
    function initialize(tp) 
    {
        Menu2InputDelegate.initialize();
        _treadmillProfile = tp;
    }
    function onSelect(item) 
    {
        if( item.getId().equals("workouts") ) 
        {
        	
        }
    } 
}


class Workouts
{
	private var _treadmillProfile;
	function initialize(tp)
	{
		_treadmillProfile = tp;
		var menu = new WatchUi.Menu2({:title=>new DrawableMenuTitle(_treadmillProfile,"Workouts")});
	    // Add menu items for demonstrating toggles, checkbox and icon menu items
	    menu.addItem(new WatchUi.MenuItem("Workout", null, "Workout", null));
	    menu.addItem(new WatchUi.MenuItem("5K", null, "fiveK", null));
	    menu.addItem(new WatchUi.MenuItem("10K", null, "tenK", null));
	    menu.addItem(new WatchUi.MenuItem("Bruce", null, "settings", null));
	    menu.addItem(new WatchUi.MenuItem("Gerber", null, "settings", null));
	        
	    WatchUi.pushView(menu, new MainMenuDelegate(), WatchUi.SLIDE_UP );
	}
	

}