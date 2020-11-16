;

if (typeof Microsoft === "undefined") {
    var Microsoft = {
        Dynamics: {
            NAV: {
                InvokeExtensibilityMethod: function () { return null; },
                GetEnvironment: function () { return null; },
                GetImageResource: function () { return null; }
            }
        }
    }
};

Object.defineProperty(window, "NaviPartner", { value: {} });
Object.defineProperty(window, "n$", { value: window.NaviPartner });
try {
    Object.defineProperty(window.top, "NaviPartnerBridge", { value: n$ });
    Object.defineProperty(window.top, "nb$", { value: n$ });
} catch (e) {
    console.error("Failed setting window.top.Navipartner property. Some functionality may not be available.");
};

(function () {
    /*
        Array polyfill

        This block defines the processSequence function that is used by module management to process array in sequence with callbacks,
        rather than in parallel that would be a seeming effect of forEach. This function is necessary for situations when each block
        inside forEach could result in an asynchronous operation, effectively putting the asynchronous callback at the end of execution
        loop. This in turn has the effect of forEach completing sooner than individual callbacks.
        With processSequence it is guaranteed that each element will be processed only after the previous was processed fully with any
        callbacks it may have awaited.
    */

    Object.defineProperty(Array.prototype,
        "processSequence",
        {
            value: function (each, completed) {
                if (typeof each !== "function")
                    throw "Function \"processSequence\" requires the parameter \"each\" of type \"function\".";

                var i = 0, me = this;

                function requestNext() {
                    processNext(me[i++]);
                };

                function processNext(element) {
                    if (i > me.length) {
                        typeof completed === "function" && completed();
                        return;
                    };
                    each(element, requestNext);
                };

                requestNext();
            }
        });
})(); // Array polyfill


(function () {
    /*
        Ready management

        This block handles ready state management. By registering a handler ready state management, the handler executes
        immediately when the page is fully loaded and the bridge framework is ready to respond to and invoke C/AL. Also,
        if the state has become ready already, registering a ready handler will cause the handler to run immediately.

        To make sure that something executes immediately upon loading, you do:

            n$.ready(function() {
                // This executes when C/AL and JavaScript are ready to talk to each other
            });
    */

    var handlers = [];
    var done = false;

    Object.defineProperty(n$,
        "ready",
        {
            value: function (handler) {
                /// <summary>Registers a handler to execute when the NaviPartner framework is fully loaded.</summary>
                /// <param name="handler">A function to execute. If this parameter is ommitted, all attached handlers will execute. Never omit this parameter.</param>
                if (typeof handler === "function") {
                    handlers.push(handler);
                    done && n$.ready();
                    return;
                };
                if (handler === undefined) {
                    handlers.forEach(function (h) {
                        h.done || (h(), h.done = true);
                    });
                    done = true;
                };
            }
        });
})(); // Ready management


(function () {
    /*
        NAV Busy state management

        This block handles the NAV Busy state management. When NAV becomes busy or idle, handlers registered here
        will be guaranteed to execute, without fear of replacing the original OnBusyChanged event accidentally and
        thus losing a previous listener.

        To register a listener:

            n$.onBusyChanged(function() {
                // This executes when state becomes idle
            }, false);

            n$.onBusyChanged(function() {
                // This executes when state becomes busy
            }, true);

            n$.onBusyChanged(function() {
                // This executes unconditionally when state changes
            });
    */
    var busyChangedListeners = [], navObject;

    n$.ready(function () {
        navObject = Microsoft.Dynamics.NAV.GetEnvironment();

        Object.defineProperty(n$,
            "onBusyChanged",
            {
                value: function (handler, busyState) {
                    /// <summary>Registers a handler to execute when busy state changes in NAV. You should always use this function instead of setting n$.NAV.OnBusyChanged property directly.</summary>
                    /// <param name="handler">Handler to execute when state changes</param>
                    /// <param name="busyState">State to fire on: true means handler will fire when state becomes busy; false means handler will fire when state becomes idle; ommitting this parameter means handler will fire always.</param>
                    if (typeof handler !== "function") {
                        console.error("Handler registered with [onBusyChanged] is not a function.");
                        return;
                    };
                    busyChangedListeners.push({
                        handler: handler,
                        state: typeof busyState !== "undefined" ? !!busyState : void 0
                    });
                }
            });
        Object.defineProperty(n$,
            "NAV",
            {
                value: navObject
            });

        n$.NAV.OnBusyChanged = function () {
            /// <summary>Do not set value to this property! Instead, call n$.NAV.onBusyChanged and pass your function as its parameter. Setting this value directly will have no effect and function you assign to it will never be called.</summary>
            busyChangedListeners.forEach(function (listener) {
                (!listener.hasOwnProperty("state") || listener.state === !!n$.NAV.Busy) && listener.handler();
            });
        };
    });

})(); // NAV Busy state management


