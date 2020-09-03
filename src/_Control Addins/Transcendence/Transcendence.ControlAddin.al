controladdin "NPR Transcendence"
{
    Scripts =
        'src/_Control Addins/Transcendence/Scripts/jquery-2.1.1.min.js',
        'src/_Control Addins/Transcendence/Scripts/jquery-ui.min.js',
        'src/_Control Addins/Transcendence/Scripts/datepicker.js',
        'src/_Control Addins/Transcendence/Scripts/datepicker.da.js',
        'src/_Control Addins/Transcendence/Scripts/datepicker.en.js',
        'src/_Control Addins/Transcendence/Scripts/datepicker.es.js',
        'src/_Control Addins/Transcendence/Scripts/datepicker.fr.js',
        'src/_Control Addins/Transcendence/Scripts/datepicker.nl.js',
        'src/_Control Addins/Transcendence/Scripts/numeral.min.js',
        'src/_Control Addins/Transcendence/Scripts/moment.min.js',
        'src/_Control Addins/Transcendence/Scripts/no-ie.js',
        'src/_Control Addins/Transcendence/Scripts/NaviPartner.min.js';

    StyleSheets =
        'src/_Control Addins/Transcendence/Stylesheets/NaviPartner.Style.min.css',
        'src/_Control Addins/Transcendence/Stylesheets/NaviPartner.UserGuide.Style.css',
        'src/_Control Addins/Transcendence/Stylesheets/datepicker.css';

    Images =
        'src/_Control Addins/Transcendence/Images/npretaillogo_med.png',
        'src/_Control Addins/Transcendence/Images/icon-warn.png',
        'src/_Control Addins/Transcendence/Images/icon-quest.png',
        'src/_Control Addins/Transcendence/Images/icon-stop.png',
        'src/_Control Addins/Transcendence/Images/icon-error.png',
        'src/_Control Addins/Transcendence/Images/icon-info.png',
        'src/_Control Addins/Transcendence/Images/lightbulb_on.png',
        'src/_Control Addins/Transcendence/Images/lightbulb_off.png',
        'src/_Control Addins/Transcendence/Images/search.png',
        'src/_Control Addins/Transcendence/Images/gear.png';

    RequestedHeight = 1;
    RequestedWidth = 1;
    HorizontalStretch = true;
    VerticalStretch = true;

    event OnFrameworkReady();
    event OnInvokeMethod(Method: Text; EventContent: JsonObject);
    event OnAction(Action: Text; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject);
    procedure InvokeFrontEndAsync(Request: JsonObject);
}