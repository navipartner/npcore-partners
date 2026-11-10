(function () {
    "use strict";
    var host = document.getElementById('controlAddIn');
    host.innerHTML = '<div id="npr-admission-calendar"></div>';
    window.NPRAdmissionCalendar.mount('#npr-admission-calendar');
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnControlReady', []);
})();
