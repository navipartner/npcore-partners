codeunit 6014582 "Print Method Mgt."
{
    // NPR5.20/MMV/20160224 CASE 233229 Created CU to unify all print methods in one place independent of each device CU.
    // 
    // Called from each printer interface codeunit:
    //   Line Printer Interface   (Receipt/display printers)
    //   Matrix Printer Interface (Label printers)
    //   Report Printer Interface (Everything else, ie. A4 printers)
    // 
    // NPR5.22/MMV/20160315 CASE 228382 Added handling of e-mail print, Google Cloud Print & small cleanup.
    // NPR5.23/MMV /20160609 CASE 240856 Return any Google Cloud Print error instead of showing in message straight away.
    // NPR5.26/MMV /20160824 CASE 246209 Use streams instead of temp files for report printing.
    //                                   Use CLIENTTYPE instead of user setup to determine print route.
    //                                   Removed old comments.
    // NPR5.29/MMV /20161110 CASE 256521 Added support for file printing via stargate and client-side .NET
    //                                   refactored.
    // NPR5.29/MMV /20161220 CASE 253590 Added function PrintBytesHTTP
    // NPR5.30/MMV /20170209 CASE 261964 Updated google print function.
    // NPR5.30/MMV /20170209 CASE 261964 Updated google print function.
    // NPR5.32/MMV /20170313 CASE 253590 Added support for bluetooth print.


    trigger OnRun()
    begin
    end;

    var
        Error_GooglePrint: Label 'Invalid Content Type and/or File Path';

    local procedure "// Print via local machine:"()
    begin
    end;

    procedure PrintBytesLocal(PrinterName: Text;PrintBytes: Text;TargetEncoding: Text)
    var
        RawPrintProxyProtocol: Codeunit "Raw Print Proxy Protocol";
        POSFrontEnd: Codeunit "POS Front End Management";
        POSProxyRawPrint: Codeunit "POS Proxy - Raw Print";
        POSSession: Codeunit "POS Session";
    begin
        case CurrentClientType of
          CLIENTTYPE::Windows : PrintBytesViaClientAddin(PrinterName, PrintBytes, TargetEncoding);
          CLIENTTYPE::Web,
          CLIENTTYPE::Tablet,
          CLIENTTYPE::Phone :
            //IF POSFrontEnd.IsActiveSession() THEN
            if (POSSession.IsActiveSession (POSFrontEnd)) then
              POSProxyRawPrint.Print(POSFrontEnd, PrinterName, TargetEncoding, PrintBytes, false)
            else
              RawPrintProxyProtocol.PrintJob(PrinterName, TargetEncoding, PrintBytes);
        end;
    end;

    procedure PrintFileLocal(PrinterName: Text;var Stream: DotNet MemoryStream;FileExtension: Text)
    var
        FilePrintProxyProtocol: Codeunit "File Print Proxy Protocol";
        POSFrontEnd: Codeunit "POS Front End Management";
        POSProxyFilePrint: Codeunit "POS Proxy - File Print";
        POSSession: Codeunit "POS Session";
    begin
        if Stream.Length < 1 then
          exit;

        if StrLen(FileExtension) = 0 then
          exit;

        case CurrentClientType of
          CLIENTTYPE::Windows : PrintFileViaClientDotNet(PrinterName, false, Stream, FileExtension);
          CLIENTTYPE::Web,
          CLIENTTYPE::Tablet,
          CLIENTTYPE::Phone   :
            //IF POSFrontEnd.IsActiveSession() THEN
            if (POSSession.IsActiveSession (POSFrontEnd)) then
              POSProxyFilePrint.Print(POSFrontEnd, PrinterName, Stream, FileExtension, false, false)
            else
              FilePrintProxyProtocol.PrintJob(PrinterName, Stream, FileExtension, false);
        end;
    end;

    local procedure "// Print via external services:"()
    begin
    end;

    procedure PrintViaEpsonWebService(PrinterName: Text;SlavePrinterName: Text;PrintBytes: Text;TargetEncoding: Text)
    var
        WebPrintMgt: Codeunit "RP Epson Web Print Mgt.";
    begin
        WebPrintMgt.CreatePrintJob(PrinterName, SlavePrinterName, PrintBytes, TargetEncoding);
    end;

    procedure PrintViaGoogleCloud(PrinterID: Text;var Stream: DotNet MemoryStream;ContentType: Text;ObjectType: Option "Report","Codeunit";ObjectID: Integer): Boolean
    var
        GoogleCloudPrintMgt: Codeunit "GCP Mgt.";
    begin
        if ContentType = '' then
          exit(false);

        if Stream.Length < 1 then
          exit(false);

        exit(GoogleCloudPrintMgt.PrintFile(PrinterID, Stream, ContentType, GoogleCloudPrintMgt.GetCustomCJT(PrinterID, ObjectType, ObjectID), '', ''));
    end;

    procedure PrintViaEmail(PrinterName: Text;var Stream: DotNet MemoryStream)
    var
        SmtpMail: Codeunit "SMTP Mail";
        InStream: InStream;
    begin
        if Stream.Length < 1 then
          exit;

        SmtpMail.CreateMessage('NaviPartner','noreply@navipartner.dk',PrinterName,'Document Print','',false);
        SmtpMail.AddAttachmentStream(Stream, 'Document.pdf');
        SmtpMail.Send();
    end;

    local procedure "// Print via windows RTC client:"()
    begin
    end;

    procedure PrintBytesViaClientAddin(PrinterName: Text;PrintBytes: Text;TargetEncoding: Text)
    var
        [RunOnClient]
        StringBufferDotNet: DotNet StringBuffer;
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

    procedure PrintFileViaClientDotNet(PrinterName: Text;PrinterDialog: Boolean;var Stream: DotNet MemoryStream;FileExtension: Text)
    var
        [RunOnClient]
        Process: DotNet Process;
        [RunOnClient]
        ProcessStartInfo: DotNet ProcessStartInfo;
        [RunOnClient]
        ProcessWindowStyle: DotNet ProcessWindowStyle;
        [RunOnClient]
        PrintDialog: DotNet PrintDialog;
        [RunOnClient]
        DialogResult: DotNet DialogResult;
        FileMgt: Codeunit "File Management";
        TempBlob: Record TempBlob temporary;
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
          if not PrintDialog.ShowDialog().Equals (DialogResult.OK) then
            exit;

          PrinterName := PrintDialog.PrinterSettings.PrinterName;
        end;

        TempBlob.Blob.CreateOutStream(OutStream);
        CopyStream(OutStream, Stream);
        if not TempBlob.Blob.HasValue then
          exit;

        Filename := FileMgt.BLOBExport(TempBlob,FileExtension,false);
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

    local procedure "// Print via web request:"()
    begin
    end;

    procedure PrintBytesHTTP(URL: Text;Endpoint: Text;PrintBytes: Text;TargetEncoding: Text)
    var
        MobilePrintMgt: Codeunit "Mobile Print Mgt.";
    begin
        MobilePrintMgt.PrintJobHTTP(URL, Endpoint, PrintBytes, TargetEncoding);
    end;

    procedure PrintBytesBluetooth(DeviceName: Text;PrintBytes: Text;TargetEncoding: Text)
    var
        MobilePrintMgt: Codeunit "Mobile Print Mgt.";
    begin
        //-NPR5.32 [253590]
        MobilePrintMgt.PrintJobBluetooth(DeviceName, PrintBytes, TargetEncoding);
        //+NPR5.32 [253590]
    end;
}

