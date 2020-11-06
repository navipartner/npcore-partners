controladdin "NPR TextEditor"
{
    Scripts =
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/tinymce.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/themes/silver/theme.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/advlist/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/anchor/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/autolink/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/autoresize/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/autosave/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/bbcode/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/charmap/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/code/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/codesample/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/colorpicker/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/contextmenu/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/directionality/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/emoticons/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/emoticons/js/emojis.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/fullpage/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/fullscreen/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/help/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/hr/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/image/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/imagetools/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/importcss/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/insertdatetime/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/legacyoutput/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/link/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/lists/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/media/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/nonbreaking/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/noneditable/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/pagebreak/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/paste/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/preview/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/print/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/quickbars/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/save/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/searchreplace/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/spellchecker/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/tabfocus/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/table/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/template/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/textcolor/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/textpattern/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/toc/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/visualblocks/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/visualchars/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/plugins/wordcount/plugin.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/icons/default/icons.min.js',
        'src/_ControlAddIns/TextEditor/Scripts/NaviPartner.Retail.Controls.TextEditor.js';

    StartupScript = 'src/_ControlAddIns/TextEditor/Scripts/startup.js';

    StyleSheets =
        'src/_ControlAddIns/TextEditor/Scripts/NaviPartner.RetailControls.TextEditor.css',
        'src/_ControlAddIns/TextEditor/Scripts/tinymce/skins/ui/oxide/skin.min.css';

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
