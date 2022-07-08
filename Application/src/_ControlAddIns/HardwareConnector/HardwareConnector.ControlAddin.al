controladdin "NPR HardwareConnector"
{
    Scripts = 'src/_ControlAddIns/HardwareConnector/bundle.js';
    StyleSheets = 'src/_ControlAddIns/HardwareConnector/bundle.css';

    VerticalStretch = true;
    HorizontalStretch = true;
    MinimumHeight = 200;
    VerticalShrink = true;

    internal procedure SendRequest(Handler: Text; Request: JsonObject; Caption: Text);

    //Adding parametar to SendRequest procedure is considered a breaking change by AppSource validation.
    //Crating dummy, unused, two param overload below to solve breaking change issue.
    procedure SendRequest(Handler: Text; Request: JsonObject);

    event ControlAddInReady();
    event ResponseReceived(Response: JsonObject);
    event ExceptionCaught(ExceptionMessage: Text);
}