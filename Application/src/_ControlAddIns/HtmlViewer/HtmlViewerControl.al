controladdin "NPR HtmlViewerControl"
{
    VerticalStretch = true;
    HorizontalStretch = true;

    StartupScript = 'src/_ControlAddIns/HtmlViewer/Scripts/HtmlViewerStartup.js';
    Scripts = 'src/_ControlAddIns/HtmlViewer/Scripts/HtmlViewer.js';
    procedure XSLT(xslt: text; xml: Text);
    event Ready();

}