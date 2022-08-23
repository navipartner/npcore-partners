controladdin "NPR Image Viewer"
{
    Scripts = 'src/_ControlAddIns/ImageViewer/script.js';
    StyleSheets = 'src/_ControlAddIns/ImageViewer/style.css';

    RequestedHeight = 250;
    RequestedWidth = 0;
    VerticalStretch = true;
    HorizontalStretch = true;

    event ControlAddInReady();

    procedure SetSource(Source: Text);
    procedure HideImage();
}