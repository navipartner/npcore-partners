controladdin "NPR MPOS Connector"
{
    Scripts = 'src/_ControlAddIns/MPOSConnector/Scripts/script.js';

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

    procedure CallNativeFunction(Payload: JsonObject);
    event ControlAddInReady();
    event RequestSendSuccessfully();
    event RequestSendFailed(Error: Text);
}