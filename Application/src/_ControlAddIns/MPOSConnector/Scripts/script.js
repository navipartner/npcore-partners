function CallNativeFunction(jsonobject) {
  try {
    var userAgent = navigator.userAgent || navigator.vendor || window.opera;
    if (/android/i.test(userAgent)) {
      window.top.mpos.handleBackendMessage(jsonobject);
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("RequestSendSuccessfully");
      return;
    }

    if (/iPad|iPhone|iPod|Macintosh/.test(userAgent) && !window.MSStream) {
      window.webkit.messageHandlers.invokeAction.postMessage(jsonobject);
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("RequestSendSuccessfully");
      return;
    }
  }
  catch (e) {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("RequestSendFailed", [e.message]);
  }

  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("RequestSendFailed", ["No mpos connection method found. Please make sure you are using the MPOS app and try again."]);
}

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlAddInReady");
