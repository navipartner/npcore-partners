controladdin "NPR DragDrop"
{
    Scripts =
        'src\_ControlAddIns\DragDrop\Script\jquery-2.1.3.min.js',
        'src\_ControlAddIns\DragDrop\Script\jquery-ui.min.js',
        'src\_ControlAddIns\DragDrop\Script\Script.js';

    StyleSheets =
        'src\_ControlAddIns\DragDrop\Stylesheet\Styles.css';

    RequestedHeight = 250;
    RequestedWidth = 0;
    VerticalStretch = true;
    HorizontalStretch = true;

    event EndDataStream();
    event EndDataTransfer();
    event InitDataStream(FileName: Text; FileSize: Decimal);
    event InitDataTransfer();
    event WriteDataStream(Data: Text; Finalize: Boolean);
    event AddInReady();

    procedure SetCaption(Caption: Text; Value: Text);
    procedure DisplayData(Data: Text);
}
