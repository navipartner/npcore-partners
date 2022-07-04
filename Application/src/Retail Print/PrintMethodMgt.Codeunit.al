codeunit 6014582 "NPR Print Method Mgt."
{
    Access = Internal;

    procedure PrintBytesLocal(PrinterName: Text; PrintJobBase64: Text)
    var
        HardwareConnectorMgt: Codeunit "NPR Hardware Connector Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        HWCPOSRequest: Codeunit "NPR Front-End: HWC";
        Request: JsonObject;
    begin
        if not GuiAllowed then
            exit;

        if POSSession.IsInitialized() then begin
            //print to hardware connector via POS page
            Request.Add('PrinterName', PrinterName);
            Request.Add('PrintJob', PrintJobBase64);

            HWCPOSRequest.SetHandler('RawPrint');
            HWCPOSRequest.SetRequest(Request);
            POSSession.GetFrontEnd(POSFrontEnd, true);
            POSFrontEnd.InvokeFrontEndMethod(HWCPOSRequest);
        end else begin
            //print to hardware connector via modal page
            HardwareConnectorMgt.SendRawPrintRequest(PrinterName, PrintJobBase64);
        end;

    end;

    procedure PrintFileLocal(PrinterName: Text; var Stream: InStream; FileExtension: Text)
    var
        HardwareConnectorMgt: Codeunit "NPR Hardware Connector Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        HWCPOSRequest: Codeunit "NPR Front-End: HWC";
        Request: JsonObject;
        Base64Convert: Codeunit "Base64 Convert";
        AzureKeyVault: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        if not GuiAllowed then
            exit;
        if StrLen(FileExtension) = 0 then
            exit;
        if Stream.EOS() then
            exit;

        if POSSession.IsInitialized() then begin
            //print to hardware connector via POS page
            Request.Add('PrinterName', PrinterName);
            Request.Add('FileData', Base64Convert.ToBase64(Stream));
            Request.Add('FileExtension', FileExtension);

            if UpperCase(FileExtension) = 'PDF' then begin
                Request.Add('PrintMethod', 'Spire');
                Request.Add('ExternalLibLicenseKey', AzureKeyVault.GetAzureKeyVaultSecret('SpirePDFDotNetCoreLicenseKey'))
            end else begin
                Request.Add('PrintMethod', 'OSFileHandler');
            end;

            HWCPOSRequest.SetHandler('FilePrint');
            HWCPOSRequest.SetRequest(Request);
            POSSession.GetFrontEnd(POSFrontEnd, true);
            POSFrontend.InvokeFrontEndMethod(HWCPOSRequest);
        end else begin
            //print to hardware connector via modal page
            HardwareConnectorMgt.SendFilePrintRequest(PrinterName, Stream, FileExtension);
        end;
    end;

    procedure PrintViaEmail(PrinterName: Text; var Stream: InStream)
    var
        Separators: List of [Text];
        TempEmailItem: Record "Email Item" temporary;
        TempErrorMessage: Record "Error Message" temporary;
        EmailSenderHandler: Codeunit "NPR Email Sending Handler";
    begin
        if Stream.EOS then
            exit;
        Separators.Add(';');
        Separators.Add(',');

        EmailSenderHandler.CreateEmailItem(TempEmailItem, 'NaviPartner', 'eprint@navipartner.dk', PrinterName.Split(Separators), 'Document Print', 'Document Print Body', false);
        EmailSenderHandler.AddAttachmentFromStream(TempEmailItem, Stream, 'Document.pdf');
        EmailSenderHandler.Send(TempEmailItem, TempErrorMessage);
        if not TempErrorMessage.IsEmpty() then
            TempErrorMessage.ShowErrors();
    end;

    procedure PrintViaPrintNodePdf(PrinterID: Text; var PdfStream: InStream; DocumentDescription: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
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

    procedure PrintViaPrintNodeRaw(PrinterID: Text; PrintJobBase64: Text; ObjectType: Option "Report","Codeunit"; ObjectID: Integer)
    var
        PrintNodeAPIMgt: Codeunit "NPR PrintNode API Mgt.";
        PrintNodeMgt: Codeunit "NPR PrintNode Mgt.";
    begin
        PrintNodeAPIMgt.SendRawText(PrinterID, PrintJobBase64, '', '', PrintNodeMgt.GetPrinterOptions(PrinterID, ObjectType, ObjectID));
    end;

    procedure PrintBytesHTTP(URL: Text; Endpoint: Text; PrintJobBase64: Text)
    var
        MobilePrintMgt: Codeunit "NPR Mobile Print Mgt.";
    begin
        MobilePrintMgt.PrintJobHTTP(URL, Endpoint, PrintJobBase64);
    end;

    procedure PrintBytesBluetooth(DeviceName: Text; PrintJobBase64: Text)
    var
        MobilePrintMgt: Codeunit "NPR Mobile Print Mgt.";
    begin
        MobilePrintMgt.PrintJobBluetooth(DeviceName, PrintJobBase64);
    end;

    procedure PrintFileMPOS(IP: Text; FileBase64: Text)
    var
        MobilePrintMgt: Codeunit "NPR Mobile Print Mgt.";
    begin
        MobilePrintMgt.PrintJobFile(IP, FileBase64);
    end;
}
