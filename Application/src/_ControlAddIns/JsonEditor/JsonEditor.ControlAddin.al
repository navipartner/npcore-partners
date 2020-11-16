controladdin "NPR JsonEditor"
{
    Scripts =
        'src/_ControlAddins/JsonEditor/Scripts/polyfill.min.js',
        'src/_ControlAddins/JsonEditor/Scripts/jsoneditor.min.js',
        'src/_ControlAddins/JsonEditor/Scripts/view.sale.js',
        'src/_ControlAddins/JsonEditor/Scripts/view.payment.js',
        'src/_ControlAddins/JsonEditor/Scripts/view.login.js',
        'src/_ControlAddins/JsonEditor/Scripts/NaviPartner.Retail.Controls.JsonEditor.js';

    StartupScript = 'src/_ControlAddins/JsonEditor/Scripts/startup.js';

    StyleSheets =
        'src/_ControlAddins/JsonEditor/Stylesheets/jsoneditor.min.css',
        'src/_ControlAddins/JsonEditor/Stylesheets/NaviPartner.Retail.Controls.JsonEditor.css';

    Images =
        'src/_ControlAddins/JsonEditor/Images/jsoneditor-icons.svg';

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
