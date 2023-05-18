let main = async ({}) => {
    debugger;

    var jsonObject = await workflow.respond("GetScanditRequest");
    var userAgent = navigator.userAgent || navigator.vendor || window.opera; 
    
    if (/android/i.test(userAgent)) {
        window.top.mpos.handleBackendMessage(jsonObject); 
    }

    if (/iPad|iPhone|iPod|Macintosh/.test(userAgent) && !window.MSStream) { 
        window.webkit.messageHandlers.invokeAction.postMessage(jsonObject);
    }
    
};