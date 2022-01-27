function expandControlAddIn() {
  if (window.parent) {
    const content = window.top.document.body.querySelector(".content-area-box");
    if (content) {
      content.style.setProperty("padding", "0");
    }

    if (window.frameElement) {
      const body = window.top.document.body;
      const frame = body.querySelector(`#${window.frameElement.id}`);

      if (frame) {
        frame.style.setProperty("min-height", `${window.top.innerHeight}px`);
        frame.style.height = `${window.top.innerHeight}px`;
      }

      const core = body.querySelector(".ms-core-overlay");
      if (core) {
        core.style.setProperty("overflow", "hidden");
      }
    }
  }
}

function hideNavNavigation() {
  const nav = window.top.document.body.querySelector(".ms-nav-navigation");
  if (nav) {
    nav.style.setProperty("display", "none", "important");
  }

  const appBar = window.top.document.body.querySelector(".ms-nav-appbar");
  if (appBar) {
    appBar.style.setProperty("display", "none", "important");
  }
}

function hideBusinessCentralNavigation() {
  // #340613
  const navContent = window.top.document.body.querySelector("div.ms-nav-content-box > .ms-nav-navigation");
  if (navContent) {
    navContent.style.setProperty("display", "none", "important");
  }
}

function hideBusinessCentralGutter() {
  // #353737
  if (window.frameElement) {
    const closestBody = window.frameElement.closest("body");
    const areaBox = closestBody.querySelector(".nav-bar-area-box");
    if (areaBox) {
      areaBox.style.setProperty("display", "none", "important");
    }

    const gutterLeft = closestBody.querySelectorAll(".ms-nav-layout-gutter-left");
    for (let node of gutterLeft) {
      node.style.setProperty("display", "none", "important")
    }

    const gutterRight = closestBody.querySelectorAll(".ms-nav-layout-gutter-right");
    for (let node of gutterRight) {
      node.style.setProperty("display", "none", "important")
    }

    const addinContainer = window.frameElement.closest(".control-addin-container");
    if (addinContainer) {
      addinContainer.style.setProperty("padding-top", "0", "important");
    }
  }
}

function hideBusinessCentralAppBar() {
  // #376820
  if (window.frameElement) {
    const bc = window.frameElement.closest(".ms-nav-content-box");
    if (bc) {
      const appBar = bc.querySelector(".ms-nav-appbar");
      if (appBar) {
        appBar.style.setProperty("display", "none", "important");
      }
      const navContent = bc.querySelector(".ms-nav-content");
      if (navContent) {
        navContent.style.setProperty("width", "100%");
      }
    }
  }
}

function hideBusinessCentralProductMenuBar() {
  // #414495
  const productMenuBar = window.top.document.body.querySelector("#product-menu-bar");
  if (productMenuBar) {
    productMenuBar.style.setProperty("display", "none", "important");
  }

  const bodyMenuBar = window.top.document.querySelector("body.has-product-menu-bar .designer");
  if (bodyMenuBar) {
    bodyMenuBar.style.setProperty("height", "100%", "important");
    bodyMenuBar.style.setProperty("top", "0", "important");
  }
}

function fixBC170DefualtClientBottomPadding() {
  // #436343
  const frameElement = window.frameElement;

  if (!frameElement) {
    return;
  }

  const msNav = frameElement.closest("body").querySelector("main.ms-nav-layout-body");

  if (msNav) {
    msNav.style.setProperty("padding-bottom", "0", "important");
  }
}

function fixIOSKeyboardFocusZoom() {
  // #413071
  const metaAll = window.top.document.head.querySelectorAll("meta");
  for (let node of metaAll) {
    if (node.name === "viewport") {
      node.content = "width=device-width, initial-scale=1, maximum-scale=1,user-scalable=0";
    }
  }
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
  if (window.top === window) return;

  function handleEsc(e) {
    if (e.key === "Escape" || e.which === 27) e.stopImmediatePropagation();
  }

  window.top.document.addEventListener("keyup", handleEsc, true);
  window.top.document.addEventListener("keydown", handleEsc, true);
}

/**
 * Hacks Business Central and Microsoft Dynamics NAV web client UI by hijacking the entire page content and
 * hiding any BC/NAV UI elements.
 */

const ready = (callback) => {
  if (document.readyState != "loading") callback();
  else document.addEventListener("DOMContentLoaded", callback);
};

ready(() => {
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
});
