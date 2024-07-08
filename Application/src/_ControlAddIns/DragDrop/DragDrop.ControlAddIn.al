controladdin "NPR DragDrop"
{
    Scripts =
        'src/_ControlAddIns/DragDrop/Script/jquery-2.1.3.min.js',
        'src/_ControlAddIns/DragDrop/Script/jquery-ui.min.js',
        'src/_ControlAddIns/DragDrop/Script/Script.js';

    StyleSheets =
        'src/_ControlAddIns/DragDrop/Stylesheet/Styles.css';

    RequestedHeight = 250;
    RequestedWidth = 0;
    VerticalStretch = true;
    HorizontalStretch = true;

    /// This event is called when the add-in is done streaming data to the NST.
    event EndDataStream();
    /// This event is called when the transfer of all pictures is done.
    event EndDataTransfer();
    /// This event is called when a new picture stream is starting.
    event InitDataStream(FileName: Text; FileSize: Decimal);
    /// This event is called when it initiates a transfer of pictures.
    event InitDataTransfer();
    /// This event is called with the (parts of) data of the picture.
    /// It will be called continously until the entire picture is streamed to the NST.
    event WriteDataStream(Data: Text; Finalize: Boolean);
    /// This event is called when the add-in is loaded in the client.
    event AddInReady();

    procedure SetCaption(Caption: Text; Value: Text);
    procedure DisplayData(Data: Text);
}
