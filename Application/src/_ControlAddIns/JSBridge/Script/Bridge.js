!Microsoft && (function () { window.Microsoft = { Dynamics: { NAV: { InvokeExtensibilityMethod: function () { }, GetImageResource: function () { } } } }; })();

(function () {
    window.__controlAddInError__NAV = window.__controlAddInError;
    window.__controlAddInError = function (e) {
        debugger;
        console.log("Unhandled error has occurred: '" + e.message + "' - Stack: " + e.stack);
        window.__controlAddInError__NAV(e);
    };
})();

function RaiseAddInReady() {
    console.log('RaiseAddInReady');
    try {
        
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlAddInReady", null)
    }
    catch (err) {
        console.log('RaiseAddInReady Error: ' + err.message);
    }
}

function CreateAdyenContainer() {

    console.log("CreateAdyenContainer start")

}

function CallNativeFunction(jsonObject) {
    console.log('CallNativeFunction: ' + jsonObject);
    $("#controlAddIn").append("<div class='nav'><br><br><br><br><br><br><br><br><div class='img'><img class='logo' /></div><div class='title'>Printing is being<br>processed..</div></div>");
    
    var obj = JSON.parse(jsonObject);
    window.webkit.messageHandlers.invokeAction.postMessage(obj);
    text = 'succes';
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ActionCompleted', [text]);

}

function CallAdyenFunction(jsonObject) {
    console.log('CallAdyenFunction: ' + jsonObject);
    
    mpos.setWindowsId(window.name);
    
    if(jsonObject)
	{
		var obj = JSON.parse(jsonObject);
		var debugAdyen = obj.mPosRequest[0].debug;
		
		$("#controlAddIn").append("<div class='nav'><br><br><br><br><br><br><br><br><div class='img'><img class='logo' /></div><div class='title'>Payment is being<br>processed..</div></div>");
        	
        	/*
		    $(document).ready(function () {
		    	$(".logo").attr("src", Microsoft.Dynamics.NAV.GetImageResource("Image/adyen-logo-retina.png"));
		        console.log('CallAdyenFunction: Added logo');
		    });
			*/		    
	    
		    mpos.startTransaction(obj);   	
	}	
}

function EndAdyenFunction(jsonObject) {
    
    if(jsonObject)
	{
		text = JSON.stringify(jsonObject, null, 2);
    	console.log('EndAdyenFunction response text: ' + text);
    	Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ActionCompleted', [text]);
	}
	
}

function CallLocalhost(jsonObject)
{
    console.log('CallLocalhost Start');
    console.log(jsonObject);
    jsonObject = JSON.stringify(jsonObject);
    
    var uri = "https://localhost:8099/api/websites/";
    var id = 1;
    //var dataToBeSent = "=test clva";
       
    //var res = encodeURIComponent(jsonObject);
    //console.log(res);
    
    //var encodedData = window.btoa(jsonObject);
    //console.log(encodedData);
    
   
    $.post(uri, jsonObject, function (data, textStatus) {
                //data contains the JSON object
                //textStatus contains the status: success, error, etc
                console.log('CallLocalRestAPI textStatus: ' + textStatus);
            }, "json");
    
    
    //console.log('CallLocalRestAPI Stop');
    
	Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ActionCompleted', [jsonObject]);
	
    /*
    $.getJSON(uri + '/' + id)
        .done(function (data) {
            console.log('CallLocalRestAPI ok');
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ActionCompleted', [jsonObject]);
        })
        .fail(function (jqXHR, textStatus, err) {
            console.log('CallLocalRestAPI Error jqXHR: ' + jqXHR);
            console.log('CallLocalRestAPI Error textStatus: ' + textStatus);
            console.log('CallLocalRestAPI Error err: ' + err);
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ActionCompleted', [jsonObject]);
        })
    */
}

function InjectJavaScript(js) {

    eval(js);    
}

function StartDebugger() {
    debugger;
}