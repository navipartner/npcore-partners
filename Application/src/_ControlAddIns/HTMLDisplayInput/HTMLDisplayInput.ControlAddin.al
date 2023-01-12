controladdin "NPR HTML Display Input"
{
    StartupScript = 'src/_ControlAddIns/HTMLDisplayInput/Scripts/HTMLDisplayInputStartup.js';
    Scripts = 'src/_ControlAddIns/HTMLDisplayInput/Scripts/HTMLDisplayInput.js';

    VerticalStretch = true;
    HorizontalStretch = true;
    RequestedHeight = 600;

    procedure SendInputData(Input: JsonObject; ShowControl: Boolean);
    event Ready();
    event OkInput();
    event RedoInput();
}