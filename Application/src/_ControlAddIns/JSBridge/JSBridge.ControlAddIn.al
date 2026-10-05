controladdin "NPR JSBridge"
{
    Scripts =
        'src/_ControlAddIns/JSBridge/Script/Bridge.js',
        'src/_ControlAddIns/JSBridge/Script/jquery-2.0.3.min.js';

    StartupScript = 'src/_ControlAddIns/JSBridge/Script/Startup.js';

    StyleSheets =
        'src/_ControlAddIns/JSBridge/StyleSheet/JSBridge.css';

    event ControlAddInReady();
    event ActionCompleted(JsonText: Text);

    procedure CallNativeFunction(NativeFunction: Text);
    procedure InjectJavaScript(JavaScript: Text);
}
