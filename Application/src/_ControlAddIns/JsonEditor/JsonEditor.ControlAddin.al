controladdin "NPR JsonEditor"
{
    Scripts =
        'src/_ControlAddIns/JsonEditor/Scripts/polyfill.min.js',
        'src/_ControlAddIns/JsonEditor/Scripts/jsoneditor.min.js',
        'src/_ControlAddIns/JsonEditor/Scripts/view.sale.js',
        'src/_ControlAddIns/JsonEditor/Scripts/view.payment.js',
        'src/_ControlAddIns/JsonEditor/Scripts/view.login.js',
        'src/_ControlAddIns/JsonEditor/Scripts/NaviPartner.Retail.Controls.JsonEditor.js';

    StartupScript = 'src/_ControlAddIns/JsonEditor/Scripts/startup.js';

    StyleSheets =
        'src/_ControlAddIns/JsonEditor/Stylesheets/jsoneditor.min.css',
        'src/_ControlAddIns/JsonEditor/Stylesheets/NaviPartner.Retail.Controls.JsonEditor.css';

    Images =
        'src/_ControlAddIns/JsonEditor/Images/jsoneditor-icons.svg';

    RequestedHeight = 500;
    RequestedWidth = 800;
    MinimumHeight = 300;
    MinimumWidth = 500;
    MaximumHeight = 1080;
    MaximumWidth = 1920;

    HorizontalStretch = true;
    VerticalStretch = true;
    HorizontalShrink = true;
    VerticalShrink = true;

    event OnControlReady();
    event OnEvent(Method: Text; EventContent: Text);
    procedure Invoke(Method: Text; Request: Text);
}
