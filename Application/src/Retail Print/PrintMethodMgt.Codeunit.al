codeunit 6014582 "NPR Print Method Mgt."
{

    procedure PrintBytesLocal(PrinterName: Text; PrintBytes: Text; TargetEncoding: Text)
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSProxyRawPrint: Codeunit "NPR POS Proxy: Raw Print";
        POSSession: Codeunit "NPR POS Session";
        HardwareConnectorMgt: Codeunit "NPR Hardware Connector Mgt.";
        Encoding: Codeunit "NPR Text Encoding Mapper";
    begin
        case CurrentClientType of
            CLIENTTYPE::Web,
          CLIENTTYPE::Tablet,
          CLIENTTYPE::Phone:
                if (POSSession.IsActiveSession(POSFrontEnd)) then
                    POSProxyRawPrint.Print(POSFrontEnd, PrinterName, TargetEncoding, PrintBytes, false)
                else
                    HardwareConnectorMgt.SendRawPrintRequest(PrinterName, PrintBytes, Encoding.EncodingNameToCodePageNumber(TargetEncoding));
        end;
    end;

    procedure PrintFileLocal(PrinterName: Text; var Stream: DotNet NPRNetMemoryStream; FileExtension: Text)
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSProxyFilePrint: Codeunit "NPR POS Proxy: File Print";
        POSSession: Codeunit "NPR POS Session";
        HardwareConnectorMgt: Codeunit "NPR Hardware Connector Mgt.";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        if Stream.Length < 1 then
            exit;

        if StrLen(FileExtension) = 0 then
            exit;

        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, Stream);

        case CurrentClientType of
            CLIENTTYPE::Web,
          CLIENTTYPE::Tablet,
          CLIENTTYPE::Phone:
                if (POSSession.IsActiveSession(POSFrontEnd)) then
                    POSProxyFilePrint.Print(POSFrontEnd, PrinterName, Stream, FileExtension, false, false)
                else
                    HardwareConnectorMgt.SendRawBytesPrintRequest(PrinterName, TempBlob);
        end;
    end;

    [Obsolete('Use the overload without DotNet. This method can be deleted when there are 0 references left')]
    procedure PrintViaEmail(PrinterName: Text; var Stream: DotNet NPRNetMemoryStream)
    var
        InStream: InStream;
        Separators: List of [Text];
        TempEmailItem: Record "Email Item" temporary;
        EmailSenderHandler: Codeunit "NPR Email Sending Handler";
    begin
        if Stream.Length < 1 then
            exit;
        Separators.Add(';');
        Separators.Add(',');

        EmailSenderHandler.CreateEmailItem(TempEmailItem, 'NaviPartner', 'eprint@navipartner.dk', PrinterName.Split(Separators), 'Document Print', 'Document Print Body', false);
        EmailSenderHandler.AddAttachmentFromStream(TempEmailItem, Stream, 'Document.pdf');
        EmailSenderHandler.Send(TempEmailItem);
    end;

    procedure PrintViaEmail(PrinterName: Text; var Stream: InStream)
    var
        Separators: List of [Text];
        TempEmailItem: Record "Email Item" temporary;
        EmailSenderHandler: Codeunit "NPR Email Sending Handler";
    begin
        if Stream.EOS then
            exit;
        Separators.Add(';');
        Separators.Add(',');

        EmailSenderHandler.CreateEmailItem(TempEmailItem, 'NaviPartner', 'eprint@navipartner.dk', PrinterName.Split(Separators), 'Document Print', 'Document Print Body', false);
        EmailSenderHandler.AddAttachmentFromStream(TempEmailItem, Stream, 'Document.pdf');
        EmailSenderHandler.Send(TempEmailItem);
    end;

    procedure PrintViaPrintNodePdf(PrinterID: Text; var PdfStream: DotNet NPRNetMemoryStream; DocumentDescription: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
    var
        PrintNodeAPIMgt: Codeunit "NPR PrintNode API Mgt.";
        PrintNodeMgt: Codeunit "NPR PrintNode Mgt.";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, PdfStream);

        PrintNodeAPIMgt.SendPDFStream(PrinterID, TempBlob, DocumentDescription, '', PrintNodeMgt.GetPrinterOptions(PrinterID, ObjectType, ObjectID));
    end;

    procedure PrintViaPrintNodeRaw(PrinterID: Text; PrintBytes: Text; TargetEncoding: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
    var
        PrintNodeAPIMgt: Codeunit "NPR PrintNode API Mgt.";
        PrintNodeMgt: Codeunit "NPR PrintNode Mgt.";
        TextEncodingMapper: Codeunit "NPR Text Encoding Mapper";
    begin
        PrintNodeAPIMgt.SendRawText(PrinterID, PrintBytes, TextEncodingMapper.EncodingNameToCodePageNumber(TargetEncoding), '', '', PrintNodeMgt.GetPrinterOptions(PrinterID, ObjectType, ObjectID));
    end;

    procedure PrintBytesHTTP(URL: Text; Endpoint: Text; PrintBytes: Text; TargetEncoding: Text)
    var
        MobilePrintMgt: Codeunit "NPR Mobile Print Mgt.";
    begin
        MobilePrintMgt.PrintJobHTTP(URL, Endpoint, PrintBytes, TargetEncoding);
    end;

    procedure PrintBytesBluetooth(DeviceName: Text; PrintBytes: Text; TargetEncoding: Text)
    var
        MobilePrintMgt: Codeunit "NPR Mobile Print Mgt.";
    begin
        MobilePrintMgt.PrintJobBluetooth(DeviceName, PrintBytes, TargetEncoding);
    end;
}
