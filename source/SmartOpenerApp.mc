using Toybox.Application;

class SmartOpenerApp extends Application.AppBase {
	hidden var mView;
    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    	Communications.cancelAllRequests();
    }

    // Return the initial view of your application here
    function getInitialView() {
    	var controller = new SmartOpenerController();
    	mView = new SmartOpenerView(controller);
    	var communicators = getCommunicators(controller);
    	controller.dirtyInitialize(mView, communicators);
    	
    	var delegate = new SmartOpenerBehaviorDelegate(controller);    	
        return [ mView, delegate ];
    }
    
    function getCommunicators(controller) {
    	var communicators = {};
    	var myqUser = Application.getApp().getProperty("myQUserName");
		var myqPassword = Application.getApp().getProperty("myQPassword");
		var myqBrand = Application.getApp().getProperty("myQBrand");
    /*	var augustUser = Application.getApp().getProperty("augustUserName");
		var augustPassword = Application.getApp().getProperty("augustPassword");
		var augustToken = Application.getApp().getProperty("augustToken");
if (augustUser != null && augustPassword != null) {
			communicators[:august] = new AugustCommunicator(controller, "", "", "");
		/*}
		*/
		if (myqUser != null 
				&& myqPassword != null 
				&& !myqUser.equals("") 
				&& !myqPassword.equals("")) {
			
			var myQ = new MyQCommunicator(controller, myqUser, myqPassword, myqBrand);
			communicators[:myQ] = myQ;
		}
		
		return communicators;
    }
}