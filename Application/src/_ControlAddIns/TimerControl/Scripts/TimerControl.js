
var timerObject;

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddInReady');

function StartTimer(milliSeconds) {
    timerObject = window.setInterval(TimerAction, milliSeconds);
}

function stopTimer() {
    clearInterval(timerObject);
}

function TimerAction() {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('RefreshPage');
}