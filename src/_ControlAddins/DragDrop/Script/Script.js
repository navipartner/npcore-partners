var navControlContainer;
var navControl;

var fileInfoName = '';
var fileInfoSize = '';

var maxWidth = 600;
var maxHeight = 400;
var maxLen = 60000000;

$(document).ready(function () {
    CreateControl();
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("AddInReady", null, false, function () { });
});


function CreateControl() {
    navControlContainer = $("#controlAddIn");
    navControlContainer.append('<div id="drop-files" ondragover="return false">' +
                                    '<div id="drop-text">Drop Images Here</div>' +
                                    '<img id="drop-img" />' +
                                '</div>');
    navControl = $("#drop-files");
    jQuery.event.props.push('dataTransfer');

    navControl.bind('drop', function (e) {
        var files = e.dataTransfer.files;
        var i = 0;

        function loadFile(file) {
            if (!file) {
                return;
            }
            var fileReader = new FileReader();
            var filename = file.name;
            var filesize = file.size;
            fileReader.onload = (function (file) {

                function processData(dataUri) {
                    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("InitDataStream", [filename, filesize], false, function () {
                        sendData(dataUri);
                    });
                }
                function sendData(dataUri) {
                    if (!dataUri) {
                        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("EndDataStream", [], false, function () {
                            i++;
                            if (i > files.length - 1) {
                                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("EndDataTransfer", [], false, function () {
                                    return;
                                });
                            }
                            loadFile(files[i]);
                        });

                        return;
                    }

                    var substring = dataUri.substr(0, maxLen);
                    dataUri = dataUri.substr(maxLen);
                    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("WriteDataStream", [substring, dataUri.length == 0], false, function () {
                        sendData(dataUri);
                    });
                }

                processData(fileReader.result);
            });

            fileReader.readAsDataURL(file);
        }

        if (files.length > 0) {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("InitDataTransfer", [], false, function () {
                loadFile(files[i]);
            });
        }
    });

    navControl.bind('dragenter', function (e) {
        e.dataTransfer.dragEffect = "copy";
        $(this).css({ 'background-color': 'lightgreen', 'border': '4px dashed mediumseagreen' });
        return false;
    });
    navControl.bind('drop', function () {
        $(this).css({ 'background-color': 'gainsboro', 'border': '4px dashed darkgrey' });
        return false;
    });
    navControl.bind('dragleave', function () {
        $(this).css({ 'background-color': 'gainsboro', 'border': '4px dashed darkgrey' });
        return false;
    });
}

function DisplayData(dataUri) {
    if (dataUri == "") {
        $("#drop-text").css("display", "inline-block");
        $("#drop-img").css("display", "none");
    } else {
        $("#drop-text").css("display", "none");
        $("#drop-img").css("display", "block");
    }
    $("#drop-img").attr("src", dataUri);
}

function SetCaption(elementId, caption) {
    $("#" + elementId).html(caption);
}