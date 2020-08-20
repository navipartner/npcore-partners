controladdin Transcendence
{
    Scripts =
        'Controls/Transcendence/Scripts/jquery-2.1.1.min.js',
        'Controls/Transcendence/Scripts/jquery-ui.min.js',
        'Controls/Transcendence/Scripts/datepicker.js',
        'Controls/Transcendence/Scripts/datepicker.da.js',
        'Controls/Transcendence/Scripts/datepicker.en.js',
        'Controls/Transcendence/Scripts/datepicker.es.js',
        'Controls/Transcendence/Scripts/datepicker.fr.js',
        'Controls/Transcendence/Scripts/datepicker.nl.js',
        'Controls/Transcendence/Scripts/numeral.min.js',
        'Controls/Transcendence/Scripts/moment.min.js',
        'Controls/Transcendence/Scripts/no-ie.js',
        'Controls/Transcendence/Scripts/NaviPartner.min.js';

    StyleSheets =
        'Controls/Transcendence/Stylesheets/NaviPartner.Style.min.css',
        'Controls/Transcendence/Stylesheets/NaviPartner.UserGuide.Style.css',
        'Controls/Transcendence/Stylesheets/datepicker.css';

    Images =
        'Controls/Transcendence/Images/npretaillogo_med.png',
        'Controls/Transcendence/Images/icon-warn.png',
        'Controls/Transcendence/Images/icon-quest.png',
        'Controls/Transcendence/Images/icon-stop.png',
        'Controls/Transcendence/Images/icon-error.png',
        'Controls/Transcendence/Images/icon-info.png',
        'Controls/Transcendence/Images/lightbulb_on.png',
        'Controls/Transcendence/Images/lightbulb_off.png',
        'Controls/Transcendence/Images/search.png',
        'Controls/Transcendence/Images/gear.png';

    RequestedHeight = 1;
    RequestedWidth = 1;
    HorizontalStretch = true;
    VerticalStretch = true;

    event OnFrameworkReady();
    event OnInvokeMethod(Method: Text; EventContent: JsonObject);
    event OnAction(Action: Text; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject);
    procedure InvokeFrontEndAsync(Request: JsonObject);
}