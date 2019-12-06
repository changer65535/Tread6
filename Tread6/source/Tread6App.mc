using Toybox.Application;
using Toybox.WatchUi;

class Tread6App extends Application.AppBase 
{
	var _treadmillProfile = null;
    function initialize() 
    {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) 
    {
    	
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() 
    {
        return [ new MainView(), new AppDelegate() ];
        
    }

}