(function () {
    /*
        NAV Event object

        This block contains definitions of n$.Event and n$.Event.Method objects that facilitate the communication with NAV through method invocations.
        Instead of invoking Microsoft.Dynamics.NAV.InvokeExtensibilityMethod directly, you should always use instances of n$.EVent.Method object (that
        is itself "inheriting" the n$.Event prototype).
        Invocations through instances of n$.Event (and n$.Event.Method) are managed and are executed in sequence, rather than in parallel. When an event
        invocation is requested, and NAV is busy, such event will be queued and invoked once NAV stops being busy.
    */

    var state = {
        events: [],
        inEvent: null,

        processNextEvent: function () {
            var e = this.events.pop();
            console.info("Dequeueing next InvokeExtensibilityMethod: " + e.event.name);
            e.args && (e.args.ready = true);
            e.event.raise(e.args, e.callback);
            if (state.events.length === 0) {
                state.inEvent = null;
            };
        }
    };

    (function () {
        /*
            n$.Event and n$.Event.Method prototypes
    
            This sub-block defines Event and Event.Method prototypes that represent diferent back-end invocation methods to go through the central
            Event Management sub-module.
        */

        n$.Event = function (event, skipIfBusy) {
            /// <summary>This prototype is for internal use only. It represents the base n$.Event object that manages invocations to NAV. You should not create instances of n$.Event directly. Instead, you should use the n$.Event.Method prototype.</summary>
            /// <param name="event">Name of the event object. If invoking this event, the event of the same name must be declared in the Control Add-in interface, as well as be present in C/AL as an event trigger.</param>
            /// <param name="skipIfBusy">Skips invocation of this event if NAV is busy.</param>
            typeof event === "object" &&
                event &&
                (
                    event.skipIfBusy !== undefined && (skipIfBusy = event.skipIfBusy),
                    event = event.name
                );
            if (!event) {
                debugger;
                throw "An attempt was made to instantiate an instance of n$.Event without specifying the event name. Switch the debugger on, and inspect the stack trace.";
            };
            this.name = event;
            this.skipIfBusy = !!skipIfBusy;
            this.isMethod = false;
            this.extensibilityMethodName = this.name;
        };
        n$.Event.prototype.raise = function (args, callback) {
            /// <summary>Invokes an event in C/AL through placing a managed call to Microsoft.Dynamics.NAV.InvokeExtensibilityMethod function. If you call this through an instance of n$.Event.Method prototype, it will invoke the OnInvokeMethod trigger in C/AL. Always use this function instead of calling the InvokeExtensibilityMethod function directly.</summary>
            /// <param name="args">Arguments to be passed to the C/AL OnInvokeMethod trigger. When invoking raise on an instance of n$.Event.Method prototype, then always pass a JSON structure as the value of the args parameter. This JSON structure will map to the 'eventContent' parameter of the OnInvokeMethod event trigger in C/AL and C/AL will see it as a JObject instance.</param>
            /// <param name="callback">A callback function to be invoked after C/AL completes the execution of the OnInvokeMethod event trigger invocation.</param>
            var me = this;

            typeof args === "function" &&
                typeof callback === "undefined" &&
                (callback = args, args = undefined);
            (!args || !args.ready) && me.isMethod && (args = [me.name, args === undefined ? {} : args]);

            if (!n$.NAV.Busy) {
                state.inEvent = { event: this, args: args };
                console.info("Invoking extensibility method: " + me.name);
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(me.extensibilityMethodName,
                    args,
                    false,
                    function () {
                        console.info("Finished invoking extensibility method: " + me.name);
                        callback &&
                            (function () {
                                try {
                                    callback();
                                } catch (e) {
                                    console.error("Error while executing callback for " + me.name + ": " + e);
                                    console.trace();
                                };
                            })();

                        if (state.events.length === 0) {
                            state.inEvent = null;
                        } else {
                            n$.NAV.Busy || state.processNextEvent();
                        };
                    });
            } else {
                if (me.skipIfBusy) {
                    console.info("Client is busy, skipping event " + me.name);
                    return;
                }

                var eventData = { event: this, args: args, callback: callback };
                console.info("Queueing extensibility method " + me.name);
                state.events.push(eventData);
            };
        };

        n$.Event.Method = function (event, skipIfBusy) {
            /// <summary>This prototype manages invocations to NAV, and any invocations through instances of this prototype will invoke the OnInvokeMethod event trigger in C/AL.</summary>
            /// <param name="event">Name of the method to invoke. This will map to the 'method' parameter of the OnInvokeMethod event trigger in C/AL.</param>
            /// <param name="skipIfBusy">Skips invocation of this event if NAV is busy.</param>
            n$.Event.call(this, "OnInvokeMethod");
            typeof event === "object" &&
                event &&
                (
                    event.skipIfBusy !== undefined && (skipIfBusy = event.skipIfBusy),
                    event = event.name
                );
            this.name = event;
            this.isMethod = true;
            this.skipIfBusy = !!skipIfBusy;
        };
        n$.Event.Method.prototype = Object.create(n$.Event.prototype);
        n$.Event.Method.prototype.constructor = n$.Event.Method;
    })(); // n$.Event and n$.Event.Method prototypes

    n$.ready(function () {
        n$.onBusyChanged(function () {
            state.events.length && state.processNextEvent();
        },
            false);
    });

})(); // NAV Event object


