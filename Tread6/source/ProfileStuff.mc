using Toybox.System as Sys;
using Toybox.WatchUi;
using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Lang;


class TreadmillProfile
{
    private var _bleDelegate;

    
    var _device;
    private var _profileManagerStuff;
    private var _rawSpeed = 0l;
    private var _rawIncline = 0l;
    private var _speed = 0;  
    private var _incline = 0;
    private var _totalDistance = 0;
    private var _elevationGain = 0;
    private var _totalEnergy = 0;
    
    //offsets;
    private var _speedOffset = 2;
    private var _averageSpeedOffset = 4;
    private var _totalDistanceOffset = 6;
    private var _inclineOffset = 9;
    private var _rampAngleOffset = 11;
    private var _positiveElevationGainOffset = 13;
    private var _negativeElevationGainOffset = 15;
    private var _totalEnergyOffset = 19;
    private var _isConnected = false;
    
    private var stack = new[0];
    
    //
    var scanForUuid = null;
    var writeBusy = false;
    
    

	public function wordToUuid(uuid)
	{
		
		return Ble.longToUuid(0x0000000000001000l + ((uuid & 0xffff).toLong() << 32), 0x800000805f9b34fbl);
	}
    
    
	public const FITNESS_MACHINE_SERVICE 	   			= wordToUuid(0x1826);
	public const TREADMILL_DATA_CHARACTERISTIC 			= wordToUuid(0x2acd);
	public const FITNESS_MACHINE_FEATURE_CHARACTERISTIC = wordToUuid(0x2acc);
	public const TREADMILL_CONTROL_POINT 				= wordToUuid(0x2ad9);
	
	
	
	function isConnected()
	{
		return _isConnected;
	}
	
    function getRawSpeed() 
    {
        return _rawSpeed;
    }
    function getSpeed() 
    {
        return _speed;
    }

	function getRawIncline() 
    {
        return _rawIncline;
    }
    function getIncline() 
    {
        return _incline;
    }
    
   	function getRunningMets()
   	{
   		var mpm = _speed * 26.8224;
    	return (0.2 * mpm + 0.9 * mpm * _incline/100 + 3.5)/3.5;
   	}
   

    
    function getTotalDistance() 
    {
        return _totalDistance;
    }
    function getElevationGain() 
    {
        return _elevationGain;
    }
    private const _fitnessProfileDef = 
    {
    	:uuid => FITNESS_MACHINE_SERVICE,				
        :characteristics => [
        {
            :uuid => TREADMILL_DATA_CHARACTERISTIC,:descriptors => [Ble.cccdUuid()]
        },
        {
        	:uuid => FITNESS_MACHINE_FEATURE_CHARACTERISTIC				
            
        },
        {
        	:uuid => TREADMILL_CONTROL_POINT				
        	
        }]
    };
 
    function unpair() 
    {
        Ble.unpairDevice( _device );
        _device = null;
        System.println("Unpaired");
    }
    
    function scanFor (serviceToScanFor)
    {
        
        System.println("ScanMenuDelegate.starting scan");
        scanForUuid = serviceToScanFor;
        Ble.setScanState( Ble.SCAN_STATE_SCANNING );
    }

	function initialize ()
	{
	  Ble.registerProfile( _fitnessProfileDef );
	  _bleDelegate = new TreadmillDelegate(self);  //pass it this
	  Ble.setDelegate( _bleDelegate );
	 
	}
	
	private function activateNextNotification() 
    {
    	var service = _device.getService(_parent.FITNESS_MACHINE_SERVICE );	
        var characteristic = service.getCharacteristic(_parent.TREADMILL_DATA_CHARACTERISTIC);
        var cccd = characteristic.getDescriptor(Ble.cccdUuid());
        cccd.requestWrite([0x01, 0x00]b);
    	
    }
    function pushWrite(obj)   //need this so BLE doesn't throw exception if two writerequests come-in before BLE can process them
	{	
		stack.add(obj);
		handleStack();
	}
    function handleStack()
    {
    	if (stack.size() == 0) {return;} // nothing to do
    	if (writeBusy == true) {return;}// already busy.  nothing to do
    	
    	var characteristic = _device.getService(FITNESS_MACHINE_SERVICE ).getCharacteristic(TREADMILL_CONTROL_POINT);
		try
		{
			writeBusy = true;
			characteristic.requestWrite(stack[0],{:writeType=>BluetoothLowEnergy.WRITE_TYPE_DEFAULT});
		
		
		   //characteristic.requestRead();
		}
		catch (ex)
		{
			System.println("EXCEPTION: " + ex.getErrorMessage());
		}
    }
    function onCharacteristicWrite(char, value)    //called after write is complete
    {
    	System.println("**callback characteristic Write.  SI: " + stack.size() + "Characteristic: " + char + ".  Value: " + value);
    	if (stack.size() == 0) 
    	{
    		System.println("onCharasteristic write called in error si=0");
    		return;
    	}
    	writeBusy = false;
    	
    	stack = stack.slice(1,null);
    	if (stack.size() > 0) {handleStack();}
       //pop-off
    	var ch = char;
    	var v = value;
    	
    }
    function onCharacteristicRead(char, value) 
    {
    	var ch = char;
    	var v = value;
    	
    }
	function onCharacteristicChanged(char, value)
	{
		var name = _device.getName();
		var cu = char.getUuid();
		
		if (cu.equals(TREADMILL_DATA_CHARACTERISTIC))
		{
			_rawSpeed = value.decodeNumber( Lang.NUMBER_FORMAT_UINT16, { :offset => _speedOffset });
			_speed = _rawSpeed / 100.0f * 0.621371192f;
			_rawIncline = value.decodeNumber( Lang.NUMBER_FORMAT_UINT16, { :offset => _inclineOffset });
	        _incline = _rawIncline / 10.0f;
	        
	        var temp = value.decodeNumber( Lang.NUMBER_FORMAT_UINT32, { :offset => _totalDistanceOffset });
	        temp = temp & 0x00ffffff;
	        _totalDistance = temp  *  0.000621371f;
	        _elevationGain = value.decodeNumber( Lang.NUMBER_FORMAT_UINT16, { :offset => _positiveElevationGainOffset }) / 10.0f * 3.28084f ;
	        //_totalEnergy   = value.decodeNumber( Lang.NUMBER_FORMAT_UINT16, { :offset => _totalEnergyOffset }) / 10;
	        //System.println(_totalEnergy);
	        WatchUi.requestUpdate();
	         
		}
		
		
	}
	
