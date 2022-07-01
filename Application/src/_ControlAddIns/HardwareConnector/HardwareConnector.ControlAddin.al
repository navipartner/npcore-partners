controladdin "NPR HardwareConnector"
{
    Scripts = 'src/_ControlAddIns/HardwareConnector/bundle.js';
    StyleSheets = 'src/_ControlAddIns/HardwareConnector/bundle.css';

    VerticalStretch = true;
    HorizontalStretch = true;
    MinimumHeight = 200;
    VerticalShrink = true;

    procedure SendRequest(Handler: Text; Request: JsonObject; Caption: Text);
    event ControlAddInReady();
    event ResponseReceived(Response: JsonObject);
    event ExceptionCaught(ExceptionMessage: Text);
}