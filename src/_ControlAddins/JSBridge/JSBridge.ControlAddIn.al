controladdin "NPR JSBridge"
{
    Scripts =
        'src/_ControlAddins/JSBridge/Script/Bridge.js',
        'src/_ControlAddins/JSBridge/Script/jquery-2.0.3.min.js';

    StartupScript = 'src/_ControlAddins/JSBridge/Script/Startup.js';

    StyleSheets =
        'src/_ControlAddins/JSBridge/StyleSheet/JSBridge.css';

    event ControlAddInReady();
    event ActionCompleted(JsonText: Text);

    procedure CallNativeFunction(NativeFunction: Text);
    procedure InjectJavaScript(JavaScript: Text);
}
