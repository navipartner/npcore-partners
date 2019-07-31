controladdin Transcendence
{
    Scripts =
        'Controls/Framework/Scripts/jquery-2.1.1.min.js',
        'Controls/Framework/Scripts/jquery-ui.min.js',
        'Controls/Framework/Scripts/datepicker.js',
        'Controls/Framework/Scripts/datepicker.da.js',
        'Controls/Framework/Scripts/datepicker.en.js',
        'Controls/Framework/Scripts/datepicker.es.js',
        'Controls/Framework/Scripts/datepicker.fr.js',
        'Controls/Framework/Scripts/datepicker.nl.js',
        'Controls/Framework/Scripts/numeral.min.js',
        'Controls/Framework/Scripts/moment.min.js',
        'Controls/Framework/Scripts/no-ie.js',
        'Controls/Framework/Scripts/NaviPartner.min.js';

    StyleSheets =
        'Controls/Framework/Stylesheets/NaviPartner.Style.min.css',
        'Controls/Framework/Stylesheets/NaviPartner.UserGuide.Style.css',
        'Controls/Framework/Stylesheets/datepicker.css';

    Images =
        'Controls/Framework/Images/npretaillogo_med.png',
        'Controls/Framework/Images/icon-warn.png',
        'Controls/Framework/Images/icon-quest.png',
        'Controls/Framework/Images/icon-stop.png',
        'Controls/Framework/Images/icon-error.png',
        'Controls/Framework/Images/icon-info.png',
        'Controls/Framework/Images/lightbulb_on.png',
        'Controls/Framework/Images/lightbulb_off.png',
        'Controls/Framework/Images/search.png',
        'Controls/Framework/Images/gear.png';

    RequestedHeight = 1;
    RequestedWidth = 1;
    HorizontalStretch = true;
    VerticalStretch = true;

    event OnFrameworkReady();
    event OnInvokeMethod(Method: Text; EventContent: JsonObject);
    event OnAction(Action: Text; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject);
    procedure InvokeFrontEndAsync(Request: JsonObject);
}