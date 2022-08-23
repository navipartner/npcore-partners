function InitComponent() {
    var controlContainer = document.getElementById("controlAddIn");
    var element = '<div><img id="' + IMAGE_ELEMENT_ID + '" /></div>';
    controlContainer.innerHTML = element;
    imageElement = document.getElementById(IMAGE_ELEMENT_ID);
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddInReady');
}

function SetSource(source) {
    if (!imageElement)
        return;

    if (!source || source === "") {
        HideImage();
        return;
    }

    imageElement.src = source;
    imageElement.style = "display: block;";
}

function HideImage() {
    if (!imageElement)
        return;

    imageElement.style = "display: none;";
}

const IMAGE_ELEMENT_ID = "npr-imageviewer-img";
var imageElement = null;

if (document.readyState === "complete") {
    InitComponent();
} else {
    window.addEventListener('load', InitComponent);
}