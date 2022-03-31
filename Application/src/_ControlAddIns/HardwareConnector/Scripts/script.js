function SendRequest(handler, request) {
  _np_hardware_connector.sendRequestAndWaitForResponseAsync(handler, request)
    .then((response) => {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
      "ResponseReceived",
      [response]
    );
    }, (exception) => {
      console.error(exception);
      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ExceptionCaught", [exception.message]);
    })
}

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlAddInReady");
