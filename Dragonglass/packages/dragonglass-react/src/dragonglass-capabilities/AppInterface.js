// TODO: This file is not being phased out, but needs better architecture and everything.
// This is just here as a quick hack to enable cross-app communication

const focus = () => setTimeout(window.focus);

const lockRegister = (locked) => {};

if (window && window.top && window.top.npDragonglass && typeof window.top.npDragonglass.connect === "function") {
  window.top.npDragonglass.connect({ focus, lockRegister });
}

const external = ((core) => {
  if (!core) {
    return {
      setBusy: () => {},
      navDialogActive: () => {},
      registerKeyPress: () => {},
      actionActive: () => {},
      applyTemplate: () => {},
      activeSale: () => {},
      getFrontEndId: () => Promise.resolve("WebBrowser;;"),
      invokeFrontEndEvent: () => {},
      eventInvocationCompleted: () => {},
    };
  }

  return {
    setBusy: (busy) => core.setBusy(busy),
    navDialogActive: (active) => core.navDialogActive(active),
    registerKeyPress: (keypress) => core.registerKeyPress(keypress),
    actionActive: (active) => core.actionActive(active),
    applyTemplate: (template) => core.applyTemplate(template),
    activeSale: (active) => core.activeSale(active),
    getFrontEndId: () => core.getFrontEndId(),
    invokeFrontEndEvent: (event, obj) => core.invokeFrontEndEvent(event, obj),
    eventInvocationCompleted: (reason) => core.eventInvocationCompleted(reason),

    stargate: {
      invokeProxy: (envelope, handle) => core.invokeProxy(envelope, handle),
      invokeProxyAsync: (envelope) => core.invokeProxyAsync(envelope),
      advertiseStargatePackages: (content) =>
        core.advertiseStargatePackages(content),
      appGatewayProtocolResponse: (event, data) =>
        core.appGatewayProtocolResponse(event, data),
    },
  };
})(
  window &&
    window.top &&
    window.top.npDragonglass &&
    window.top.npDragonglass.core
);

export const AppInterface = external;
