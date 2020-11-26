codeunit 6014582 "NPR Print Method Mgt."
{

    procedure PrintBytesLocal(PrinterName: Text; PrintBytes: Text; TargetEncoding: Text)
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSProxyRawPrint: Codeunit "NPR POS Proxy: Raw Print";
        POSSession: Codeunit "NPR POS Session";
        HardwareConnectorMgt: Codeunit "NPR Hardware Connector Mgt.";
    begin
        case CurrentClientType of
            CLIENTTYPE::Windows:
                PrintBytesViaClientAddin(PrinterName, PrintBytes, TargetEncoding);
            CLIENTTYPE::Web,
          CLIENTTYPE::Tablet,
          CLIENTTYPE::Phone:
                if (POSSession.IsActiveSession(POSFrontEnd)) then
                    POSProxyRawPrint.Print(POSFrontEnd, PrinterName, TargetEncoding, PrintBytes, false)
                else
                    HardwareConnectorMgt.SendRawPrintRequest(PrinterName, PrintBytes, TargetEncoding);
        end;
    end;

    procedure PrintFileLocal(PrinterName: Text; var Stream: DotNet NPRNetMemoryStream; FileExtension: Text)
    var
        // TODO: CTRLUPGRADE - references a possibly obsolete object
        //FilePrintProxyProtocol: Codeunit "File Print Proxy Protocol";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSProxyFilePrint: Codeunit "NPR POS Proxy: File Print";
        POSSession: Codeunit "NPR POS Session";
    begin
        if Stream.Length < 1 then
            exit;

        if StrLen(FileExtension) = 0 then
            exit;

        case CurrentClientType of
            CLIENTTYPE::Windows:
                PrintFileViaClientDotNet(PrinterName, false, Stream, FileExtension);
            CLIENTTYPE::Web,
          CLIENTTYPE::Tablet,
          CLIENTTYPE::Phone:
                if (POSSession.IsActiveSession(POSFrontEnd)) then
                    POSProxyFilePrint.Print(POSFrontEnd, PrinterName, Stream, FileExtension, false, false)
                else
                    // TODO: CTRLUPGRADE - invokes old obsolete Proxy Manager Stargate v1 protocol
                    ERROR('CTRLUPGRADE');
        /*
        FilePrintProxyProtocol.PrintJob(PrinterName, Stream, FileExtension, false);
        */
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

    procedure PrintBytesViaClientAddin(PrinterName: Text; PrintBytes: Text; TargetEncoding: Text)
    var
        [RunOnClient]
        StringBufferDotNet: DotNet NPRNetStringBuffer;
    begin
        StringBufferDotNet := StringBufferDotNet.StringBuffer();
        StringBufferDotNet.ClearBuffer;
        StringBufferDotNet.Append(PrintBytes);
        if TargetEncoding = '' then
            StringBufferDotNet.PrintBuffer(PrinterName)
        else
            StringBufferDotNet.PrintBufferWithEncoding(PrinterName, TargetEncoding);

        Clear(StringBufferDotNet);
    end;

    procedure PrintFileViaClientDotNet(PrinterName: Text; PrinterDialog: Boolean; var Stream: DotNet NPRNetMemoryStream; FileExtension: Text)
    var
        [RunOnClient]
        Process: DotNet NPRNetProcess;
        [RunOnClient]
        ProcessStartInfo: DotNet NPRNetProcessStartInfo;
        [RunOnClient]
        ProcessWindowStyle: DotNet NPRNetProcessWindowStyle;
        [RunOnClient]
        PrintDialog: DotNet NPRNetPrintDialog;
        [RunOnClient]
        DialogResult: DotNet NPRNetDialogResult;
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        Filename: Text;
    begin
        // Note: This function will use whatever software is set as default handler for the file extension type on the local machine.
        // ie. if Adobe Reader is set as default PDF client, it will be Adobe Reader handling the print.
        // This means the print can be sub-optimal or in some cases not even possible.

        if PrinterDialog then begin
            PrintDialog := PrintDialog.PrintDialog();
            PrintDialog.AllowPrintToFile := false;
            PrintDialog.AllowCurrentPage := false;
            PrintDialog.AllowSelection := false;
            PrintDialog.AllowSomePages := false;
            PrintDialog.PrinterSettings.Copies := 1;
            if not PrintDialog.ShowDialog().Equals(DialogResult.OK) then
                exit;

            PrinterName := PrintDialog.PrinterSettings.PrinterName;
        end;

        TempBlob.CreateOutStream(OutStream);
        CopyStream(OutStream, Stream);
        if not TempBlob.HasValue then
            exit;

        Filename := FileMgt.BLOBExport(TempBlob, FileExtension, false);
        if StrLen(Filename) = 0 then
            exit;

        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(Filename);
        ProcessStartInfo.CreateNoWindow := true;
        ProcessStartInfo.WindowStyle := ProcessWindowStyle.Hidden;

        if StrLen(PrinterName) = 0 then //Use default printer in windows.
            ProcessStartInfo.Verb := 'Print'
        else begin
            ProcessStartInfo.UseShellExecute := true;
            ProcessStartInfo.Arguments := '"' + PrinterName + '"';
            ProcessStartInfo.Verb := 'PrintTo';
        end;

        Process := Process.Start(ProcessStartInfo);
        Process.WaitForExit(5 * 1000); //Timeout after 5 seconds.

        FileMgt.DeleteClientFile(Filename);
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

