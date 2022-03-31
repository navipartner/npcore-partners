controladdin "NPR HardwareConnector"
{
    Scripts = 'src/_ControlAddIns/HardwareConnector/Scripts/HardwareConnectorClient.js',
              'src/_ControlAddIns/HardwareConnector/Scripts/script.js';

    MinimumHeight = 1;
    MinimumWidth = 1;
    RequestedHeight = 1;
    RequestedWidth = 1;
    MaximumHeight = 1;
    MaximumWidth = 1;
    VerticalStretch = false;
    VerticalShrink = false;
    HorizontalStretch = false;
    HorizontalShrink = false;

    procedure SendRequest(Handler: Text; Request: JsonObject);
    event ControlAddInReady();
    event ResponseReceived(Response: JsonObject);
    event ExceptionCaught(ExceptionMessage: Text);
}