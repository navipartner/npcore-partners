
function PollBackgroundTaskCompletion() {
    setTimeout(() => {Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("BackgroundTaskCompletionCallBack")}, 1000)
}

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlAddInReady");
