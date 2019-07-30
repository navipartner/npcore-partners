controladdin Bridge
{
    Scripts = 'Controls/Bridge/Scripts/bridge.js';

    RequestedHeight = 1;
    RequestedWidth = 1;

    event OnFrameworkReady();
    event OnInvokeMethod(Method: Text; EventContent: JsonObject);
    procedure InvokeFrontEndAsync(Request: JsonObject);
}