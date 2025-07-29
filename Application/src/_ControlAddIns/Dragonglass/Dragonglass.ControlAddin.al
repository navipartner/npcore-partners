controladdin "NPR Dragonglass"
{
    Scripts =
        'https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.1/jquery.min.js',
        'https://dragonglass.azureedge.net/release/2.41.0/bundle.js';

    RequestedHeight = 1;
    RequestedWidth = 1;
    HorizontalStretch = true;
    VerticalStretch = true;

    //There is a 1:1 relationship between an inbound request on InvokeMethod and an outbound response on ControlAddinResponse.
    //This allows the frontend to await a response like any HTTP request
    event InvokeMethod(RequestId: Integer; Method: Text; Parameters: JsonObject);
    procedure ControlAddinResponse(Response: JsonObject);


    // BELOW IS DEPRECATED BUT OBSOLETE TAGS IN CONTROL ADDINS ARE BUGGY
    event OnFrameworkReady();
    event OnInvokeMethod(Method: Text; EventContent: JsonObject);
    event OnAction(Action: Text; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject);
    procedure InvokeFrontEndAsync(Request: JsonObject);
}
