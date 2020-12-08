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

    procedure PrintViaEpsonWebService(PrinterName: Text; SlavePrinterName: Text; PrintBytes: Text; TargetEncoding: TextEncoding; CodePage: Integer)
    var
        WebPrintMgt: Codeunit "NPR RP Epson Web Print Mgt.";
    begin
        WebPrintMgt.CreatePrintJob(PrinterName, SlavePrinterName, PrintBytes, TargetEncoding, CodePage);
    end;

    procedure PrintViaGoogleCloud(PrinterID: Text; var Stream: DotNet NPRNetMemoryStream; ContentType: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer): Boolean
    var
        GoogleCloudPrintMgt: Codeunit "NPR GCP Mgt.";
    begin
        if ContentType = '' then
            exit(false);

        if Stream.Length < 1 then
            exit(false);

        exit(GoogleCloudPrintMgt.PrintFile(PrinterID, Stream, ContentType, GoogleCloudPrintMgt.GetCustomCJT(PrinterID, ObjectType, ObjectID), '', ''));
    end;

    procedure PrintViaEmail(PrinterName: Text; var Stream: DotNet NPRNetMemoryStream)
    var
        SmtpMail: Codeunit "SMTP Mail";
        InStream: InStream;
        Separators: List of [Text];
    begin
        if Stream.Length < 1 then
            exit;
        Separators.Add(';');
        Separators.Add(',');

        SmtpMail.CreateMessage('NaviPartner', 'noreply@navipartner.dk', PrinterName.Split(Separators), 'Document Print', '', false);
        SmtpMail.AddAttachmentStream(Stream, 'Document.pdf');
        SmtpMail.Send();
    end;

    procedure PrintViaPrintNodePdf(PrinterID: Text; var PdfStream: DotNet NPRNetMemoryStream; DocumentDescription: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
    var
        PrintNodeAPIMgt: Codeunit "NPR PrintNode API Mgt.";
        PrintNodeMgt: Codeunit "NPR PrintNode Mgt.";
    begin
        PrintNodeAPIMgt.SendPDFStream(PrinterID, PdfStream, DocumentDescription, '', PrintNodeMgt.GetPrinterOptions(PrinterID, ObjectType, ObjectID));
    end;

    procedure PrintViaPrintNodeRaw(PrinterID: Text; PrintBytes: Text; TargetEncoding: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
    var
        PrintNodeAPIMgt: Codeunit "NPR PrintNode API Mgt.";
        PrintNodeMgt: Codeunit "NPR PrintNode Mgt.";
    begin
        PrintNodeAPIMgt.SendRawText(PrinterID, PrintBytes, TargetEncoding, '', '', PrintNodeMgt.GetPrinterOptions(PrinterID, ObjectType, ObjectID));
    end;

    procedure PrintBytesHTTP(URL: Text; Endpoint: Text; PrintBytes: Text; TargetEncoding: TextEncoding; CodePage: Integer)
    var
        MobilePrintMgt: Codeunit "NPR Mobile Print Mgt.";
    begin
        MobilePrintMgt.PrintJobHTTP(URL, Endpoint, PrintBytes, TargetEncoding, CodePage);
    end;

    procedure PrintBytesBluetooth(DeviceName: Text; PrintBytes: Text; TargetEncoding: TextEncoding; CodePage: Integer)
    var
        MobilePrintMgt: Codeunit "NPR Mobile Print Mgt.";
    begin
        MobilePrintMgt.PrintJobBluetooth(DeviceName, PrintBytes, TargetEncoding, CodePage);
    end;
}