(function () {
    /*
        FrontEndAsync feature

        This block defines the functionality of the FrontEndAsync interface method. This is the only method defined on the IBridge interface.
    */

    var asyncHandlers = {};

    function invokeFrontEndAsyncSafe(request) {
        try {
            invokeFrontEndAsync(request);
        } catch (e) {
            console.error("An error has occurred while processing the front-end request " +
                (request && request.Method) +
                ": " +
                e.message);
        }
    };

    function invokeFrontEndAsync(request) {
        typeof request === "string" && (request = JSON.parse(request));

        (request.Method && typeof asyncHandlers[request.Method] === "function")
            ? (
                console.info("Invoking asynchronous request [" + request.Method + "]"),
                asyncHandlers[request.Method](request),
                console.info("Finished invoking asynchronous request [" + request.Method + "]")
            )
            : console.error("A request was received from C/AL that cannot be recognized:\n" +
                JSON.stringify(request));
    };

    Object.defineProperty(window,
        "InvokeFrontEndAsync",
        {
            value: function (request) {
                /// <summary>Invokes a handler for a JavaScript invocation requested from C/AL. This method is called internally and you should not be invoking this method directly.</summary>
                /// <param name="request">JSON representation of the request object</param>
                request.Method &&
                    typeof asyncHandlers[request.Method] === "function" &&
                    asyncHandlers[request.Method].immediate
                    ? invokeFrontEndAsyncSafe(request)
                    : setTimeout(function () { invokeFrontEndAsync(request); });
            }
        });

    Object.defineProperty(n$,
        "registerFrontEndAsync",
        {
            value: function (name, handler) {
                /// <summary>Registers a front-end asynchronous invocation handler.</summary>
                /// <param name="name">Name of the handler to regsiter. Must be unique.</param>
                /// <param name="handler">Function that represents the handler. This funtion is invoked when C/AL makes a call to JavaScript for this specific registered handler name.</param>
                if (typeof handler !== "function") {
                    console.error(
                        "Registering a front-end asynchronous handler \"" +
                        name +
                        "\" failed because no handler function was provided.");
                    return void 0;
                }
                asyncHandlers[name] = handler;

                return {
                    immediate: function () {
                        handler.immediate = true;
                    }
                };
            }
        });
})(); // FrontEndAsync feature


