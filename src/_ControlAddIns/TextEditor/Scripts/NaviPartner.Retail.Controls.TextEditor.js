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
    //iframe.style.paddingBottom = '42px';

    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnControlReady",[]);
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

    var init = {    
        selector: '#textarea',

        plugins: [
            "advlist autolink autosave link lists charmap preview hr anchor pagebreak ",
            "searchreplace wordcount visualblocks visualchars code nonbreaking",
            "table contextmenu directionality template paste textcolor colorpicker textpattern autoresize"
        ],

        toolbar1: "bold italic underline strikethrough | formatselect fontsizeselect | bullist numlist",
        toolbar2: "cut copy paste | searchreplace | undo redo | link unlink | forecolor | outdent indent blockquote | preview",
        toolbar3: "table | removeformat | subscript superscript | visualchars visualblocks restoredraft | code",
        toolbar_mode: 'wrap',
        
        paste_auto_cleanup_on_paste: true,
        paste_as_text: true,
        max_height: 500,
        toolbar_sticky: true,

        setup: SetupTinyMce
        
    };

    // Apply Customer Settings:
    for (var key in options) {
        init[key] = options[key];
    };

    tmce.init(init);

    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("OnAfterInit",[]);

};

function SetupTinyMce(editor) {
    editor.on("init", function () {      
        editor.setContent(inputText);
    });
};