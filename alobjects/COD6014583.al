codeunit 6014583 "Report Printer Interface"
{
    // NPR5.22/MMV/20160317 CASE 228382 Created CU
    // 
    // Replace REPORT.RUN calls with a reference to this CU for all reports that should support seamless printing in the NAV Web (Major Tom)/Tablet/Phone clients.
    // This codeunit works together with 'Object Output Selection' where you can specify an e-mail or printername for any reports.
    // 
    // If you want to run a report without a record, set variant to some type other than Record / RecordRef.
    // 
    // NPR5.23/MMV /20160609 CASE 240856 Added SetNOGUI();
    //                                   Added GetLastError();
    //                                   Added TryPrintPDF();
    //                                   The above does not catch any errors in the report execution itself - Only the print methods.
    //                                   This is done to still have rollback of any data modifications inside a report execution if an error occurs.
    // NPR5.26/MMV /20160824 CASE 246209 Streams instead of temp files.
    //                                   Handle reports that does not run on a record.
    //                                   Deleted old comments.
    //                                   Refactored.
    // NPR5.27/MMV /20161020 CASE 254204 Catch misuse of REPORT.SAVEAS manually just like NAV run-time did for REPORT.RUN.
    // NPR5.29/MMV /20161123 CASE 256521 Updated call to Print Method Mgt. for file print.
    //                                   Removed overzealous dataitem check that was added in NPR5.27.
    //                                   Removed guard against blank outputpath.
    // NPR5.30/MMV /20170209 CASE 261964 Updated google print function.
    // NPR5.47/TJ  /20180919 CASE 327664 Recoded by MMV to properly work on web client
    // NPR5.48/MMV /20181203 CASE 338596 Only check for POS on GUI sessions.
    // NPR5.53/THRO/20200106 CASE 383562 Added PrintNode pdf print


    trigger OnRun()
    begin
    end;

    var
        SuppressError: Boolean;
        LastErrorText: Text;
        Err_ReportPrint: Label 'Error when printing report %1 %2';
        RecordSpecified: Boolean;
        Err_InvalidRecRef: Label 'The first data item in report "%1" does not use table %2';

    procedure RunReport(Number: Integer; ReqWindow: Boolean; SystemPrinter: Boolean; "Record": Variant)
    var
        POSSession: Codeunit "POS Session";
        POSFrontEndMgt: Codeunit "POS Front End Management";
        ObjectOutputMgt: Codeunit "Object Output Mgt.";
        ObjectOutputSelection: Record "Object Output Selection";
    begin
        //-NPR5.47 [327664]
        // RecordSpecified := Record.ISRECORD OR Record.ISRECORDREF;
        //
        // IF CURRENTCLIENTTYPE = CLIENTTYPE::Windows THEN BEGIN
        //  IF RecordSpecified THEN
        //    REPORT.RUN(Number, ReqWindow, SystemPrinter, Record)
        //  ELSE
        //    REPORT.RUN(Number, ReqWindow, SystemPrinter);
        //  EXIT;
        // END;
        //
        // IF NOT TryGetOutputPath(Number, OutputPath) THEN BEGIN
        //  IF RecordSpecified THEN
        //    REPORT.RUN(Number, ReqWindow, SystemPrinter, Record)
        //  ELSE
        //    REPORT.RUN(Number, ReqWindow, SystemPrinter);
        //  EXIT;
        // END;
        //
        // IF NOT CreatePDF(Number, ReqWindow, Record, PDFStream) THEN
        //  EXIT;
        //
        // IF PDFStream.Length < 1 THEN
        //  EXIT;
        //
        // IF TryPrintPDF(OutputPath, PDFStream, ObjectOutputMgt.GetReportOutputType(Number), Number) THEN
        //  EXIT;
        //
        // LastErrorText := GETLASTERRORTEXT();
        // IF (NOT SuppressError) AND GUIALLOWED THEN BEGIN
        //  IF LastErrorText <> '' THEN
        //    LastErrorText := ' - ' + LastErrorText;
        //  ERROR(Err_ReportPrint, FORMAT(Number), LastErrorText);
        // END;

        RecordSpecified := Record.IsRecord or Record.IsRecordRef;

        //-NPR5.48 [338598]
        if GuiAllowed then
            //+NPR5.48 [338598]
            if not POSSession.IsActiveSession(POSFrontEndMgt) then begin
                RunStandardReportFlow(Number, ReqWindow, SystemPrinter, Record);
                exit;
            end;

        if not ObjectOutputMgt.TryGetOutputRec(ObjectOutputSelection."Object Type"::Report, Number, '', UserId, ObjectOutputSelection) then begin
            //-NPR5.48 [338598]
            if GuiAllowed then
                //+NPR5.48 [338598]
                RunStandardReportFlow(Number, ReqWindow, SystemPrinter, Record);
            exit;
        end;

        RunCustomReportFlow(Number, ReqWindow, Record, ObjectOutputSelection);
        //+NPR5.47 [327664]
    end;

    local procedure RunStandardReportFlow(Number: Integer; ReqWindow: Boolean; SystemPrinter: Boolean; "Record": Variant)
    begin
        //-NPR5.47 [327664]
        if RecordSpecified then
            REPORT.Run(Number, ReqWindow, SystemPrinter, Record)
        else
            REPORT.Run(Number, ReqWindow, SystemPrinter);
        //+NPR5.47 [327664]
    end;

    local procedure RunCustomReportFlow(Number: Integer; ReqWindow: Boolean; "Record": Variant; ObjectOutputSelection: Record "Object Output Selection")
    var
        PDFStream: DotNet npNetMemoryStream;
    begin
        //-NPR5.47 [327664]
        if not (ObjectOutputSelection."Output Type" in [ObjectOutputSelection."Output Type"::"Printer Name",
                                                        ObjectOutputSelection."Output Type"::"Google Print",
                                                        ObjectOutputSelection."Output Type"::"PrintNode PDF", //NPR5.53 [383562]
                                                        ObjectOutputSelection."Output Type"::"E-mail"]) then
            ObjectOutputSelection.FieldError("Output Type");

        if not CreatePDF(Number, ReqWindow, Record, PDFStream) then
            exit;

        if PDFStream.Length < 1 then
            exit;

        if TryPrintPDF(ObjectOutputSelection."Output Path", PDFStream, ObjectOutputSelection."Output Type", Number) then
            exit;

        LastErrorText := GetLastErrorText();
        if (not SuppressError) and GuiAllowed then begin
            if LastErrorText <> '' then
                LastErrorText := ' - ' + LastErrorText;
            Error(Err_ReportPrint, Format(Number), LastErrorText);
        end;
        //+NPR5.47 [327664]
    end;

    procedure SetSuppressError(SuppressErrorIn: Boolean)
    begin
        SuppressError := SuppressErrorIn;
    end;

    procedure GetLastError(): Text
    begin
        exit(LastErrorText);
    end;

    local procedure "-- Aux"()
    begin
    end;

    local procedure CreatePDF(Number: Integer; ReqWindow: Boolean; var "Record": Variant; var OutPDFStream: DotNet npNetMemoryStream): Boolean
    var
        Parameters: Text;
        OutStr: OutStream;
        RecRef: RecordRef;
    begin
        if ReqWindow then begin
            Parameters := REPORT.RunRequestPage(Number);
            if Parameters = '' then
                exit(false);
        end;

        if Record.IsRecord then
            RecRef.GetTable(Record)
        else
            if Record.IsRecordRef then
                RecRef := Record;

        OutPDFStream := OutPDFStream.MemoryStream();
        OutStr := OutPDFStream;

        if RecordSpecified then begin
            REPORT.SaveAs(Number, Parameters, REPORTFORMAT::Pdf, OutStr, RecRef)
        end else
            REPORT.SaveAs(Number, Parameters, REPORTFORMAT::Pdf, OutStr);

        exit(true);
    end;

    [TryFunction]
    local procedure TryPrintPDF(OutputPath: Text; var Stream: DotNet npNetMemoryStream; OutputType: Integer; ObjectID: Integer)
    var
        ObjectOutputSelection: Record "Object Output Selection";
        PrintMethodMgt: Codeunit "Print Method Mgt.";
        OutErrorMessage: Text;
    begin
        //-NPR5.30 [261964]
        //Success := TRUE;
        //+NPR5.30 [261964]

        case OutputType of
            ObjectOutputSelection."Output Type"::"E-mail":
                PrintMethodMgt.PrintViaEmail(OutputPath, Stream);
            ObjectOutputSelection."Output Type"::"Printer Name":
                PrintMethodMgt.PrintFileLocal(OutputPath, Stream, 'pdf');
                //-NPR5.30 [261964]
                //ObjectOutputSelection."Output Type"::"Google Print" : Success := PrintMethodMgt.PrintViaGoogleCloud( OutputPath, Stream, 'application/pdf', 0, ObjectID, OutErrorMessage);
            ObjectOutputSelection."Output Type"::"Google Print":
                PrintMethodMgt.PrintViaGoogleCloud(OutputPath, Stream, 'application/pdf', 0, ObjectID);
                //+NPR5.30 [261964]
          //-NPR5.53 [383562]
          ObjectOutputSelection."Output Type"::"PrintNode PDF" :
            begin
              ObjectOutputSelection."Object Type" := ObjectOutputSelection."Object Type"::Report;
              ObjectOutputSelection."Object ID" := ObjectID;
              ObjectOutputSelection.GetObjectName();
              PrintMethodMgt.PrintViaPrintNodePdf(OutputPath, Stream, ObjectOutputSelection."Object Name");
            end;
          //+NPR5.53 [383562]
        end;

        //-NPR5.30 [261964]
        // IF NOT Success THEN
        //  ERROR(OutErrorMessage);
        //+NPR5.30 [261964]
    end;
}

