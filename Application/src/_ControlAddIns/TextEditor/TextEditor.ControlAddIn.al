controladdin "NPR TextEditor"
{
    Scripts =
        'https://xsd.navipartner.dk/tinymce/js/tinymce/tinymce.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/NaviPartner.Retail.Controls.TextEditor.js';

    StartupScript = 'src/_ControlAddIns/TextEditor/Scripts/startup.js';

    StyleSheets =
        'src/_ControlAddIns/TextEditor/Scripts/NaviPartner.RetailControls.TextEditor.css';

    RequestedHeight = 500;
    RequestedWidth = 800;
    MinimumHeight = 350;
    MinimumWidth = 350;
    MaximumHeight = 1080;
    MaximumWidth = 1920;

    HorizontalStretch = true;
    VerticalStretch = true;
    HorizontalShrink = true;
    VerticalShrink = true;

    event OnControlReady();
    event OnAfterInit();
    event OnContentChange(Content: Text);
    procedure InitTinyMce();
    procedure SetContent(Content: Text);
    procedure RequestContent();
    procedure PresetOption(PropertyName: Text; PropertyValue: Text);
}
