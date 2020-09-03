controladdin "NPR Dragonglass"
{
    Scripts =
        'src/_Control Addins/Dragonglass/Scripts/jquery-2.1.1.min.js',
        'src/_Control Addins/Dragonglass/Scripts/jquery-ui.min.js',
        'src/_Control Addins/Dragonglass/Scripts/datepicker.js',
        'src/_Control Addins/Dragonglass/Scripts/datepicker.da.js',
        'src/_Control Addins/Dragonglass/Scripts/datepicker.en.js',
        'src/_Control Addins/Dragonglass/Scripts/datepicker.es.js',
        'src/_Control Addins/Dragonglass/Scripts/datepicker.fr.js',
        'src/_Control Addins/Dragonglass/Scripts/datepicker.nl.js',
        'src/_Control Addins/Dragonglass/Scripts/bundle.js',
        'src/_Control Addins/Dragonglass/Scripts/moment.min.js',
        'src/_Control Addins/Dragonglass/Scripts/no-ie.js',
        'src/_Control Addins/Dragonglass/Scripts/NaviPartner.Transcendence.min.js';

    StyleSheets =
        'src/_Control Addins/Dragonglass/Stylesheets/datepicker.css',
        'src/_Control Addins/Dragonglass/Stylesheets/dragonglass.icons.min.css';

    Images =
        'src/_Control Addins/Dragonglass/Images/npretaillogo_med.png',
        'src/_Control Addins/Dragonglass/Images/dragonglass.woff',
        'src/_Control Addins/Dragonglass/Images/spinner-100-R.png',
        'src/_Control Addins/Dragonglass/Images/mobilepay_logo_inverted_small.png',
        'src/_Control Addins/Dragonglass/Images/mobilepay_logo_small.png';

    RequestedHeight = 1;
    RequestedWidth = 1;
    HorizontalStretch = true;
    VerticalStretch = true;

    event OnFrameworkReady();
    event OnInvokeMethod(Method: Text; EventContent: JsonObject);
    event OnAction(Action: Text; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject);
    procedure InvokeFrontEndAsync(Request: JsonObject);
}