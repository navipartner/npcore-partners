controladdin "NPR HtmlViewerControl"
{
    VerticalStretch = true;
    HorizontalStretch = true;

    StartupScript = 'src/_ControlAddins/HtmlViewer/Scripts/HtmlViewerStartup.js';
    Scripts = 'src/_ControlAddins/HtmlViewer/Scripts/HtmlViewer.js';
    procedure XSLT(xslt: text; xml: Text);
    event Ready();

}