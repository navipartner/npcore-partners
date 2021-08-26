controladdin "NPR Dragonglass"
{
    Scripts =
        'src/_ControlAddins/Dragonglass/Scripts/GetImageResource.js',
        'src/_ControlAddins/Dragonglass/Scripts/appInsights.min.js',
        'src/_ControlAddins/Dragonglass/Scripts/jquery-2.1.1.min.js',
        'src/_ControlAddins/Dragonglass/Scripts/jquery-ui.min.js',
        'src/_ControlAddins/Dragonglass/Scripts/datepicker.js',
        'src/_ControlAddins/Dragonglass/Scripts/datepicker.da.js',
        'src/_ControlAddins/Dragonglass/Scripts/datepicker.en.js',
        'src/_ControlAddins/Dragonglass/Scripts/datepicker.es.js',
        'src/_ControlAddins/Dragonglass/Scripts/datepicker.fr.js',
        'src/_ControlAddins/Dragonglass/Scripts/datepicker.nl.js',
        'src/_ControlAddins/Dragonglass/Scripts/bundle.js',
        'src/_ControlAddins/Dragonglass/Scripts/moment.min.js',
        'src/_ControlAddins/Dragonglass/Scripts/no-ie.js';

    StyleSheets =
        // Font Awesome (icons)
        'src/_ControlAddins/Dragonglass/Fonts/fontawesome/css/all.min.css',

        // Font Raleway (NP website font, for mobile UI)
        'https://fonts.googleapis.com/css2?family=Raleway:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap',

        'src/_ControlAddins/Dragonglass/Stylesheets/datepicker.css',
        'src/_ControlAddins/Dragonglass/Stylesheets/themeDefault.css',
        'src/_ControlAddins/Dragonglass/Stylesheets/bundle.css';

    Images =
        // Font Awesome
        'src/_ControlAddins/Dragonglass/Fonts/fontawesome/webfonts/fa-brands-400.woff2',
        'src/_ControlAddins/Dragonglass/Fonts/fontawesome/webfonts/fa-duotone-900.woff2',
        'src/_ControlAddins/Dragonglass/Fonts/fontawesome/webfonts/fa-light-300.woff2',
        'src/_ControlAddins/Dragonglass/Fonts/fontawesome/webfonts/fa-regular-400.woff2',
        'src/_ControlAddins/Dragonglass/Fonts/fontawesome/webfonts/fa-solid-900.woff2',
        'src/_ControlAddins/Dragonglass/Fonts/fontawesome/webfonts/fa-thin-100.woff2',

        // Bundle - exclude from production builds
        'src/_ControlAddins/Dragonglass/Scripts/bundle.js.map',

        // Images
        'src/_ControlAddins/Dragonglass/Images/npretaillogo_med.png',
        'src/_ControlAddins/Dragonglass/Images/npretaillogo_med_inverted.png',
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
