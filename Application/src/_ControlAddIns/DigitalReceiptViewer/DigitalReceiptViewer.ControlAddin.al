controladdin "NPR DigitalReceiptViewer"
{
    Scripts = './src/_ControlAddIns/DigitalReceiptViewer/DigitalReceiptScripts.js';
    StyleSheets = './src/_ControlAddIns/DigitalReceiptViewer/Stylesheet.css';

    HorizontalStretch = true;
    HorizontalShrink = true;
    MinimumWidth = 250;
    RequestedHeight = 1700;

    procedure SetContent(PDFLine: Text)
}