(function () {
    /*
        Module management

        This block handles module management. Modules are named blocks of code that are executed to initialize
        specific functionality. Modules are first registered, and after the state becomes ready, all registered
        moduels are executed. If a registered module is registered with dependencies, these dependencies are
        loaded first in order of declaration. If a module is registered after the initialization is already
        completed, then the initializer of such module is invoked immediately.
    */

    var done = false;
    var initializers = [];
    initializers.index = {};

    // Bridge functionality extension
    n$.registerFrontEndAsync("RegisterModule",
        function (req) {
            function checkRequiredProperty(name) {
                return (req.hasOwnProperty(name) && (typeof req[name] === "string")) ||
                    (console.error("[" +
                        name +
                        "] property of type \"string \" must be present when registering modules."), false);
            };

            if (!checkRequiredProperty("Name") || !checkRequiredProperty("Script"))
                return void 0;

            return n$.addModule(req.Name, req.Script).depend(req.Requires);
        }).immediate();
    var requestModule = new n$.Event.Method("RequestModule");


    // Private functions
    function insertScript(code) {
        var script = document.createElement("script");
        script.setAttribute("type", "text/javascript");
        script.innerText = code;
        document.head.appendChild(script);
    };

    function initialize(completed, stack) {
        var me = this;

        function complete() {
            me.initialized
                ? console.info("Done initializing module [" + me.name + "]")
                : console.warn("Module [" + me.name + "] was not initialized: " + me.error);
            typeof completed === "function" && completed(me.initialized);
        };

        if (!(stack instanceof Array))
            stack = [];
        for (var i = 0; i < stack.length; i++)
            if (stack[i] === me.name) {
                me.initialized = false;
                me.error = "Circular dependency detected in module [" +
                    me.name +
                    "]: " +
                    stack.join(" -> ") +
                    " -> " +
                    me.name;
                complete();
                return;
            };

        if (me.initializing)
            return;
        me.initializing = true;

        me.done
            ? complete()
            : (
                console.info("Initializing module [" + me.name + "]"),
                initRequire.call(me,
                    function (success) {
                        if (success) {
                            try {
                                typeof me.function === "function"
                                    ? me.function()
                                    : insertScript(me.function);
                                me.initialized = true;
                            } catch (e) {
                                me.initialized = false;
                                me.error = e;
                            };
                        };
                        me.done = true;
                        me.initializing = false;
                        complete();
                    },
                    stack)
            );
    };

    function initRequire(completed, stack) {
        var me = this;

        function allDone() {
            var ok = true;
            me.required.forEach(function (req) {
                ok = ok && typeof initializers.index[req] === "object" && initializers.index[req].done;
            });
            return ok;
        };

        if (!me.required || !me.required.length || allDone()) {
            completed.call(me, typeof me.initialized === "undefined" || me.initialized);
            return;
        };

        console.info(">>> Initializing required modules for [" + me.name + "]:");

        var remaining = me.required.length, errorAtInitialization;

        function requireCompleted() {
            console.info("<<< Done initializing required modules for [" + me.name + "]:");
            completed.call(me, !errorAtInitialization);
        };

        stack.push(this.name);

        function performInitialization(init, completedSuccess, completedFailure) {
            function callCompleted() {
                init.initialized
                    ? completedSuccess()
                    : completedFailure();
            }

            init.done
                ? callCompleted()
                : initialize.call(init, callCompleted, stack);
        };

        function completedSingleInitialization(success) {
            success
                ? (!--remaining && requireCompleted())
                : (errorAtInitialization = true, me.initialized = false, me.error =
                    "Failed initialization of module [" + me.name + "]. Check the console or log.", requireCompleted());
        };

        function requestRequiredModule(module, completedSingle) {
            /// <summary>Invoked when a required module is not available and has to be requested from the back-end C/AL.</summary>
            requestModule.raise({ module: module }, completedSingle);
        };

        var i = 0;

        function requestNext() {
            processNext(me.required[i++]);
        };

        function processNext(required) {
            if (i > me.required.length)
                return;
            if (errorAtInitialization)
                return;

            function completedSingleSuccess() {
                completedSingleInitialization(true);
                requestNext();
            };

            function completedSingleFailure() {
                completedSingleInitialization(false);
                requestNext();
            };

            var init = initializers.index[required];
            typeof init === "undefined"
                ? requestRequiredModule(required,
                    function () {
                        init = initializers.index[required];
                        typeof init === "undefined"
                            ? (
                                console.error("Required module [" + required + "] was not found."),
                                completedSingleFailure()
                            )
                            : performInitialization(init, completedSingleSuccess, completedSingleFailure);
                    })
                : performInitialization(init, completedSingleSuccess, completedSingleFailure);
        };

        requestNext();
    };

    function addInitializer(init) {
        initializers.push(init);
        initializers.index[init.name] = init;
        return init;
    };


    // Public methods
    Object.defineProperty(n$,
        "initialize",
        {
            value: function (completed) {
                /// <summary>Initializes the registered modules. This function is called internally and you should not be calling it directly.</summary>
                /// <param name="completed">Callback function to invoke after ann modules have been initialized.</param>
                console.info("Begin initializing modules");
                initializers.processSequence(
                    function (init, complete) {
                        init.done
                            ? complete()
                            : initialize.call(init, complete);
                    },
                    function () {
                        console.info("Done initializing modules");
                        typeof completed === "function" && completed();
                    });
                done = true;
            }
        });

    Object.defineProperty(n$,
        "addModule",
        {
            value: function (name, initializer) {
                /// <summary>Adds a module to the runtime. The module will be initialized at the initialization stage, or if that stage is already over, immediatelly upon adding.</summary>
                /// <param name="name">Name of the module to initialize</param>
                /// <param name="initializer">Function that initializes the module functionality.</param>
                if (typeof initializer !== "function" && typeof initializer !== "string")
                    throw new Error("Initializer " + name + " must be a function or a string.");
                if (initializers.index[name]) {
                    console.warn(
                        "Module with name \"" +
                        name +
                        "\" was already added. This addModule invocation will exit and no change will be made.");
                    return void 0;
                }

                var initObject = addInitializer({
                    name: name,
                    "function": initializer,
                    depend: function (requires) {
                        /// <summary>Specifies dependencies that this module requires.</summary>
                        /// <signature>Arguments: list of names</signature>
                        if (!requires)
                            return;

                        var error = false;
                        [].slice.call(arguments).forEach(function (module) {
                            if (!module)
                                return;
                            if (error)
                                return;
                            if (module === this.name) {
                                error = true;
                                throw "Module [" + this.name + "] cannot depend on itself.";
                            };
                            this.required = this.required || [];
                            this.required.push(module);
                        }.bind(this));
                    }
                });

                done && setTimeout(function () { initObject.done || initialize.call(initObject); });
                return initObject;
            }
        });
})(); // Module management


