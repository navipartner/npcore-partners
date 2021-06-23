/*
    This file is not directly used anywhere.

    When changing this file, copy all the contents below this comment block and paste it into
    NaviPartner.Transcendence.ts as contents of the TRANSCENDENCE_SCRIPT constant.
*/

console.log(
  "[dragonglass-transcendence] Initializing Transcendence dynamic script loader"
);

return new Promise((fulfill) => {
  const n$ = {};

  const connectToApp = (object) => {
    if (
      window &&
      window.top &&
      window.top.npDragonglass &&
      typeof window.top.npDragonglass.connect === "function"
    ) {
      window.top.npDragonglass.connect(object);
    }
  };

  n$.Enums = {
    NumpadType: {
      Decimal: 0,
      Integer: 1,
      Date: 2,
      Text: 3,
    },
  };

  n$.inherit = function (object, fromObject) {
    object.prototype = Object.create(fromObject.prototype);
    object.prototype.constructor = object;
  };

  /********** MODULE: Debug **********/
  (() => {
    function stringifyObject(obj, stopRecursion) {
      var objToStr = {};
      for (var p in obj) {
        if (obj.hasOwnProperty(p)) {
          var type = typeof obj[p];
          if (
            type === "string" ||
            type === "number" ||
            type === "boolean" ||
            type === "undefined"
          )
            objToStr[p] = obj[p];
          if (type === "object") {
            if (p === "Content") {
              if (!$.isEmptyObject(obj[p])) objToStr[p] = obj[p];
            } else
              objToStr[p] = stopRecursion
                ? "<object>"
                : stringifyObject(obj[p], true);
          }
        }
      }
      return stopRecursion ? objToStr : JSON.stringify(objToStr);
    }

    function jsonStringify(obj) {
      switch (typeof obj) {
        case "undefined":
          return "undefined";
        case "function":
          return "<function>";
        case "object":
          if (obj && obj.__json) {
            delete obj.__json;
            return JSON.stringify(obj);
          }
          return stringifyObject(obj);
        case "number":
        case "boolean":
          return obj.toString();
      }
      return obj;
    }

    n$.Debug = {};

    n$.Debug.Source = function (name) {
      this.name = name;
    };

    n$.Debug.Source.prototype = {
      alert: function (message, details, isError) {
        typeof details === "boolean" &&
          typeof isError === "undefined" &&
          ((isError = details), (details = undefined));
        alert(message);
        this.log({
          event: this.name || "window.alert",
          data: details || message,
          error: !!isError,
          warning: !isError,
        });
      },
      warning: function (message, error, throwing) {
        this.log({
          event: "JavaScript [" + this.name + "]",
          data: message,
          trace: true,
          warning: !error,
          error: !!error && !throwing,
        });
      },
      dontPanic: function (message, red) {
        dragonglass.raiseCriticalError(
          message instanceof Error ? message : Error(message.toString())
        );
      },
      error: function (message, warning, red) {
        this.dontPanic(message, red);
        this.warning(message, true, !warning);
        if (!warning) {
          var err = new Error(message);
          err.fromCode = true;
          throw err;
        }
      },
      log: function (par) {
        var data = par.data ? jsonStringify(par.data) : "";
        var msg = par.event ? par.event + (data ? ": " + data : "") : par;
        par.warning
          ? console.warn(this.name + ": " + msg)
          : par.error
          ? console.error(this.name + ": " + msg)
          : console.info(this.name + ": " + msg);
        par.trace && console.trace();
      },

      /// This function logs the JSON object as-is, without trying to optimize it
      logJson: function (par) {
        par && par.data && (par.data.__json = true);
        this.log(par);
      },
    };

    n$.Debug.Event = new n$.Debug.Source("Event");
    n$.Debug.BackEnd = new n$.Debug.Source("BackEnd");
    n$.Debug.Workflow = new n$.Debug.Source("Workflow");
  })();

  /********** MODULE: Events **********/
  (() => {
    var state = {
      events: [],
      inEvent: null,

      processNextEvent: function () {
        var e = this.events.pop();
        n$.Debug.Event.log({
          event: "Dequeueing next InvokeExtensibilityMethod",
          data: {
            event: e.event.name,
            args: e.args,
            eventsInQueue: this.events.length,
          },
        });
        setTimeout(function () {
          e.args &&
            ((e.args.ready = true), (e.args.originalArgs = e.originalArgs));
          e.event.raise(e.args, e.callback);
          if (state.events.length === 0) {
            state.inEvent = null;
          }
        });
      },
    };

    n$.Event = function (event, skipIfBusy, rejectDuplicate) {
      typeof event === "object" &&
        event &&
        (event.skipIfBusy !== undefined && (skipIfBusy = event.skipIfBusy),
        event.rejectDuplicate !== undefined &&
          (rejectDuplicate = event.rejectDuplicate),
        (event = event.name));
      if (!event) {
        debugger;
        throw "An attempt was made to instantiate an instance of n$.Event without specifying the event name. Switch the debugger on, and inspect the stack trace.";
      }
      this.name = event;
      this.skipIfBusy = !!skipIfBusy;
      this.rejectDuplicate =
        rejectDuplicate === undefined ? true : !!rejectDuplicate;
      this.isMethod = false;
      this.extensibilityMethodName = this.name;
    };

    n$.Event.prototype.raise = function (args, callback) {
      var me = this,
        originalArgs = undefined;

      typeof args === "function" &&
        typeof callback === "undefined" &&
        ((callback = args), (args = undefined));
      (!args || !args.ready) &&
        me.isMethod &&
        ((originalArgs = me.processArguments(args === undefined ? {} : args)),
        (args = [me.name, originalArgs]));

      if (!dragonglass.nav.busy) {
        state.inEvent = { event: me, args: args };
        n$.Debug.Event.log({
          event: "n$.Event.prototype.raise",
          data: { event: me.name, args: args },
        });
        typeof me.filter === "function" && me.filter(args);
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
          me.extensibilityMethodName,
          args || [],
          false,
          function () {
            n$.Debug.Event.log({
              event: "Finished executing",
              data: { event: me.name, args: args },
            });
            callback && setTimeout(callback);
            me.isMethod &&
              me.callback &&
              setTimeout(function () {
                me.callback(
                  args && args.ready ? args.originalArgs : originalArgs
                );
              });

            if (state.events.length === 0) {
              state.inEvent = null;
            } else {
              dragonglass.nav.busy || state.processNextEvent();
            }
          }
        );
      } else {
        if (me.skipIfBusy) {
          n$.Debug.Event.log({
            event: "Client is busy, skipping event",
            data: { event: me.name, args: args },
          });
          return;
        }

        var eventData = {
          event: me,
          args: args,
          callback: callback,
          originalArgs: originalArgs,
        };
        n$.Debug.Event.log({
          event: "Queueing InvokeExtensibilityMethod",
          data: eventData,
        });
        state.events.push(eventData);
      }
    };

    n$.Event.Method = function (event, skipIfBusy, rejectDuplicate) {
      var processArguments = function (args) {
        return args;
      };

      var filter = function () {};
      var noSupport = function () {
        return false;
      };

      typeof event === "object" &&
        event &&
        (typeof event.filter === "function" && (filter = event.filter),
        event.skipIfBusy !== undefined && (skipIfBusy = event.skipIfBusy),
        event.rejectDuplicate !== undefined &&
          (rejectDuplicate = event.rejectDuplicate),
        typeof event.processArguments === "function" &&
          (processArguments = event.processArguments),
        typeof event.callback === "function" &&
          (this.callback = event.callback),
        typeof event.noSupport === "function" && (noSupport = event.noSupport),
        (event = event.name));
      this.name = event;
      this.skipIfBusy = !!skipIfBusy;
      this.rejectDuplicate =
        rejectDuplicate === undefined ? true : !!rejectDuplicate;
      this.isMethod = true;
      this.processArguments = processArguments;
      this.filter = filter;
      n$.Event.Method.noSupport[event] = noSupport;
    };
    n$.Event.Method.prototype = new n$.Event("OnInvokeMethod");
    n$.Event.Method.noSupport = {};

    n$.Events = {
      Action: new n$.Event({ name: "OnAction" }),

      // Methods
      AbortWorkflow: new n$.Event.Method({ name: "AbortWorkflow" }),
      AbortAllWorkflows: new n$.Event.Method({ name: "AbortAllWorkflows" }),
      BeforeWorkflow: new n$.Event.Method({ name: "BeforeWorkflow" }),
    };

    if (
      dragonglass &&
      dragonglass.nav &&
      typeof dragonglass.nav.subscribeBusyChanged === "function"
    ) {
      dragonglass.nav.subscribeBusyChanged((busy) => {
        n$.Debug.Event.log({
          event: "Client busy state changed",
          data: busy ? "Busy" : "Idle",
        });
        dragonglass.external.setBusy(busy);
      });
    }
  })();

  /********** MODULE: FrontEndAsync **********/
  (() => {
    // This is a fallback entry point for Dragonglass
    n$._invokeFrontEndAsync = function (request) {
      if (request.Content && request.Content._trace) {
        var debugtrace = request.Content._trace.debug_trace;
        if (debugtrace)
          n$.Debug.BackEnd.log(
            "Asynchronous event " +
              request.Method +
              " with debug trace " +
              debugtrace
          );
      }

      if (
        request.Method &&
        typeof n$.AsyncRequestHandlers[request.Method] === "function"
      ) {
        var method = n$.AsyncRequestHandlers[request.Method];
        if (!method.notrace && request.Content && request.Content._trace) {
          n$.Debug.Workflow.logJson({
            event: "Trace",
            data: { method: request.Method, data: request.Content._trace },
          });
        }

        try {
          n$.AsyncRequestHandlers[request.Method](request);
        } catch (e) {
          throw new Error(
            "An error has occurred while processing the front-end request " +
              request.Method +
              ": " +
              e.message
          );
        }

        return true;
      }

      n$.Debug.BackEnd.warning(
        "A request was received from C/AL that cannot be recognized: " +
          JSON.stringify(request)
      );
      return false;
    };

    n$.AsyncRequestHandlers = {};

    /********** SUBMODULE: FrontEndAsync.SecureMethod **********/
    (() => {
      var secureMethod = new n$.Event.Method({ name: "SecureMethod" });
      var debug = new n$.Debug.Source("SecureMethod");
      var methods = {};
      var serverPasswordInvocationRequests = { id: 0, responses: {} };

      var clientPasswords = [];
      function evaluateClientPassword(context) {
        dragonglass.popup
          .numpad({
            title: "Password required",
            caption:
              "This operation is password-protected. Please enter your password to continue.",
            masked: true,
            value: "",
            type: dragonglass.enums.inputType[n$.Enums.NumpadType.Text],
          })
          .then((result) => {
            if (result === null) return;

            if (clientPasswords.indexOf(String(result)) >= 0) {
              context.success();
              return;
            }
            dragonglass.popup.error(
              "The password you provided is not valid. You may not execute this operation."
            );
          });
      }

      function evaluateServerPassword(context) {
        var requestId = ++serverPasswordInvocationRequests.id;
        dragonglass.popup
          .numpad({
            title: "Password required",
            caption:
              "This operation is password-protected. Please enter your password to continue.",
            masked: true,
            value: "",
            type: dragonglass.enums.inputType[n$.Enums.NumpadType.Text],
          })
          .then((result) => {
            if (result === null) return;

            secureMethod.raise(
              {
                action: "validate",
                method: context.method,
                password: String(result),
                requestId: requestId,
              },
              () => {
                if (!serverPasswordInvocationRequests.responses[requestId]) {
                  dragonglass.popup.error(
                    "The server did not respond to the password validation request."
                  );
                  return;
                }
                var response =
                  serverPasswordInvocationRequests.responses[requestId];
                delete serverPasswordInvocationRequests.responses[requestId];
                if (response.status) {
                  context.success();
                  return;
                }
                if (response.skipUi) return;

                dragonglass.popup.error(
                  response.reason ||
                    "The password you provided is not valid. You may not execute this operation."
                );
              }
            );
          });
      }

      function evaluateHandler(handler) {
        try {
          return eval(handler);
        } catch (e) {
          return function () {
            alert(
              "Invalid SecureMethod handler implementation. Evaluation failed with error: " +
                e
            );
          };
        }
      }

      function SecureMethodContext(method, context, callback) {
        this.invocationContext = context;
        this.method = method;
        this.success = function () {
          callback();
        };
      }

      n$.Security = n$.Security || {};
      n$.Security.evaluateMethod = function (method, context, callback) {
        if (!methods[method]) {
          debug.dontPanic(
            "Secure method [" +
              method +
              "] was requested, but it was not registered."
          );
          return;
        }
        if (!callback || typeof callback !== "function") {
          debug.dontPanic(
            "Secure method [" +
              method +
              "] was invoked without a callback function. This is a serious blunder by a developer.",
            true
          );
          return;
        }
        methods[method].handler(
          new SecureMethodContext(method, context, callback)
        );
      };

      n$.AsyncRequestHandlers.ConfigureSecureMethods = function (req) {
        if (!req.Content || !req.Content.methods) return;

        var ms = req.Content.methods;
        for (var method in ms) {
          if (ms.hasOwnProperty(method)) {
            methods[method] = ms[method];
            switch (methods[method].type) {
              case 0:
                methods[method].handler = evaluateHandler(
                  methods[method].handler
                );
                break;
              case 1: // Client-side password
                methods[method].handler = evaluateClientPassword;
                break;
              case 2: // Server-side password
                methods[method].handler = evaluateServerPassword;
                break;
            }
          }
        }
      };

      n$.AsyncRequestHandlers.ConfigureSecureMethodsClientPasswords = function (
        req
      ) {
        if (!req.Content || !req.Content.passwords) return;

        if (typeof req.Content.passwords === "string")
          req.Content.passwords = req.Content.passwords.split(",");

        if (req.Content.passwords instanceof Array) {
          clientPasswords = [];
          req.Content.passwords.forEach(function (pwd) {
            if (pwd && typeof pwd === "string") clientPasswords.push(pwd);
          });
        }
      };

      n$.AsyncRequestHandlers.ValidateSecureMethodPassword = function (req) {
        if (
          !req.Content ||
          !req.Content.hasOwnProperty("success") ||
          !req.Content.requestId ||
          typeof req.Content.requestId !== "number"
        )
          return;

        serverPasswordInvocationRequests.responses[req.Content.requestId] = {
          status: req.Content.success,
          reason: req.Content.reason,
          skipUi: req.Content.skipUi,
        };
      };
    })();

    /********** SUBMODULE: FrontEndAsync.PauseWorkflow **********/
    (() => {
      n$.AsyncRequestHandlers.PauseWorkflow = function (req) {
        var workflow = n$.Workflow.getById(req.WorkflowId, false);
        workflow
          ? workflow.pause(true)
          : n$.Debug.Workflow.warning(
              "FrontEndAsync.PauseWorkflow invoked, with no active workflow. Check the back end!"
            );
      };
    })();

    /********** SUBMODULE: FrontEndAsync.ProvideContext **********/
    (() => {
      n$.AsyncRequestHandlers.ProvideContext = function (req) {
        var workflow = n$.Workflow.getById(req.WorkflowId, false);
        workflow &&
          workflow.name !== req.Content.actionCode &&
          (workflow = null);

        if (!workflow) {
          n$.Workflow.fail(
            "Context was provided for an unknown workflow [" +
              req.Content.actionCode +
              ", " +
              req.WorkflowId +
              "]. This most likely means that an action codeunit handled the OnBeforeWorkflow event not intended for it, but may indicate an incompletely handled front-end state after a previous failed workflow. You should contact support."
          );
          return;
        }

        if (req.Content.objectName) {
          n$.Workflow.setContext(req.Content.objectName, req.Context, workflow);
          return;
        }

        $.extend(workflow.context, req.Context);
      };
      n$.AsyncRequestHandlers.ProvideContext.immediate = true;
    })();

    /********** SUBMODULE: FrontEndAsync.ResumeWorkflow **********/
    (() => {
      n$.AsyncRequestHandlers.ResumeWorkflow = function (req) {
        var workflow = n$.Workflow.getById(req.WorkflowId, false);
        workflow
          ? workflow._paused && workflow.resume(req.Content.actionId)
          : n$.Debug.Workflow.warning(
              "FrontEndAsync.ResumeWorkflow invoked, with no active workflow. Check the back end!"
            );
      };
    })();

    /********** SUBMODULE: FrontEndAsync.Workflow **********/
    (() => {
      n$.AsyncRequestHandlers.Workflow = function (req) {
        var workflow = n$.Workflow.getById(req.WorkflowId);
        var workflowStep = workflow ? workflow[req.StepName] : undefined;

        if (req.Content.explicit === true) {
          setTimeout(function () {
            if (!workflow && req.Content.nested) return;
            n$.Workflow.nest(workflow, req);
          });
          return;
        }

        if (!workflow || !workflowStep) {
          n$.Debug.Workflow.error(
            "A workflow step " +
              req.WorkflowName +
              "." +
              req.StepName +
              " was requested, but this " +
              (workflow && !workflowStep
                ? "workflow step does not exist in the specified workflow."
                : "workflow is not currently running."),
            true
          );
          return;
        }

        if (workflow._backEndId && workflow._backEndId !== req.BackEndId) {
          n$.Debug.Workflow.error(
            "Unexpected workflow step invoked. BackEndId mismatch at " +
              req.WorkflowName +
              "." +
              req.StepName +
              " (stored: " +
              workflow._backEndId +
              ", received: " +
              req.BackEndId +
              ")"
          );
          n$.Events.AbortAllWorkflows.raise({}, function () {
            workflow._abortWorkflow();
            n$.Workflow.abortAll();
          });
          return;
        }

        workflow.continueAtStep = workflowStep;
      };
      n$.AsyncRequestHandlers.Workflow.immediate = true;
    })();

    /********** SUBMODULE: FrontEndAsync.Workflow **********/
    (() => {
      function parametersToObj(params) {
        var result = {};
        for (var p in params) {
          if (params.hasOwnProperty(p)) {
            if (typeof params[p] === "object" && params[p] instanceof Number) {
              var val = params[p].valueOf();
              for (var v in params[p]) {
                if (params[p].hasOwnProperty(v)) {
                  if (params[p][v] === val) {
                    result[p] = v;
                  }
                }
              }
            } else result[p] = params[p];
          }
        }
        return result;
      }

      n$.AsyncRequestHandlers.WorkflowCallCompleted = function (req) {
        var content = req.Content._trace
          ? {
              duration: req.Content._trace.durationBefore
                ? {
                    before: req.Content._trace.durationBefore,
                  }
                : {
                    all: req.Content._trace.durationAll,
                    action: req.Content._trace.durationAction,
                    data: req.Content._trace.durationData,
                    overhead: req.Content._trace.durationOverhead,
                  },
              raw: req.Content._trace,
            }
          : {};

        if (!req.Success) {
          content.error = {
            silent: !req.ThrowError,
            message: req.ErrorMessage,
          };
        }

        var workflow = n$.Workflow.getById(req.WorkflowId, true);

        if (workflow) {
          content.workflow = {
            id: workflow.workflowId,
            name: workflow.name,
            step:
              req.Content._trace && req.Content._trace.durationBefore
                ? "OnBeforeWorkflow"
                : workflow.thisStep &&
                  workflow.thisStep instanceof n$.Workflow.Task
                ? workflow.thisStep.name
                : "",
            parameters: workflow.parameters
              ? parametersToObj(workflow.parameters)
              : {},
          };
        }

        n$.Debug.Workflow.logJson({
          event: "WorkflowCallCompleted",
          data: content,
        });

        if (!req.Success) {
          n$.Debug.Workflow.warning("C/AL error: " + req.ErrorMessage);
          if (req.ThrowError && req.ErrorMessage) {
            dragonglass.popup.error({
              title: "Error",
              caption: req.ErrorMessage,
            });
          }
          workflow && workflow.fail(req.ActionId);
          return;
        }

        if (!workflow && req.WorkflowId === 0 && req.ActionId === 0) return;

        workflow.receiveComplete(req.ActionId);
      };
      n$.AsyncRequestHandlers.WorkflowCallCompleted.immediate = true;
      n$.AsyncRequestHandlers.WorkflowCallCompleted.notrace = false;
    })();
  })();

  /********** MODULE: Workflow **********/
  (() => {
    var workflowId = 0;
    var actionId = 0;
    var globalContext = {};

    function getNextActionId() {
      return ++actionId;
    }

    var coordinator = (function () {
      var workflows, failed, paused;
      var known = {};
      var queue = [];
      var busy = false;
      var awaitCount = 0;
      var awaitInterval = 0;
      var firstAwait, lastAwait;

      function clearAwait(resetCounter) {
        resetCounter && ((awaitCount = 0), (firstAwait = 0), (lastAwait = 0));
        awaitInterval && (clearTimeout(awaitInterval), (awaitInterval = 0));
      }

      function resetEngineAfterFailure() {
        const _dg_redux_state = dragonglass.store.getState();
        if (_dg_redux_state.popups.length) return;

        clearAwait(true);

        dragonglass.popup
          .confirm({
            caption:
              "This seems to not be working, you are clicking buttons, but there is no response. While it may be that an operation is taking too long to complete, we suspect something went wrong.<br>" +
              "If you agree with us, then please click Yes." +
              "<br><br>" +
              "Do you want us to fix this for you?" +
              "<br><br>" +
              "This will make the buttons respond again, but may lose the information of the last action you made including all actions you attempted while the system seemed unresponsive.",
            title: "The buttons seem unresponsive...",
          })
          .then((res) => res && resetEngine());
      }

      function beginAwait() {
        clearAwait();
        if (!busy || !queue.length) return;

        firstAwait || (firstAwait = Date.now());
        var now = Date.now();

        if (++awaitCount >= 3) {
          awaitInterval = setTimeout(resetEngineAfterFailure, 1000);
          return;
        }
        (now - lastAwait < 250 || now - firstAwait > 30000) &&
          (awaitInterval = setTimeout(resetEngineAfterFailure, 10000));

        lastAwait = Date.now();
      }

      function resetEngine() {
        if (workflows && typeof workflows === "object") {
          Object.keys(workflows).forEach((key) => {
            const workflow = workflows[key];
            if (
              key &&
              typeof workflow.outerPromiseCompletionCallback === "function"
            )
              workflow.outerPromiseCompletionCallback();
          });
        }
        workflows = {};
        globalContext = {};
        queue = [];
        busy = false;
        failed = false;
        paused = false;
        clearAwait(true);
      }
      resetEngine();

      var result = {
        workflow: {
          // Indicates if the workflow engine is in the failed state
          isFailed: function () {
            return failed;
          },

          // Aborts all currently active workflows and resets the state in the front end
          abortAll: function (force) {
            if (!force) {
              for (var w in workflows) {
                if (workflows.hasOwnProperty(w)) {
                  var workflow = workflows[w];
                  workflow instanceof n$.Workflow.Workflow &&
                    workflow.abandon();
                  coordinator.workflow.completeOuterWorkflowPromise(workflow);
                }
              }
            }
            resetEngine();
          },

          // Puts the workflow engine in the failed state and aborts all workflows in both the front and the back end
          fail: function (msg) {
            failed = true;
            n$.Events.AbortAllWorkflows.raise({});
            this.abortAll(true);
            msg && typeof msg === "string" && n$.Debug.Workflow.error(msg);
          },

          // Puts the workflow engine in the failed state and completes the current workflow
          failWorkflow: function (workflow) {
            failed = true;
            var me = this;
            n$.Events.AbortWorkflow.raise(
              { id: workflow.workflowId },
              function () {
                me.completeWorkflow(workflow);
              }
            );
          },

          nest: function (parent, req) {
            parent && parent.pause();
            const actionInfo = {
              Parameters: req.Content.workflowParameters,
              Content: parent && parent.actionContent,
              _nestingContext: req.Content.workflowContext,
              _nested: true,
            };
            dragonglass.executeKnownWorkflow(
              req.WorkflowName,
              actionInfo,
              parent
            );
          },

          pause: function () {
            paused = true;
          },

          resume: function () {
            paused = false;
          },

          // Registers a new workflow, assigns it a unique id, and puts it on the execution stack
          register: function (workflow) {
            workflow.workflowId = ++workflowId;
            workflows[workflowId] = workflow;
          },

          start: function (workflow, callback) {
            workflow.outerPromiseCompletionCallback = callback;
            setTimeout(function () {
              n$.Debug.Workflow.log({
                event: "Starting workflow execution",
                data: { name: workflow.name },
              });

              function next() {
                n$.Debug.Workflow.log(
                  "Workflow execution completed, looking up next."
                );

                clearAwait(true);
                busy = false;

                var wkf = queue.shift();
                if (wkf) {
                  n$.Debug.Workflow.log({
                    event: "-> Unqueueing workflow",
                    data: { remaining: queue.length, name: wkf.name },
                  });
                  busy = true;
                  setTimeout(function () {
                    queue.length && beginAwait();
                    wkf.execute(next);
                  });
                }
              }

              if (workflow instanceof n$.Workflow.Workflow) {
                if (busy || queue.length) {
                  n$.Debug.Workflow.log({
                    event: "-> Queueing workflow",
                    data: { awaiting: queue.length, name: workflow.name },
                  });
                  queue.push(workflow);
                  beginAwait();
                  return;
                }
                busy = true;
                setTimeout(function () {
                  workflow.execute(next);
                });
              }
            });
          },

          // Retrieves a workflow by an ID, and optionally throws an error
          getById: function (id, throwError) {
            if (!workflows[id]) {
              id &&
                throwError &&
                n$.Debug.Workflow.error(
                  "Workflow has been requested by ID " +
                    id +
                    ", but that workflow either has completed or was aborted. This is a programming bug, not a user error."
                );
              return null;
            }
            return workflows[id];
          },

          // Sets context of an object specified by name
          setContext: function (object, context, workflow) {
            var obj;
            switch (object) {
              case "temp":
              case "tmp":
                obj = workflow.temp;
                break;
              case "transaction":
                obj = n$.Workflow.transactionTemp;
                break;
              case "session":
                obj = n$.Workflow.sessionTemp;
                break;
              case "global":
                obj = globalContext;
                break;
              default:
                this.fail(
                  "Context was provided for unknown or unsupported object [" +
                    object +
                    "]."
                );
                return;
            }
            if (!obj) {
              this.fail(
                "Context was provided for object [" +
                  obj +
                  "], but this object is not available (even though by all means it should be)."
              );
              return;
            }
            $.extend(obj, context);
          },

          completeOuterWorkflowPromise: function (wkf) {
            if (wkf._completedOuterWorkflowPromise) return;

            wkf._completedOuterWorkflowPromise = true;
            wkf.outerPromiseCompletionCallback &&
              typeof wkf.outerPromiseCompletionCallback === "function" &&
              wkf.outerPromiseCompletionCallback();
          },

          completeWorkflow: function (wkf) {
            var completed = delete workflows[wkf.workflowId];
            if (!completed) {
              n$.Debug.Workflow.warning(
                "Complete operation was invoked by workflow [" +
                  wkf.name +
                  ", " +
                  wkf.workflowId +
                  "] but it is not the current workflow. Stack is being cleared, but back-end code must be checked for errors."
              );
              resetEngine();
              return;
            }

            n$.Debug.Workflow.log(
              "Workflow " +
                wkf.name +
                " has completed as a " +
                (wkf.nested ? "nested" : "top-level") +
                " workflow."
            );

            coordinator.workflow.completeOuterWorkflowPromise(wkf);
            wkf.workflowCompletionCallback &&
              typeof wkf.workflowCompletionCallback === "function" &&
              wkf.workflowCompletionCallback(wkf);

            if (wkf.nested && wkf.parent instanceof n$.Workflow.Workflow) {
              wkf.parent.resume();
            }

            (failed || !Object.keys(workflows).length) && resetEngine();
          },
        },
      };
      return result;
    })();

    n$.Workflow = {
      // Static space
      getById: coordinator.workflow.getById,
      registerKnown: coordinator.workflow.registerKnown,
      setContext: coordinator.workflow.setContext,
      abortAll: coordinator.workflow.abortAll,
      fail: coordinator.workflow.fail,
      nest: coordinator.workflow.nest,
      start: coordinator.workflow.start,

      // Classes

      Workflow: function (workflow, parameters, content, parent) {
        var me = this;
        parent &&
          parent instanceof n$.Workflow.Workflow &&
          ((me.parent = parent), (me.nested = true));

        coordinator.workflow.register(me);

        this.model = {};
        this.context = {};

        this._initOptions(parameters);

        this.actionContent = content || {};
        this.alive = true;
        this.name = workflow.Name;
        this.state = {};
        this.parameters = parameters || {};
        this.thisStep = null;
        this.running = false;
        this.invokeBefore = !!workflow.RequestContext;
        this.requestContext = {};

        var lastStep = null;
        workflow.Steps.forEach(function (step) {
          var thisStep = new n$.Workflow.Step(step, me);
          me[step.Label] = thisStep;
          lastStep && (lastStep.nextStep = thisStep);
          me.thisStep || (me.thisStep = thisStep);
          lastStep = thisStep;
        });
      },

      Task: function () {
        this._proto_execute = this.execute;
      },

      Callable: function () {},

      Step: function (step, workflow) {
        this._queue = [];

        this.name = step.Label;
        this.label = step.Label;
        this.code = step.Code;
        this.workflow = workflow;
      },

      Chain: function (func, args, step) {
        this.step = step;
        this.workflow = step.workflow;

        this._queue = [];
        this._setup(func, args);
        this._initialize();
      },

      Command: function (func, args, step) {
        this.step = step;
        this.workflow = step.workflow;

        this._setup(func, args);
      },

      Result: function (func, args, chain) {
        this.chain = chain;
        this.step = chain.step;
        this.workflow = chain.step.workflow;

        this._setup(func, args);
      },

      ActionHandler: function (button) {
        this.button = button;
        this.workflow = null;
      },
    };

    // Workflow prototype
    (function () {
      function newResponseContext(callback) {
        if (!callback) callback = null;

        if (callback && typeof callback !== "function")
          n$.Debug.Workflow.error(
            "A front-end Workflow has requested a new response context, but has provided a callback parameter that's not a function."
          );

        var callbackReceived = false;
        var completeReceived = false;
        var completelyProcessed = false;
        var failed = false;
        function process() {
          completelyProcessed &&
            n$.Debug.Workflow.error(
              "There was an attempt to process again a front-end workflow that has already been fully processed."
            );

          completelyProcessed = callbackReceived && completeReceived;
          completelyProcessed && !failed && callback && callback();
        }
        var context = {
          receiveComplete: function () {
            process((completeReceived = true));
          },
          receiveCallback: function () {
            if (failed) return;
            process((callbackReceived = true));
          },
          fail: function () {
            failed = true;
          },
        };
        Object.defineProperty(context, "failed", {
          get: function () {
            return failed;
          },
        });
        Object.defineProperty(context, "callbackReceived", {
          get: function () {
            return callbackReceived;
          },
        });
        Object.defineProperty(context, "completeReceived", {
          get: function () {
            return completeReceived;
          },
        });
        return context;
      }

      function getRequestContext(workflow, id) {
        id = id || 0;
        if (
          !workflow.requestContext ||
          !workflow.requestContext[id] ||
          typeof workflow.requestContext[id] !== "object"
        )
          n$.Debug.Workflow.error(
            "Response context id " +
              id +
              " was requested from workflow [" +
              workflow.name +
              "." +
              workflow.workflowId +
              "], but it does not exist."
          );
        return workflow.requestContext[id];
      }

      // public space
      n$.Workflow.Workflow.prototype.getEventData = function (id) {
        var data = { workflow: this.name, workflowId: this.workflowId };
        id && (data.actionId = id);
        return data;
      };
      n$.Workflow.Workflow.prototype.fail = function (id) {
        n$.Debug.Workflow.log({
          event: "Workflow fail requested",
          data: this.getEventData(id),
        });

        this.alive = false;
        getRequestContext(this, id).fail();
        coordinator.workflow.failWorkflow(this);
      };
      n$.Workflow.Workflow.prototype.receiveComplete = function (id) {
        getRequestContext(this, id).receiveComplete();
      };
      n$.Workflow.Workflow.prototype.receiveCallback = function (id) {
        n$.Debug.Workflow.log({
          event: id
            ? "Workflow callback received"
            : "BeforeWorkflow callback received",
          data: this.getEventData(id),
        });
        getRequestContext(this, id).receiveCallback();
      };

      n$.Workflow.Workflow.prototype._initOptions = function (p) {
        for (var o in p) {
          if (p.hasOwnProperty(o) && o.lastIndexOf("_option_") === 0) {
            var option = o.substring(8);
            p[option] = new Number(p[option]);
            for (var v in p[o]) {
              if (p[o].hasOwnProperty(v)) {
                p[option][v] = p[o][v];
              }
            }
            delete p[o];
          }
        }
      };
      n$.Workflow.Workflow.prototype.invokeBeforeWorkflow = function (
        callback
      ) {
        n$.Debug.Workflow.log({ event: "BeforeWorkflow", data: this.name });
        var me = this;
        me.requestContext[0] = newResponseContext(callback);

        n$.Events.BeforeWorkflow.raise(
          {
            action: this.name,
            parameters: this.parameters,
            workflowId: me.workflowId,
          },
          function () {
            me.receiveCallback();
          }
        );
      };
      n$.Workflow.Workflow.prototype._stepCompleted = function (step) {
        var me = this;
        if (me.thisStep._pauseProcessing) return;

        step._abort
          ? me._abortWorkflow()
          : ((me.thisStep = me.continueAtStep || me.thisStep.nextStep),
            me.continueAtStep && delete me.continueAtStep,
            me.thisStep &&
              (me._paused ||
                setTimeout(function () {
                  me.thisStep.execute();
                })));
        me.thisStep || coordinator.workflow.completeWorkflow(me);
      };
      n$.Workflow.Workflow.prototype._goto = function (step) {
        var me = this;
        me.thisStep = step;
        setTimeout(function () {
          me._paused || me.thisStep.execute();
        });
      };
      n$.Workflow.Workflow.prototype._abortWorkflow = function (force) {
        var me = this;
        me.alive = false;
        function completeAbort() {
          force
            ? coordinator.workflow.abortAll(true)
            : coordinator.workflow.completeWorkflow(me);
        }

        me._backEndId && me._responded
          ? n$.Events.AbortWorkflow.raise({ id: me.workflowId }, completeAbort)
          : completeAbort();
      };
      n$.Workflow.Workflow.prototype._respond = function (
        stepname,
        context,
        callback
      ) {
        if (
          typeof stepname === "function" &&
          context === undefined &&
          callback === undefined
        ) {
          callback = stepname;
          stepname = undefined;
        }

        var me = this;
        context = context || {};
        context.data = dragonglass.getDataStates();

        if (this.getInitialContext) {
          context = { ...this.getInitialContext(), ...context };
        }

        context = { ...context, ...me.context };
        me._backEndId && (context.backEndid = me._backEndId);
        context.parameters = me.parameters;

        var actionId = getNextActionId();
        me.requestContext[actionId] = newResponseContext(callback);
        n$.Events.Action.raise(
          [me.name, stepname || "", me.workflowId, actionId, context],
          function () {
            me.receiveCallback(actionId);
          }
        );
      };
      n$.Workflow.Workflow.prototype.abandon = function () {
        this._abortWorkflow(true);
      };
      n$.Workflow.Workflow.prototype.execute = function (callback) {
        n$.Debug.Workflow.log("Starting execution of workflow: " + this.name);

        if (coordinator.workflow.isFailed()) {
          n$.Debug.Workflow.warning(
            "-> The workflow engine is in the failed state, aborting execution without any further action."
          );
          return;
        }

        var me = this;
        if (!me.alive) {
          n$.Debug.Workflow.log(
            "-> This workflow is no longer alive, aborting execution with no further action taken by this instance."
          );
          return;
        }

        const _dg_redux_state = dragonglass.store.getState();
        me.running = true;
        this.view = {
          login: _dg_redux_state.view.active === "login",
          sale: _dg_redux_state.view.active === "sale",
          payment: _dg_redux_state.view.active === "payment",
          restaurant: _dg_redux_state.view.active === "restaurant",
        };

        function execute() {
          me.workflowCompletionCallback = callback;
          me.thisStep
            ? me.thisStep.execute(function () {
                me._stepCompleted(me.thisStep);
              })
            : me._respond(function () {
                coordinator.workflow.completeWorkflow(me);
              });
        }

        me.invokeBefore ? me.invokeBeforeWorkflow(execute) : execute();
      };
      n$.Workflow.Workflow.prototype.pause = function () {
        if (!this.running) {
          n$.Debug.Workflow.warning(
            "Pause invoked on a workflow that is not running yet, or anymore."
          );
          return;
        }

        this._paused = true;
        this.nested || coordinator.workflow.pause();
      };
      n$.Workflow.Workflow.prototype.resume = function (actionId) {
        if (!this.running) {
          n$.Debug.Workflow.warning(
            "Resume invoked on a workflow that is not running yet, or anymore."
          );
          return;
        }

        var context = actionId && getRequestContext(this, actionId);
        var execute = context ? context.callbackReceived : true;

        this.nested || coordinator.workflow.resume();
        this._paused &&
          this.thisStep &&
          (delete this._paused,
          execute && this.thisStep.execute(),
          delete this._pausedId);
      };
    })();

    // Task prototype
    n$.Workflow.Task.prototype._type = "Task";
    n$.Workflow.Task.prototype._setAbortFlags = function () {
      this._abort = true;
      this.workflow._abort = true;
    };
    n$.Workflow.Task.prototype._abortIfStepNotDone = function (task) {
      return (
        this instanceof n$.Workflow.Step &&
        this._queue.length &&
        (this._setAbortFlags(),
        n$.Debug.Workflow.error(
          "A workflow task [" +
            task +
            "] has been invoked with other tasks still awaiting execution in workflow step [" +
            this.name +
            "]. This task can only be invoked last in a workflow step."
        ),
        true)
      );
    };
    n$.Workflow.Task.prototype.name = "[Task]";
    n$.Workflow.Task.prototype.execute = function (done) {
      if (coordinator.workflow.isFailed()) {
        n$.Debug.Workflow.warning(
          "Workflow engine in a failed state, and step execution is initiated. Aborting all."
        );
        return;
      }

      var me = this;

      function next() {
        if (me.workflow._abort) {
          done && done();
          return;
        }
        me._queue && me._queue instanceof Array && me._queue.length
          ? me._queue.shift().execute(next)
          : done && done();
      }

      this.workflow._abort ? done && done() : this.call(next);
    };
    n$.Workflow.Task.prototype.call = function (done) {
      done();
    };

    // Callable prototype
    n$.Workflow.Callable.prototype = new n$.Workflow.Task();
    n$.Workflow.Callable.prototype._setup = function (func, args) {
      this.name = func;
      this.callObject = {
        function: this._functions[func],
        arguments: args,
      };
    };
    n$.Workflow.Callable.prototype._continue = function () {
      return true;
    };
    n$.Workflow.Callable.prototype.call = function (done) {
      this._continue()
        ? this.callObject.function.apply(this, [
            { arguments: this.callObject.arguments, callback: done },
          ])
        : done();
      this instanceof n$.Workflow.Chain && (this.workflow._lastChain = this);
    };

    // Step prototype
    n$.Workflow.Step.prototype = new n$.Workflow.Task();
    n$.Workflow.Step.prototype._type = "Step";
    n$.Workflow.Step.prototype._initialize = function () {
      var me = this;

      function getProxy(name) {
        return function () {
          var cmd = me._commands[name].apply(me, arguments);
          me._queue.push(cmd);
          return cmd;
        };
      }

      me.workflow.temp = me.workflow.temp || {};
      n$.Workflow.sessionTemp = n$.Workflow.sessionTemp || {};
      n$.Workflow.transactionTemp = n$.Workflow.transactionTemp || {};

      const state = dragonglass.store.getState();
      const dataState = state.data;
      const dataSource = dataState.sources[me.workflow.dataSource];
      const dataSet = dataState.sets[me.workflow.dataSource];
      const localization = state.localization.Actions[me.workflow.name];

      const row = dataSet
        ? dataSet.rows.find((r) => r.position === dataSet.currentPosition)
        : null;
      const dataFunc = (() => {
        const data = (field) => {
          return row && row.fields ? row.fields[field] : null;
        };

        data.isEmpty = () => !dataSet.rows.length;
        return data;
      })();
      eval(
        "var temp = me.workflow.temp, tmp = temp, data = dataFunc, transaction = n$.Workflow.transactionTemp, session = n$.Workflow.sessionTemp, global = globalContext, context = me.workflow.context, model = me.workflow.model, param = me.workflow.parameters, parameters = param, labels = localization, view = me.workflow.view;"
      );
      for (var f in this._commands)
        if (this._commands.hasOwnProperty(f)) {
          this._commands[f].chain = this;
          var proxy = getProxy(f);
          proxy && eval("var " + f + " = proxy;");
        }

      try {
        eval(this.code);
      } catch (e) {
        this.workflow.abandon();
        n$.Debug.Workflow.error(
          "A JavaScript runtime error occurred while executing this workflow step: " +
            this.code +
            " The error message is: " +
            e
        );
      }
    };
    n$.Workflow.Step.prototype._respond = function (context, task, callback) {
      var me = this;
      if (me._abortIfStepNotDone(task)) {
        callback();
        return;
      }

      me.workflow._respond(me.name, context, callback);
    };
    n$.Workflow.Step.prototype._commands = {
      numpad: function () {
        return new n$.Workflow.Chain("numpad", arguments, this);
      }, // done
      intpad: function () {
        return new n$.Workflow.Chain("intpad", arguments, this);
      }, // done
      datepad: function () {
        return new n$.Workflow.Chain("datepad", arguments, this);
      },
      stringpad: function () {
        return new n$.Workflow.Chain("stringpad", arguments, this);
      }, // done
      passwordpad: function () {
        return new n$.Workflow.Chain("passwordpad", arguments, this);
      }, // done
      confirm: function () {
        return new n$.Workflow.Chain("confirm", arguments, this);
      }, // done
      input: function () {
        return new n$.Workflow.Chain("input", arguments, this);
      }, // done
      password: function () {
        return new n$.Workflow.Chain("password", arguments, this);
      }, // done
      message: function () {
        return new n$.Workflow.Command("message", arguments, this);
      }, // done
      error: function () {
        return new n$.Workflow.Command("error", arguments, this);
      }, // done

      hyperlink: function () {
        return new n$.Workflow.Command("hyperlink", arguments, this);
      },
      respond: function () {
        return new n$.Workflow.Command("respond", arguments, this);
      },
      end: function () {
        return new n$.Workflow.Command("end", arguments, this);
      },
      goto: function () {
        return new n$.Workflow.Command("goto", arguments, this);
      },
      store: function () {
        return new n$.Workflow.Command("store", arguments, this);
      },
      abort: function () {
        return new n$.Workflow.Command("abort", arguments, this);
      },
      dim: function () {
        return new n$.Workflow.Command("dim", arguments, this);
      },
      undim: function () {
        return new n$.Workflow.Command("undim", arguments, this);
      },
    };
    n$.Workflow.Step.prototype.execute = function (done) {
      var me = this;
      done ||
        (done = function () {
          me.workflow._stepCompleted(me);
        });
      this.workflow._abort
        ? done()
        : (this._initialize(), this._proto_execute(done));
    };

    // Chain prototype
    n$.Workflow.Chain.prototype = new n$.Workflow.Callable();
    n$.Workflow.Chain.prototype._proto_call = n$.Workflow.Chain.prototype.call;
    n$.Workflow.Chain.prototype._initialize = function () {
      var me = this;

      function getProxy(name) {
        return function () {
          var cmd = new n$.Workflow.Result(name, arguments, me);
          cmd._initializers.hasOwnProperty(name) &&
            cmd._initializers[name].apply(cmd);
          me._queue.push(cmd);
          return me;
        };
      }

      this._methods.forEach(function (f) {
        me[f] = getProxy(f);
      });
    };
    n$.Workflow.Chain.prototype._continue = function () {
      return this._executed
        ? this.hasOwnProperty("_continueFlag")
          ? this._continueFlag
          : this.getResult().success
        : true;
    };
    n$.Workflow.Chain.prototype._type = "Chain";
    n$.Workflow.Chain.prototype._methods = [
      "respond",
      "store",
      "when",
      "then",
      "end",
      "goto",
      "ok",
      "cancel",
      "yes",
      "no",
      "abort",
      "debug",
      "do",
    ];
    n$.Workflow.Chain.prototype._storeResult = function (name, value) {
      this.workflow.context["$" + this.step.name] ||
        (this.workflow.context["$" + this.step.name] = {});
      this.workflow.context["$" + this.step.name][name] = value;
    };
    n$.Workflow.Chain.prototype._functions = {
      _numpad: function (args, type, masked) {
        var me = this;
        (function (title, caption, value, notblank, store) {
          var par = typeof title === "object" ? title : {};

          if (typeof title !== "object") {
            caption === undefined ? (caption = title) : (par.title = title);
            par.caption = caption;
            value && (par.value = value);
            notblank && (par.notBlank = notblank);
          } else {
            store = caption;
          }
          par.title =
            par.title || dragonglass.localization().DialogCaption_Confirmation;
          masked && (par.masked = true);
          par.type =
            dragonglass.enums.inputType[type || n$.Enums.NumpadType.Decimal];
          typeof store !== "string" && (store = "numpad");
          dragonglass.popup.numpad(par).then((result) => {
            result !== null && me._storeResult(store, result);
            me.getResult = function () {
              return {
                success: result !== null,
                value: result || 0,
                cancel: result === null,
                ok: result !== null,
              };
            };
            args.callback();
          });
        }.apply(this, args.arguments));
      },
      numpad: function (args) {
        n$.Workflow.Chain.prototype._functions._numpad.call(
          this,
          args,
          n$.Enums.NumpadType.Decimal
        );
      },
      intpad: function (args) {
        n$.Workflow.Chain.prototype._functions._numpad.call(
          this,
          args,
          n$.Enums.NumpadType.Integer
        );
      },
      stringpad: function (args) {
        n$.Workflow.Chain.prototype._functions._numpad.call(
          this,
          args,
          n$.Enums.NumpadType.Text
        );
      },
      passwordpad: function (args) {
        n$.Workflow.Chain.prototype._functions._numpad.call(
          this,
          args,
          n$.Enums.NumpadType.Text,
          true
        );
      },
      datepad: function (args) {
        n$.Workflow.Chain.prototype._functions._numpad.call(
          this,
          args,
          n$.Enums.NumpadType.Date
        );
      },
      confirm: function (args) {
        var me = this;
        (function (title, caption, store) {
          var par = typeof title === "object" ? title : {};

          if (typeof title !== "object") {
            caption === undefined ? (caption = title) : (par.title = title);
            par.caption = caption;
          } else {
            store = caption;
          }

          typeof store !== "string" && (store = "confirm");
          dragonglass.popup.confirm(par).then((result) => {
            var yes = result === true;
            me._storeResult(store, yes);
            me.getResult = function () {
              return {
                success: yes,
                value: yes,
                yes: yes,
                no: !yes,
              };
            };
            args.callback();
          });
        }.apply(this, args.arguments));
      },
      input: function (args, masked) {
        var me = this;
        (function (title, caption, instruction, value, notblank, store) {
          var par = typeof title === "object" ? title : {};

          if (typeof title !== "object") {
            caption === undefined ? (caption = title) : (par.title = title);
            par.caption = caption;
            instruction && (par.instruction = instruction);
            value && (par.value = value);
            notblank && (par.notBlank = notblank);
          } else {
            store = caption;
          }
          masked && (par.masked = masked);

          typeof store !== "string" && (store = "input");
          dragonglass.popup.input(par).then((result) => {
            result !== null && me._storeResult(store, result);
            me.getResult = function () {
              return {
                success: result !== null,
                value: result,
                ok: result !== null,
                cancel: result === null,
              };
            };
            args.callback();
          });
        }.apply(this, args.arguments));
      },
      password: function (args) {
        n$.Workflow.Chain.prototype._functions.input.call(this, args, true);
      },
      calendar: function (args) {
        var me = this;
        (function (title, caption, store) {
          var par = typeof title === "object" ? title : {};

          if (typeof title !== "object") {
            caption === undefined ? (caption = title) : (par.title = title);
            par.caption = caption;
          } else {
            store = caption;
          }

          typeof store !== "string" && (store = "calendar");
          par.dataSource = "BUILTIN_SALELINE";

          dragonglass.popup.calendarPlusGrid(par).then((result) => {
            result !== null && me._storeResult(store, result);
            me.getResult = function () {
              return {
                success: result !== null,
                value: result,
                ok: result !== null,
                cancel: result === null,
              };
            };
            args.callback();
          });
        }.apply(me, args.arguments));
      },
    };
    n$.Workflow.Chain.prototype.call = function () {
      this._proto_call.apply(this, arguments);
      this._executed = true;
    };
    n$.Workflow.Chain.prototype.getResult = function () {
      return { success: !this._executed };
    };

    // Command prototype
    (function () {
      function showPopupThroughFunc(args, popupFunc) {
        ((title, caption) => {
          var par = typeof title === "object" ? title : {};
          if (typeof title !== "object") {
            caption === undefined ? (caption = title) : (par.title = title);
            par.caption = caption;
          }
          popupFunc(par).then(
            () => typeof args.callback === "function" && args.callback()
          );
        }).apply(this, args.arguments);
      }

      n$.Workflow.Command.prototype = new n$.Workflow.Callable();
      n$.Workflow.Command.prototype._type = "Command";
      n$.Workflow.Command.prototype._functions = {
        error: function (args) {
          showPopupThroughFunc.call(this, args, dragonglass.popup.error);
        },
        message: function (args) {
          showPopupThroughFunc.call(this, args, dragonglass.popup.message);
        },
        menu: function (args) {
          (function (caption, menu, columns, rows) {
            rows === undefined &&
              typeof menu === "number" &&
              ((rows = columns),
              (columns = menu),
              (menu = caption),
              (caption = n$.Menu.prototype.__menus[menu].Caption));
            menu === undefined &&
              ((menu = caption),
              (caption = n$.Menu.prototype.__menus[menu].Caption));
            dragonglass.popup
              .menu({
                Caption: caption,
                rows: rows,
                columns: columns,
                menu: menu,
              })
              .then(() => args.callback());
          }.apply(this, args.arguments));
        },
        hyperlink: function (args) {
          args.callback();
        },
        respond: function (args) {
          (function (name, value) {
            var ctx = {};
            typeof name !== "undefined" &&
              typeof value !== "undefined" &&
              (ctx[name] = value);
            this.step._respond(ctx, "respond", args.callback);
          }.apply(this, args.arguments));
        },
        store: function (args) {
          var me = this;
          (function (name, value) {
            value === undefined &&
              me.workflow._lastChain &&
              (value = me.workflow._lastChain.getResult().value);
            me.workflow.context[name] = value;
          }.apply(this, args.arguments));
          args.callback();
        },
        end: function (args) {
          args.callback();
        },
        goto: function (args) {
          (function (step) {
            if (this.workflow[step] instanceof n$.Workflow.Step)
              this.workflow._goto(this.workflow[step]);
            else
              throw new Error(
                "Workflow step [" +
                  step +
                  "] was invoked, but that step does not exist."
              );
          }.apply(this, args.arguments));
        },
        set: function (args) {
          args.callback();
        },
        abort: function () {
          this.workflow._abortWorkflow();
        },
        dim: function (args) {
          // unsupported
          args.callback();
        },
        undim: function (args) {
          // unsupported
          args.callback();
        },
      };
    })();

    // Result prototype
    n$.Workflow.Result.prototype = new n$.Workflow.Callable();
    n$.Workflow.Result.prototype._type = "Result";
    n$.Workflow.Result.prototype._functions = {
      respond: function (args) {
        var me = this;
        (function (name) {
          var ctx = {};
          name
            ? (ctx[name] = me.chain.getResult().value)
            : (ctx = me.chain.getResult());
          me.step._respond(ctx, "respond", args.callback);
        }.apply(this, args.arguments));
      },
      ok: function (args) {
        this.chain._continueFlag = !!this.chain.getResult().ok;
        this._applyArgumentFunction(args);
        args.callback();
      },
      cancel: function (args) {
        this.chain._continueFlag = !!this.chain.getResult().cancel;
        this._applyArgumentFunction(args);
        args.callback();
      },
      yes: function (args) {
        this.chain._continueFlag = !!this.chain.getResult().yes;
        this._applyArgumentFunction(args);
        args.callback();
      },
      no: function (args) {
        this.chain._continueFlag = !!this.chain.getResult().no;
        this._applyArgumentFunction(args);
        args.callback();
      },
      store: function (args) {
        var me = this;
        (function (name) {
          me.workflow.context[name] = me.chain.getResult().value;
        }.apply(this, args.arguments));
        args.callback();
      },
      when: function (args) {
        args.callback();
      },
      then: function (args) {
        args.callback();
      },
      end: function () {},
      goto: function (args) {
        (function (step) {
          if (this.workflow[step] instanceof n$.Workflow.Step)
            this.workflow._goto(this.workflow[step]);
          else
            throw new Error(
              "Workflow step [" +
                step +
                "] was invoked, but that step does not exist."
            );
        }.apply(this, args.arguments));
      },
      abort: function () {
        this.workflow._abortWorkflow();
      },
      debug: function (args) {
        args.callback();
      },
      do: function (args) {
        (function (func) {
          typeof func === "function" && func();
        }.apply(this, args.arguments));
        args.callback();
      },
    };
    n$.Workflow.Result.prototype._initializers = {
      cancel: function () {
        this._continue = function () {
          return true;
        };
      },
      ok: function () {
        this._continue = function () {
          return true;
        };
      },
      yes: function () {
        this._continue = function () {
          return true;
        };
      },
      no: function () {
        this._continue = function () {
          return true;
        };
      },
    };
    n$.Workflow.Result.prototype._applyArgumentFunction = function (args) {
      if (!this.chain._continueFlag || typeof args.arguments[0] !== "function")
        return;
      var func = args.arguments[0];
      var arguments = Array.prototype.slice.call(args.arguments);
      arguments.splice(0, 1);
      func.apply(this.chain, arguments);
    };
    n$.Workflow.Result.prototype._continue = function () {
      return this.chain._continue();
    };

    // ActionHandler Prototype
    n$.Workflow.ActionHandler.Workflow = function (button) {
      n$.Workflow.ActionHandler.call(this, button);
      this.workflow = new n$.Workflow.Workflow(
        button.action.Workflow,
        button.action.Parameters,
        button.action.Content
      );
    };
    n$.inherit(n$.Workflow.ActionHandler.Workflow, n$.Workflow.ActionHandler);
    n$.Workflow.ActionHandler.Workflow.prototype.execute = function (
      dataSource,
      callback
    ) {
      dataSource && (this.workflow.dataSource = dataSource);
      this.workflow && this.workflow instanceof n$.Workflow.Workflow
        ? n$.Workflow.start(this.workflow, callback)
        : n$.Debug.Workflow.error(
            "Action without workflow for: " + this.button.action.Type
          );
    };
  })();

  /********** MODULE: AdministrativeTemplates **********/
  (() => {
    n$.AsyncRequestHandlers.ApplyAdministrativeTemplates = (req) => {
      var package = null;
      switch (req.Content.version) {
        case "1.0":
          package = {
            version: "1.0",
            content: [],
          };
          req.Content.templates.forEach((policy, index) => {
            var template = {
              id: policy.id,
              persist: policy.persist,
              strength: policy.strength,
            };
            delete policy.id;
            delete policy.persist;
            delete policy.strength;
            template.policy = policy;
            package.content.push(template);
          });
          break;
      }
      package && dragonglass.external.applyTemplate(JSON.stringify(package));
    };
  })();

  /********** MODULE: Keyboard **********/
  (() => {
    var bindingsConfigured = false;
    var bindings = {};
    var eventKeyPress = new n$.Event.Method({ name: "KeyPress" });
    var debugKeyboard = new n$.Debug.Source("Keyboard");

    n$.AsyncRequestHandlers.ConfigureKeyboardBindings = function (req) {
      if (!req.Content || !req.Content.bindings) return;

      bindingsConfigured = true;
      bindings = req.Content.bindings;

      [].slice.call(bindings).forEach(function (key) {
        dragonglass.external.registerKeyPress(key);
      });
    };

    const keyPressed = (which) => {
      debugger;
      const _dg_redux_state = dragonglass.store.getState();
      if (
        _dg_redux_state &&
        _dg_redux_state.popups &&
        _dg_redux_state.popups.length
      ) {
        return false;
      }

      if (!bindingsConfigured || bindings.indexOf(which) === -1) {
        debugKeyboard.log("Unconfigured key press: [" + which + "]. Ignoring.");
        return false;
      }

      debugKeyboard.log(
        "Configured key press: [" + which + "]. Forwarding to NAV."
      );
      eventKeyPress.raise({ key: which });
      return true;
    };

    connectToApp({ keyPressed });
  })();

  /********** MODULE: ProtocolUI **********/
  (() => {
    var responseEvent = new n$.Event.Method({ name: "ProtocolUIResponse" });

    var models = {};
    var lastModelId = 0;
    var debug = new n$.Debug.Source("ProtocolUI");

    function createModelFrame(modelId, html, css, js) {
      var timerInterval = 0;
      var frame = document.createElement("iframe");
      frame.src = "javascript:''";
      var model = {
        modelId: modelId,
        closed: false,
        close: function () {
          if (timerInterval) frame.contentWindow.clearInterval(timerInterval);
          model.closed = true;
        },
        respond: function (mid, sender, event) {
          if (!model.closed) {
            if (
              !sender &&
              typeof frame.contentWindow["Timer_" + event] === "number"
            ) {
              timerInterval ||
                (timerInterval = frame.contentWindow["Timer_" + event]);
              sender = event = "n$_timer";
            }
            responseEvent.raise({
              modelId: mid,
              sender: sender,
              event: event || (event === undefined ? "" : event),
            });
          } else {
            debug.log(
              "Respond was invoked for a model that was previously closed through the np-behavior-close. Ignoring this event, but this indicates a possible refactoring to be needed in the back-end code."
            );
          }
        },
        invokeClose: function () {
          this.respond(modelId, "model", "close");
        },
        respondExplicit: function (sender, event) {
          this.respond(modelId, sender, event);
        },
      };

      var jq = "";
      $("head > script").each(function (i, script) {
        if ((script.src || "").indexOf("/jquery-") >= 0) {
          jq += script.outerHTML;
        }
      });

      var frameHtml =
        "<html><head>" +
        css +
        "<style>body{display:flex;align-items:center;justify-content:center;height: 100%;}</style>" +
        (jq || "") +
        "<script>function $_update(src) { var block = $(src); $('body').append(block); }</script>" +
        "<script>$(document).ready(function() { $('div.np-behavior-close').click(function() { n$.close(); }); });</script>" +
        "</head><body><div id='controlAddIn'>" +
        html +
        "</div>" +
        js +
        "</body></html>";
      var ctrl = document.getElementById("controlAddIn");
      if (!ctrl) return;

      ctrl.appendChild(frame);
      frame.contentWindow.document.open();
      frame.contentWindow.document.write(frameHtml);
      frame.contentWindow.document.close();

      frame.id = "model" + ++lastModelId;

      models[modelId] = {
        frame: $(frame).css({
          width: "100%",
          height: "100%",
          position: "absolute",
          top: "0",
          left: "0",
          margin: "0",
          padding: "0",
          border: "0",
        }),
        window: frame.contentWindow,
        focusElement: frame,
      };

      frame.contentWindow.n$ = model;
    }

    const convertModelEvent = (source, modelId) => source.replaceAll("n$.Framework.RaiseObjectModelEvent(", "n$.respond('" + modelId + "', ");

    n$.AsyncRequestHandlers.ShowModel = function (req) {
      if (!req.Content) return;

      var modelId = req.Content.modelId || "";
      var html = req.Content.html;
      var css = req.Content.css;
      var js = req.Content.script;
      html && (html = convertModelEvent(html, modelId));
      js && (js = convertModelEvent(js, modelId));

      createModelFrame(modelId, html, css, js);
    };

    n$.AsyncRequestHandlers.UpdateModel = function (req) {
      if (!req.Content) return;

      var modelId = req.Content.modelId;
      var html = req.Content.html;
      var css = req.Content.css;
      var js = req.Content.script;

      if (!modelId) {
        debug.error(
          "UpdateModel request was received without modelId parameter."
        );
        return;
      }

      var model = models[modelId];
      if (!model) {
        debug.error(
          "UpdateModel request was received for model [" +
            modelId +
            "] which was previously closed."
        );
        return;
      }

      html && (html = convertModelEvent(html, modelId), model.window["$_update"](html));
      css && model.window["$_update"](css);
      js && model.window["$_update"](js);
    };

    n$.AsyncRequestHandlers.CloseModel = function (req) {
      var modelId = req.Content.modelId || "";
      if (modelId) {
        var model = models[modelId];
        model.frame.remove();
        delete models[modelId];
        setTimeout(window.focus);
      }
    };
  })();

  /********** MODULE: Stargate **********/
  (() => {
    var contexts = {},
      lastHandle = 0,
      stargateNoSupportWarningGiven;

    function getContext(handle) {
      return contexts[handle];
    }

    function storeContext(context) {
      contexts[++lastHandle] = context;
      return (context.handle = lastHandle);
    }

    function clearContext(handle) {
      if (contexts.hasOwnProperty(handle)) delete contexts[handle];
    }

    function showStargateNoSupportMessage() {
      n$.Workflow.abortAll();
      stargateNoSupportWarningGiven ||
        dragonglass.popup.message({
          title: "Important Information",
          caption:
            "<p>So you have reached a point where your web-based POS talks to your local hardware, like printers, credit card readers or such. " +
            "But you are in a web browser, and web browsers cannot just talk to hardware. Also, you did not configure any hardware yet.</p>" +
            "<p>Don't worry, if you install our rich client, such as Major Tom for Windows, or NP Retail for iOS app, all local hardware functionality will be available to you.</p>",
        });
      stargateNoSupportWarningGiven = true;
    }

    var debug = {
      device: new n$.Debug.Source("Device"),
      stargate: new n$.Debug.Source("Stargate"),
    };

    var responseMethod = new n$.Event.Method({ name: "InvokeDeviceResponse" });
    var protocolMethod = new n$.Event.Method({
      name: "Protocol",
      processArguments: function (arg) {
        if (typeof arg.contextHandle === "number") {
          var context = getContext(arg.contextHandle);
          if (context && typeof context === "object") {
            arg.action = context.action;
            arg.step = context.step;
          }
        }
        return arg;
      },
      callback: function (args) {
        if (args.closeProtocol) {
          clearContext(args.contextHandle);
        }
      },
    });

    // This event is invoked only from Major Tom! It has no references in JavaScript, but it doesn't mean it's not used anywhere.
    n$.Events.Protocol = {
      raise: (arg) => {
        var context = getContext(arg.contextHandle);
        if (context && context.v3) {
          if (context.protocolCallback) {
            context.protocolCallback(arg, (event, data) =>
              dragonglass.external.stargate.appGatewayProtocolResponse(
                event,
                data
              )
            );
            return;
          }
          debug.device.error(
            "Protocol response received from Major Tom without a protocol callback."
          );

          return;
        }

        protocolMethod.raise(arg);
      },
    };

    var invokeDeviceId = 0;
    n$.AsyncRequestHandlers.InvokeDevice = function (req) {
      var invocationId = ++invokeDeviceId;
      var context1 =
        req.Content && req.Content.Method
          ? "Method: " + req.Content.Method
          : "";
      var context2 = req.Content.TypeName
        ? "TypeName " + req.Content.TypeName
        : "";
      var context = (context1 ? context1 + ", " : "") + context2;
      context && (context = " (" + context + ")");
      var sync =
        " [" + (req.Content && req.Content.Async ? "a" : "") + "synchronous]";
      debug.device.log(
        "InvokeDevice request received (" + invocationId + sync + ")" + context,
        req
      );

      function logEnd() {
        debug.device.log(
          "InvokeDevice request completed (" + invocationId + ")" + context,
          req
        );
      }

      if (!dragonglass.external.stargate) {
        showStargateNoSupportMessage();
        return;
      }

      if (req.Content && req.Content.Async) {
        dragonglass.external.stargate.invokeProxyAsync(req.Envelope);
        logEnd();
        return;
      }

      var response = {
        stargate: "2.0",
        id: req.Id,
        success: false,
        action: req.Content.Action,
        step: req.Content.Step,
        response: "Proxy not installed.",
      };

      dragonglass.external.stargate
        .invokeProxy(
          req.Envelope,
          storeContext({
            id: req.Id,
            action: response.action,
            step: response.step,
          })
        )
        .then((resp) => {
          if (resp == null) {
            debug.device.log(
              "Null response received from proxy. Nothing will be sent back to C/AL"
            );
            logEnd();
            return;
          }
          response.success = true;
          response.response = resp;
          logEnd();
          responseMethod.raise(response);
        })
        .catch((e) => {
          response.response = (e && e.message) || "<unknown error>";
          debug.device.warning(
            "Device invocation failed: " + response.response,
            true
          );
          logEnd();
          responseMethod.raise(response);
        });
    };

    n$.AsyncRequestHandlers.StargatePackages = function (req) {
      debug.stargate.log("StargatePackages request received", req);
      if (!dragonglass.external.stargate) {
        return;
      }

      dragonglass.external.stargate
        .advertiseStargatePackages(req.Content)
        .then((shouldRestart) => {
          if (shouldRestart) {
            dragonglass.popup.error({
              title: "Important Information",
              caption:
                "<p>There are new version(s) available for some of front-end functionality which you already used during this session. If you continue this session, you may " +
                "encounter unexpected issues. We recommend that you close your application, and then start it again, to allow the updated features to refresh your client.</p>",
            });
          }
        })
        .catch((e) => {
          debug.stargate.warning(
            "Stargate method invocation failed with message: " + e
          );
        });
    };

    n$.AsyncRequestHandlers.AppGatewayProtocolResponse = function (req) {
      debug.device.log("AppGatewayProtocolResponse request received", req);
      if (!dragonglass.external.stargate) {
        showStargateNoSupportMessage();
        return;
      }
      dragonglass.external.stargate.appGatewayProtocolResponse(
        req.Event,
        req.Data
      );
    };
  })();

  // Remnant of Major Tom interface to Transcendence
  if (window) {
    connectToApp({ appGatewaySendResponse: n$.Events.Protocol.raise });

    // Legacy-only access
    Object.defineProperty(window, "n$", {
      get: () => {
        console.warn("Accessing legacy-only n$ object.");
        console.trace();
        return n$;
      },
    });
    Object.defineProperty(window, "NaviPartner", {
      get: () => {
        console.warn("Accessing legacy-only NaviPartner object.");
        console.trace();
        return n$;
      },
    });
  }

  fulfill({
    invokeFrontEndAsync: n$._invokeFrontEndAsync,
    getNewButtonWorkflow: (button) =>
      new n$.Workflow.ActionHandler.Workflow(button),
    executeV1Workflow: (
      initialContext,
      actionInfo,
      workflow,
      parameters,
      content,
      parent,
      fulfill
    ) => {
      const workflowV1 = new n$.Workflow.Workflow(
        workflow,
        parameters,
        content,
        parent
      );
      if (actionInfo._nested) {
        actionInfo._nestedContext &&
          (workflowV1.context = actionInfo._nestedContext);
        workflowV1.outerPromiseCompletionCallback = fulfill;
        workflowV1.execute();
      } else {
        if (initialContext) workflowV1.context = initialContext;
        n$.Workflow.start(workflowV1, fulfill);
      }
    },
    actionActive: (active) => dragonglass.external.actionActive(active),
    noSupport: (method) =>
      typeof n$.Event.Method.noSupport[method] === "function" &&
      n$.Event.Method.noSupport[method](),
    abortAllWorkflows: () => n$.Workflow.abortAll(),
    Event: n$.Event,
  });
});
