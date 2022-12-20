controladdin "NPR Dragonglass"
{
    Scripts =
        'src/_ControlAddins/Dragonglass/Scripts/bundle.js';


    Images =
        'src/_ControlAddins/Dragonglass/Scripts/bundle.js.map';

    RequestedHeight = 1;
    RequestedWidth = 1;
    HorizontalStretch = true;
    VerticalStretch = true;

    event OnFrameworkReady();
    event OnInvokeMethod(Method: Text; EventContent: JsonObject);
    event OnAction(Action: Text; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject);
    procedure InvokeFrontEndAsync(Request: JsonObject);
}
