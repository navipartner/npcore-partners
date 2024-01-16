
function SetContent(PDFLink) {
    var iframe = window.frameElement;

    iframe.parentElement.style.display = 'flex';
    iframe.parentElement.style.flexDirection = 'column';
    iframe.parentElement.style.flexGrow = '1';

    iframe.style.flexGrow = '1';
    iframe.style.flexShrink = '1';
    iframe.style.flexBasis = 'auto';
    iframe.style.paddingBottom = '42px';

    var digitalReceiptViewerControlAddin = document.getElementById('controlAddIn');
    digitalReceiptViewerControlAddin.innerHTML = '<iframe src="' + PDFLink + '" frameborder="0" height="100%" width="100%"></iframe>';
}