(function () {
    /*
        Initialization block

        This block makes sure that the Bridge.js framework is initialized when browser is ready.
    */

    function ready() {
        console.info("Starting JavaScript framework initialization");
        n$.initialize();
        n$.ready();
        var frameworkReady = new n$.Event("OnFrameworkReady");
        frameworkReady.raise(function () {
            console.info("Completed JavaScript framework initialization");
        });
        return true;
    };

    function onReady() {
        return document.readyState !== "complete" && setTimeout(ready);
    };

    onReady() || (document.onreadystatechange = onReady());
})(); // Initialization block


n$.addModule("BaseAsyncRequests", function () {
    /*
        This module contains the InvokeFrontEndAsync API that is available to NAV by default at all times. Any of these async handlers can be invoked
        fron NAV without the need to register any module.
    */


    // Private space
    function insertHeadTag(tag, content, attributes) {
        var element = document.createElement(tag);
        element.innerText = content;
        attributes &&
            attributes.forEach(function (attr) {
                attr &&
                    typeof attr.name === "string" &&
                    typeof attr.value === "string" &&
                    element.setAttribute(attr.name, attr.value);
            });
        document.head.appendChild(element);
    };

    // Public space
    n$.registerFrontEndAsync("SetSize",
        function (req) {
            /// <summary>Sets size of the screen.</summary>
            /// <param name="req">Defines the size request. The control add-in and its parent will assume this size. Members are:\n
            ///   width: width in CSS units\n
            ///   height: height in CSS units
            /// </param>
            if (req.width) {
                window.frameElement.style.width = req.width;
                window.frameElement.style.maxWidth = req.width;
            };
            if (req.height) {
                window.frameElement.style.height = req.height;
                window.frameElement.style.maxHeight = req.height;
            };
        });

    n$.registerFrontEndAsync("SetStyleSheet",
        function (req) {
            /// <summary>Inserts a stylesheet element in the document head section.</summary>
            /// <param name="req">Defines the stylesheet request. Members are:\n
            ///   style: CSS style to be applied
            /// </param>
            typeof req.style === "string" &&
                insertHeadTag("style", req.style);
        });

    n$.registerFrontEndAsync("SetScript",
        function (req) {
            /// <summary>Inserts a script element in the document head section.</summary>
            /// <param name="req">Defines the script request. Members are:\n
            ///   script: the JavaScript code to be inserted (and immediately executed)
            /// </param>
            typeof req.script === "string" &&
                insertHeadTag("script",
                    req.script,
                    [
                        {
                            name: "type",
                            value: "text/javascript"
                        }
                    ]);
        });
}); // Base API async requests
