/*
 * All code in this file is IE11 compatible at the time of writing. If editing this, please make sure it stays so!
 */

if (typeof Array.isArray === 'undefined') {
    Array.isArray = function (obj) {
        return Object.prototype.toString.call(obj) === '[object Array]';
    }
};

function invokeAL(event, context) {
    return new Promise(function (resolve) {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
            event,
            context || [],
            false,
            function () {
                resolve();
            });
    });
}

function invokeALEvent(event, content) {
    return invokeAL("OnEvent", [event, content]);
}

var controlAddInContext = {
    editor: null,
    initialized: false,
    autocomplete: {},
    valid: false
};

function initializeControlAddIn() {
    var controlAddIn = document.getElementById("controlAddIn");
    var div = document.createElement("div");

    controlAddIn.appendChild(div);

    function resize() {
        div.style.width = window.innerWidth + "px";
        div.style.height = window.innerHeight + "px";
    }
    resize();

    window.addEventListener("resize", resize);

    var options = {
        mode: "code",
        modes: ["code", "tree"],
        search: false,
        enableSort: false,
        enableTransform: false,
        templates: [
            {
                text: "Login View",
                title: "Inserts a default login view",
                value: viewLogin
            },
            {
                text: "Sale View",
                title: "Inserts a default sale view",
                value: viewSale
            },
            {
                text: "Payment View",
                title: "Inserts a default payment view",
                value: viewPayment
            }
        ],
        onNodeName: function (node) {
            try {
                var json = controlAddInContext.editor.get();
                var last;
                for (var i = 0; i < node.path.length; i++) {
                    last = node.path[i];
                    json = json[last];
                }
                if (Array.isArray(json))
                    return "";

                var type = json["type"] || (typeof last === "number" ? "container" : last);
                var result = type;
                switch (type) {
                    case "menu":
                        result += " " + (json["source"] || "undefined");
                        break;
                    case "binding":
                    case "grid":
                        result += " " + (json["dataSource"] || "undefined");
                        break;
                }

                return result;
            }
            catch (e) { }
        },
        onChange: function () {
            try {
                var content = JSON.stringify(controlAddInContext.editor.get());
                invokeALEvent("save", content);
            } catch (e) {
                if (!controlAddInContext.editor.getText().trim())
                    invokeALEvent("save", "");
            }
        },
        autocomplete: {
            trigger: "focus",
            getOptions: function (text, path, input) {
                try {
                    switch (input) {
                        case "value":
                            var json = controlAddInContext.editor.get();
                            var last;
                            var object;
                            for (var i = 0; i < path.length; i++) {
                                object = json;
                                last = path[i];
                                json = json[last];
                            }

                            if (last === "type")
                                return ["button", "captionbox", "grid", "input", "label", "lastsale", "loginpad", "logo", "menu", "panel", "text"];

                            if (last === "flow")
                                return ["horizontal", "vertical"];

                            if (last === "source" && object.type === "menu")
                                return new Promise(function (resolve) {
                                    invokeALEvent("retrieve", "menu").then(function () {
                                        resolve(controlAddInContext.autocomplete.menu);
                                    });
                                });

                            if (last === "dataSource")
                                return new Promise(function (resolve) {
                                    invokeALEvent("retrieve", "dataSource").then(function () {
                                        resolve(controlAddInContext.autocomplete.dataSource);
                                    });
                                });

                            debugger;
                            return null;
                        case "field":
                            break;
                    }
                }
                catch (e) { }
            }
        }
    };

    controlAddInContext.editor = new JSONEditor(div, options);
    controlAddInContext.initialized = true;

    return invokeAL("OnControlReady");
};

var invokeMethods = {
    setJson: function (context) {
        try {
            var json = JSON.parse(context || "{}");
            controlAddInContext.editor.set(json);
        } catch (e) {
            try {
                var mode = controlAddInContext.editor.getMode();
                controlAddInContext.editor.setMode("code");
                controlAddInContext.editor.setText(context);
                controlAddInContext.editor.setMode(mode);
            } catch(e) {
                throw new Error("An error has occurred trying to set JSON: " + e.message + ". JSON: " + context);
            }
        }
    },
    autocomplete_menu: function (context) {
        controlAddInContext.autocomplete.menu = JSON.parse(context);
    },
    autocomplete_dataSource: function (context) {
        controlAddInContext.autocomplete.dataSource = JSON.parse(context);
    }
};

function Invoke(method, context) {
    if (typeof method !== "string" || typeof invokeMethods[method] !== "function")
        throw new Error("Method " + method + " is not defined.");

    if (!controlAddInContext.initialized)
        throw new Error("Control Add-in has not been completely initialized.");

    invokeMethods[method](context);
};
