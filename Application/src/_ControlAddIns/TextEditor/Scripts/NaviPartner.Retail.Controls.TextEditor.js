var tmce = tinymce;
var options = {};
var inputText = '';

function initializeControlAddIn() {

    var iframe = window.frameElement;

    iframe.parentElement.style.display = 'flex';
    iframe.parentElement.style.flexDirection = 'column';
    iframe.parentElement.style.flexGrow = '1';

    iframe.style.removeProperty('height');
    iframe.style.removeProperty('min-height');
    iframe.style.removeProperty('max-height');

    iframe.style.flexGrow = '1';
    iframe.style.flexShrink = '1';
    iframe.style.flexBasis = 'auto';

    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnControlReady", []);
}
function SetContent(content) {
    inputText = content;
};
function PresetOption(propertyName, propertyValue) {
    options[propertyName] = propertyValue;
}
function RequestContent() {
    SendContentToNav();
};
function SendContentToNav() {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnContentChange", [tmce.activeEditor.getContent({ format: 'raw' })]);
};

function InitTinyMce() {

    var div = document.getElementById("controlAddIn");
    div.innerHTML = "";

    var InputArea = document.createElement("textarea");
    InputArea.id = "textarea";
    InputArea.name = "textarea";

    div.appendChild(InputArea);

    var useDarkMode = window.matchMedia("(prefers-color-scheme: dark)").matches;

    var init = {
        selector: '#textarea',

        menubar: "file edit view insert format tools table help",

        plugins: "print preview paste searchreplace autolink autosave directionality code visualblocks visualchars fullscreen link media template codesample table charmap hr pagebreak nonbreaking anchor toc insertdatetime advlist lists wordcount textpattern noneditable help charmap quickbars emoticons",

        toolbar: "undo redo | bold italic underline strikethrough | fontselect fontsizeselect formatselect | alignleft aligncenter alignright alignjustify | outdent indent |  numlist bullist | forecolor backcolor removeformat | pagebreak | charmap emoticons | fullscreen  preview save print | insertfile media template link anchor codesample | ltr rtl",
        toolbar_sticky: true,
        toolbar_mode: 'sliding',

        paste_auto_cleanup_on_paste: true,
        paste_as_text: true,

        quickbars_selection_toolbar: "bold italic | quicklink h2 h3 blockquote quicktable",
        noneditable_noneditable_class: "mceNonEditable",
        contextmenu: "link table",
        skin: useDarkMode ? "oxide-dark" : "oxide",
        content_css: useDarkMode ? "dark" : "default",
        content_style: "body { font-family:Helvetica,Arial,sans-serif; font-size:14px }",

        resize: "both",
        statusbar: true,
        branding: true,
        setup: SetupTinyMce

    };

    // Apply Customer Settings:
    for (var key in options) {
        init[key] = options[key];
    };

    tmce.init(init);

    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnAfterInit", []);

};

function SetupTinyMce(editor) {
    editor.on("init", function () {
        editor.setContent(inputText);
    });
};