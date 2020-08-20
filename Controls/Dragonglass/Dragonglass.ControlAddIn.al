controladdin Dragonglass
{
    Scripts =
        'Controls/Dragonglass/Scripts/jquery-2.1.1.min.js',
        'Controls/Dragonglass/Scripts/jquery-ui.min.js',
        'Controls/Dragonglass/Scripts/datepicker.js',
        'Controls/Dragonglass/Scripts/datepicker.da.js',
        'Controls/Dragonglass/Scripts/datepicker.en.js',
        'Controls/Dragonglass/Scripts/datepicker.es.js',
        'Controls/Dragonglass/Scripts/datepicker.fr.js',
        'Controls/Dragonglass/Scripts/datepicker.nl.js',
        'Controls/Dragonglass/Scripts/bundle.js',
        'Controls/Dragonglass/Scripts/moment.min.js',
        'Controls/Dragonglass/Scripts/no-ie.js',
        'Controls/Dragonglass/Scripts/NaviPartner.Transcendence.min.js';

    StyleSheets =
        'Controls/Dragonglass/Stylesheets/datepicker.css',
        'Controls/Dragonglass/Stylesheets/dragonglass.icons.min.css';

    Images =
        'Controls/Dragonglass/Images/npretaillogo_med.png',
        'Controls/Dragonglass/Images/dragonglass.woff',
        'Controls/Dragonglass/Images/spinner-100-R.png',
        'Controls/Dragonglass/Images/mobilepay_logo_inverted_small.png',
        'Controls/Dragonglass/Images/mobilepay_logo_small.png';

    RequestedHeight = 1;
    RequestedWidth = 1;
    HorizontalStretch = true;
    VerticalStretch = true;

    event OnFrameworkReady();
    event OnInvokeMethod(Method: Text; EventContent: JsonObject);
    event OnAction(Action: Text; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject);
    procedure InvokeFrontEndAsync(Request: JsonObject);
}