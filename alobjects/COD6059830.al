codeunit 6059830 "RFID Two-way Printer Mgt."
{
    // NPR5.48/MMV /20181128 CASE 327107 Created object
    // 
    // Codeunit hooks onto normal label flow and collects the jobs into a buffer that is send to an RFID handler.
    // This handler can be set by invoking OnSetRFIDHandlerCodeunit() at any moment during the print, ie. from inside a print codeunit or via "Pre Processing Codeunit" if using a template.
    // 
    // When OnHandleRFIDBuffer() is invoked the handler should take it from there, either pre-generating EPC/Serial Number values and imprinting tags with them or reading
    // existing unique EPCs and creating them as item cross reference.
    // 
    // Note: This manual event approach is only relevant if an RFID use-case does not fit into 1-way printer communication approach. If it does, RFID print commands in the template module should be used.

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        HandlerCodeunit: Integer;
        tmpRFIDPrintBuffer: Record "RFID Print Buffer" temporary;
        LastLineQuantity: Decimal;
        ERR_PRINT_QUANTITY: Label 'Can only handle one RFID print per item quantity';
        RecordSend: Boolean;
        ERR_PRINT_RECORD: Label 'RFID module does not support more than one record at a time';
        ERR_HANDLER_OVERLAP: Label 'Cannot set multiple RFID handlers in one print batch';

    procedure PrintItem(Item: Record Item;ReportType: Integer)
    var
        LabelLibrary: Codeunit "Label Library";
        Success: Boolean;
        This: Codeunit "RFID Two-way Printer Mgt.";
    begin
        BindSubscription(This);

        LabelLibrary.PrintItem(Item, true, 1, true, ReportType);

        This.HandleRFIDBuffer();
    end;

    procedure PrintRetailJournal(var JournalLine: Record "Retail Journal Line";ReportType: Integer)
    var
        LabelLibrary: Codeunit "Label Library";
        Success: Boolean;
        This: Codeunit "RFID Two-way Printer Mgt.";
    begin
        BindSubscription(This);

        LabelLibrary.PrintRetailJournal(JournalLine, ReportType);

        This.HandleRFIDBuffer();
    end;

    local procedure PreparePrintBufferEntry(JournalLine: Record "Retail Journal Line")
    begin
        JournalLine.TestField("Item No.");
        RecordSend := false;
        LastLineQuantity := JournalLine."Quantity to Print";

        tmpRFIDPrintBuffer."Item No." := JournalLine."Item No.";
        tmpRFIDPrintBuffer."Variant Code" := JournalLine."Variant Code";
        tmpRFIDPrintBuffer."Serial No." := JournalLine."Serial No.";
    end;

    procedure HandleRFIDBuffer()
    begin
        if tmpRFIDPrintBuffer.IsEmpty then
          exit;
        if HandlerCodeunit = 0 then
          exit;

        OnHandleRFIDBuffer(HandlerCodeunit, tmpRFIDPrintBuffer);
    end;

    local procedure PrintRetailJournalLineRecord(JournalLine: Record "Retail Journal Line";ReportType: Integer)
    var
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
        RecRef: RecordRef;
        RetailFormCode: Codeunit "Retail Form Code";
    begin
        PreparePrintBufferEntry(JournalLine);
        RecRef.GetTable(JournalLine);
        RecRef.SetRecFilter;

        RetailReportSelectionMgt.SetMatrixPrintIterationFieldNo(JournalLine.FieldNo("Quantity to Print"));
        RetailReportSelectionMgt.SetRequestWindow(true);
        RetailReportSelectionMgt.SetRegisterNo(RetailFormCode.FetchRegisterNumber);
        RetailReportSelectionMgt.RunObjects(RecRef,ReportType);
    end;

    local procedure "// Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleRFIDBuffer(HandlerCodeunit: Integer;var tmpRFIDPrintBuffer: Record "RFID Print Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetRFIDHandlerCodeunit(CodeunitID: Integer)
    begin
    end;

    local procedure "// Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059830, 'OnSetRFIDHandlerCodeunit', '', false, false)]
    local procedure OnSubscribeSetRFIDHandlerCodeunit(CodeunitID: Integer)
    begin
        if HandlerCodeunit = CodeunitID then
          exit;
        if HandlerCodeunit <> 0 then
          Error(ERR_HANDLER_OVERLAP);

        HandlerCodeunit := CodeunitID;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014580, 'OnBeforeSendMatrixPrint', '', false, false)]
    local procedure OnBeforeSendMatrixObjectOutput(TemplateCode: Text;CodeunitId: Integer;ReportId: Integer;var Printer: Codeunit "RP Matrix Printer Interface";NoOfPrints: Integer;var Skip: Boolean)
    var
        i: Integer;
        PrintJob: Text;
        OutStream: OutStream;
    begin
        if HandlerCodeunit = 0  then
          exit;
        Skip := true;

        if RecordSend then
          Error(ERR_PRINT_RECORD);
        RecordSend := true;

        if NoOfPrints < 1 then
          exit;
        if NoOfPrints <> LastLineQuantity then
          Error(ERR_PRINT_QUANTITY);

        Printer.OnGetPrintBytes(PrintJob);
        tmpRFIDPrintBuffer."Print Job".CreateOutStream(OutStream);
        OutStream.Write(PrintJob);

        for i := 1 to NoOfPrints do begin
          tmpRFIDPrintBuffer."Tag No." += 1;
          tmpRFIDPrintBuffer.Insert;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014413, 'OnBeforePrintRetailJournal', '', false, false)]
    local procedure OnBeforePrintRetailJournal(var JournalLine: Record "Retail Journal Line";ReportType: Integer;var Skip: Boolean)
    var
        RetailJournalLine: Record "Retail Journal Line";
        i: Integer;
    begin
        Skip := true;

        if JournalLine.FindSet then
          repeat
            PrintRetailJournalLineRecord(JournalLine, ReportType);
          until JournalLine.Next = 0;
    end;
}

