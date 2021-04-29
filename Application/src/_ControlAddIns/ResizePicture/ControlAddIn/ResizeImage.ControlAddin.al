controladdin "NPR ResizeImage"
{
    RequestedHeight = 1;
    MinimumHeight = 1;
    MaximumHeight = 1;
    RequestedWidth = 1;
    MinimumWidth = 1;
    MaximumWidth = 1;
    VerticalStretch = false;
    VerticalShrink = false;
    HorizontalStretch = false;
    HorizontalShrink = false;
    Scripts =
        'src/_ControlAddins/ResizePicture/JsScript/ResizeImage.js';
    StartupScript = 'src/_ControlAddins/ResizePicture/JsScript/Startup.js';

    event OnCtrlReady();
    event returnImage(resizedImage: Text; escpos: Text);
    event returnESCPOSBytes(Hi: Integer; Lo: Integer; CmdHi: Integer; CmdLo: Integer)

    procedure ResizeImage(sourceBase64: Text; imageExtension: Text);
}