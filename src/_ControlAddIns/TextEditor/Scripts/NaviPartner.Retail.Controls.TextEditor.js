var tmce = tinymce;
var options = {};
var inputText = '';

function initializeControlAddIn() {
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
        toolbar_mode: 'floating',
        
        paste_auto_cleanup_on_paste: true,
        paste_as_text: true,
        resize: 'both',
        autoresize_min_height: 300,
        autoresize_bottom_margin: 30,

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