controladdin "NPR NPCamera"
{
    Scripts = 'src/_ControlAddIns/NPCamera/Scripts/NPCamera.js';
    StyleSheets = 'src/_ControlAddIns/NPCamera/Styles/Styles.css';

    RequestedHeight = 550;
    RequestedWidth = 600;
    MaximumHeight = 550;
    MaximumWidth = 600;
    event Ready();
    event UsePhoto(ImageObj: JsonObject);
    event Cancel();
    procedure Initialize(InitJson: JsonObject);
}