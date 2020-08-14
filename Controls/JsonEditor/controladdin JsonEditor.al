controladdin JsonEditor
{
    Scripts =
        'Controls/JsonEditor/Scripts/polyfill.min.js',
        'Controls/JsonEditor/Scripts/jsoneditor.min.js',
        'Controls/JsonEditor/Scripts/view.sale.js',
        'Controls/JsonEditor/Scripts/view.payment.js',
        'Controls/JsonEditor/Scripts/view.login.js',
        'Controls/JsonEditor/Scripts/NaviPartner.Retail.Controls.JsonEditor.js';

    StartupScript = 'Controls/JsonEditor/Scripts/startup.js';

    StyleSheets =
        'Controls/JsonEditor/Stylesheets/jsoneditor.min.css',
        'Controls/JsonEditor/Stylesheets/NaviPartner.Retail.Controls.JsonEditor.css';

    Images =
        'Controls/JsonEditor/Images/jsoneditor-icons.svg';

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
