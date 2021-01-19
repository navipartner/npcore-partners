controladdin "NPR Dragonglass"
{
    Scripts =
        'src/_ControlAddins/Dragonglass/Scripts/GetImageResource.js',
        'src/_ControlAddins/Dragonglass/Scripts/jquery-2.1.1.min.js',
        'src/_ControlAddins/Dragonglass/Scripts/jquery-ui.min.js',
        'src/_ControlAddins/Dragonglass/Scripts/datepicker.js',
        'src/_ControlAddins/Dragonglass/Scripts/datepicker.da.js',
        'src/_ControlAddins/Dragonglass/Scripts/datepicker.en.js',
        'src/_ControlAddins/Dragonglass/Scripts/datepicker.es.js',
        'src/_ControlAddins/Dragonglass/Scripts/datepicker.fr.js',
        'src/_ControlAddins/Dragonglass/Scripts/datepicker.nl.js',
        'src/_ControlAddins/Dragonglass/Scripts/bundle.6.1.2209.5.js',
        'src/_ControlAddins/Dragonglass/Scripts/moment.min.js',
        'src/_ControlAddins/Dragonglass/Scripts/no-ie.js',
        'src/_ControlAddins/Dragonglass/Scripts/NaviPartner.Transcendence.min.js';

    StyleSheets =
        'src/_ControlAddins/Dragonglass/Stylesheets/datepicker.css',
        'src/_ControlAddins/Dragonglass/Stylesheets/dragonglass.icons.min.css';

    Images =
        'src/_ControlAddins/Dragonglass/Scripts/bundle.6.1.2209.5.js.map',
        'src/_ControlAddins/Dragonglass/Images/npretaillogo_med.png',
        'src/_ControlAddins/Dragonglass/Images/dragonglass.woff',
        'src/_ControlAddins/Dragonglass/Images/spinner-100-R.png',
        'src/_ControlAddins/Dragonglass/Images/mobilepay_logo_inverted_small.png',
        'src/_ControlAddins/Dragonglass/Images/mobilepay_logo_small.png';

    RequestedHeight = 1;
    RequestedWidth = 1;
    HorizontalStretch = true;
    VerticalStretch = true;

    event OnFrameworkReady();
    event OnInvokeMethod(Method: Text; EventContent: JsonObject);
    event OnAction(Action: Text; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject);
    procedure InvokeFrontEndAsync(Request: JsonObject);
}