	function setSpeed ( speed )
    {
	    if (speed < 0) {speed = 0;}
	    if (speed > 12) {speed = 12;}
        var kph = speed * 160.934;
        var long1 = kph.toLong();//convert to kph and multiply by one humdred
        var b1 = [0x02,0,0]b;   //starting with 2 means set speed
        b1.encodeNumber(long1,Lang.NUMBER_FORMAT_UINT16,{:offset=>1,:endianness=>Lang.ENDIAN_LITTLE});
        
       	System.println("speed");
        pushWrite(b1);
    }
    function setIncline ( incline )
    {
        var incl = incline * 10.0;
        var long1 = incl.toLong();//convert to kph and multiply by one humdred
        var b1 = [0x03,0,0]b;   //starting with 2 means set speed
        b1.encodeNumber(long1,Lang.NUMBER_FORMAT_UINT16,{:offset=>1,:endianness=>Lang.ENDIAN_LITTLE});
        
       	System.println("incline");
       	pushWrite(b1);
    }
	
	
	
	function onConnectedStateChanged( device, state )
	{
		if (state == Ble.CONNECTION_STATE_CONNECTED)
		{
			_isConnected = true;
			WatchUi.requestUpdate();
			_device = device;
	    	System.println("BleDelegate.onConnectedStateChanged");
	    	var service = device.getService(FITNESS_MACHINE_SERVICE );
	    	
	        var characteristic = service.getCharacteristic(TREADMILL_DATA_CHARACTERISTIC);
	        var cccd = characteristic.getDescriptor(Ble.cccdUuid());
	        cccd.requestWrite([0x01, 0x00]b);
	    }
	    if (state == Ble.CONNECTION_STATE_DISCONNECTED)
	    {
	    	_isConnected = false;
	    	System.println("Disconnected");
	    }
	}
	
	private function contains( iter, obj ) 
    {
        for( var uuid = iter.next(); uuid != null; uuid = iter.next() ) 
        {
            if( uuid.equals( obj ) ) 
            {
                return true;
            }
        }
        return false;
    }
	function onScanResults (scanResults)
	{
		System.println("BleDelegate.onScanResults");
    	
    	//var rssi = scanResults.getRssi();
    	
    	for( var result = scanResults.next(); result != null; result = scanResults.next() ) 
        {
            if( contains( result.getServiceUuids(), scanForUuid ) ) 
            {
            
            		
        		 Ble.setScanState( Ble.SCAN_STATE_OFF );
    			var d = Ble.pairDevice( result );
            }
        }
    
	}
	function onDescriptorWrite(descriptor, status) 
    {
       
       
    }
	
	
    

    

    

    /*
    
    
    
    
    

function onDescriptorWrite(descriptor, status) 
    {
        if( Ble.cccdUuid().equals( descriptor.getUuid() ) ) 
        {
            processCccdWrite( status );
        }
        else
        {
        
        }
    }


    private function processCccdWrite( status ) 
    {
        if( _pendingNotifies.size() > 1 ) 
        {
            _pendingNotifies = _pendingNotifies.slice(1,_pendingNotifies.size() );
			activateNextNotification();
        }
        else {
            _pendingNotifies = [];
        }
    }
   

    */

    
   
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


class TreadmillDelegate extends Ble.BleDelegate 
{
    
	var _parent = null;
	
    function initialize(parent  ) 
    {
    	BleDelegate.initialize();
    	_parent = parent;
    	System.println("BleDelegate.initialize");
    }
    
    function onScanResults( scanResults ) 
    {
	    if (_parent != null)
	    {
	    	_parent.onScanResults(scanResults);
	    }
	}
    

    function onConnectedStateChanged( device, state ) 
    {
	    if (_parent != null)
		{
			_parent.onConnectedStateChanged(device, state);
		}
	   		 
        
    }

    
    

    function onCharacteristicChanged(char, value) 
    {
    	BleDelegate.onCharacteristicChanged(char, value);
    	//System.println("**callback characteristic Changed");
    	if (_parent != null)
    	{
    		_parent.onCharacteristicChanged(char, value);
    	}
    	
    }
    function onCharacteristicRead(char, value) 
    {
    	BleDelegate.onCharacteristicRead(char, value);
    	System.println("**callback characteristic Read");
    	if (_parent != null)
    	{
    		_parent.onCharacteristicRead(char, value);
    	}
    	
    }
    function onCharacteristicWrite(char, value) 
    {
    	BleDelegate.onCharacteristicChanged(char, value);
    	
    	if (_parent != null)
    	{
    		_parent.onCharacteristicWrite(char, value);
    	}
    	
    }
    function onDescriptorWrite(descriptor, status) 
    {
    	System.println("**callback DESCRIPTOR write");
    	if (_parent != null)
    	{
    	
    		_parent.onDescriptorWrite(descriptor, status);
    	}
        
        
    }
    function onDescriptorRead(descriptor, status) 
    {
    	System.println("**callback DESCRIPTOR read");
    	var q = 42;
        
    }

    
	
    
}

