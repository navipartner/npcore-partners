/**
 * This file is essentially JavaScript as the only thing it does is some good old JavaScript DOM manipulation.
 * Don't sweat it about type safety here. Just cast to any anything that's necessary.
 */

// TODO: do this without jQuery!

// Grabbing global jQuery reference
const $ = (window as any)["$"] as any;

function expandControlAddIn() {
    if (window.parent) {
        $(".content-area-box", window.parent.document).css("padding", "0");
        if (window.frameElement) {
            const frame = $("#" + window.frameElement.id, window.parent.document);
            frame.css("min-height", window.top.innerHeight + "px");
            frame.height(window.top.innerHeight + "px");
            $(".ms-core-overlay", window.parent.document).css("overflow", "hidden");
        }
    }
}

function hideNavNavigation() {
    const nav = $(window.frameElement).closest("#contentBox");
    nav.find(".ms-nav-navigation").attr("style", "display: none !important");
    nav.find(".ms-nav-appbar").attr("style", "display: none !important");
}

function hideBusinessCentralNavigation() {
    // #340613
    $(window.top.document.body).find("div.ms-nav-content-box > .ms-nav-navigation").attr("style", "display: none !important");
}

function hideBusinessCentralGutter() {
    // #353737
    $(window.frameElement).closest("body").find(".nav-bar-area-box").attr("style", "display: none !important");
    $(window.frameElement).closest("body").find(".ms-nav-layout-gutter-left").attr("style", "display: none !important");
    $(window.frameElement).closest("body").find(".ms-nav-layout-gutter-right").attr("style", "display: none !important");
    $(window.frameElement).closest(".control-addin-container").attr("style", "padding-top: 0 !important");
}

function hideBusinessCentralAppBar() {
    // #376820
    const bc = $(window.frameElement).closest(".ms-nav-content-box");
    bc.find(".ms-nav-appbar").attr("style", "display: none !important");
    bc.find(".ms-nav-content").attr("style", "width: width: calc(-0px + 100%)");
}

function hideBusinessCentralProductMenuBar() {
    // #414495
    $("#product-menu-bar", window.top.document.body).attr("style", "display: none !important");
    $("body.has-product-menu-bar .designer", window.top.document).attr("style", "height: 100% !important; top: 0 !important");
}

function fixBC170DefualtClientBottomPadding() {
    // #436343
    $(window.frameElement).closest("body").find("main.ms-nav-layout-body").attr("style", "padding-bottom: 0 !important");
}

function fixIOSKeyboardFocusZoom() {
    // #413071
    const metaAll = window.top.document.head.querySelectorAll("meta") as any;
    for (let node of metaAll) {
        if (node.name === "viewport") {
            node.content = "width=device-width, initial-scale=1, maximum-scale=1,user-scalable=0"
        }
    };
}

function hideNotificationPanel() {
    // #450630
    const frame = window.frameElement;
    if (!frame) {
        return;
    }
    const doc = frame.ownerDocument;
    const style = doc.createElement("style");
    style.innerText = "div.notification-panel { display: none; } div.notification-area { display: none; }";
    doc.head.appendChild(style);
}

function preventEscInTopWindow() {
    if (window.top === window)
        return;

    function handleEsc(e: KeyboardEvent) {
        if (e.key === "Escape" || e.which === 27)
            e.stopImmediatePropagation();
    }

    window.top.document.addEventListener("keyup", handleEsc, true);
    window.top.document.addEventListener("keydown", handleEsc, true);
}

/**
 * Hacks Business Central and Microsoft Dynamics NAV web client UI by hijacking the entire page content and
 * hiding any BC/NAV UI elements.
 */
export const bootstrapBusinessCentralUICustomization = () => {
    hideNavNavigation();
    hideBusinessCentralNavigation();
    hideBusinessCentralGutter();
    hideBusinessCentralAppBar();
    hideBusinessCentralProductMenuBar();
    fixBC170DefualtClientBottomPadding();
    expandControlAddIn();
    fixIOSKeyboardFocusZoom();
    preventEscInTopWindow();
    hideNotificationPanel();
};
