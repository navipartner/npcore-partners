controladdin "NPR Transcendence"
{
    Scripts =
        'src/_ControlAddins/Transcendence/Scripts/jquery-2.1.1.min.js',
        'src/_ControlAddins/Transcendence/Scripts/jquery-ui.min.js',
        'src/_ControlAddins/Transcendence/Scripts/datepicker.js',
        'src/_ControlAddins/Transcendence/Scripts/datepicker.da.js',
        'src/_ControlAddins/Transcendence/Scripts/datepicker.en.js',
        'src/_ControlAddins/Transcendence/Scripts/datepicker.es.js',
        'src/_ControlAddins/Transcendence/Scripts/datepicker.fr.js',
        'src/_ControlAddins/Transcendence/Scripts/datepicker.nl.js',
        'src/_ControlAddins/Transcendence/Scripts/numeral.min.js',
        'src/_ControlAddins/Transcendence/Scripts/moment.min.js',
        'src/_ControlAddins/Transcendence/Scripts/no-ie.js',
        'src/_ControlAddins/Transcendence/Scripts/NaviPartner.min.js';

    StyleSheets =
        'src/_ControlAddins/Transcendence/Stylesheets/NaviPartner.Style.min.css',
        'src/_ControlAddins/Transcendence/Stylesheets/NaviPartner.UserGuide.Style.css',
        'src/_ControlAddins/Transcendence/Stylesheets/datepicker.css';

    Images =
        'src/_ControlAddins/Transcendence/Images/npretaillogo_med.png',
        'src/_ControlAddins/Transcendence/Images/icon-warn.png',
        'src/_ControlAddins/Transcendence/Images/icon-quest.png',
        'src/_ControlAddins/Transcendence/Images/icon-stop.png',
        'src/_ControlAddins/Transcendence/Images/icon-error.png',
        'src/_ControlAddins/Transcendence/Images/icon-info.png',
        'src/_ControlAddins/Transcendence/Images/lightbulb_on.png',
        'src/_ControlAddins/Transcendence/Images/lightbulb_off.png',
        'src/_ControlAddins/Transcendence/Images/search.png',
        'src/_ControlAddins/Transcendence/Images/gear.png';

    RequestedHeight = 1;
    RequestedWidth = 1;
    HorizontalStretch = true;
    VerticalStretch = true;

    event OnFrameworkReady();
    event OnInvokeMethod(Method: Text; EventContent: JsonObject);
    event OnAction(Action: Text; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject);
    procedure InvokeFrontEndAsync(Request: JsonObject);
}