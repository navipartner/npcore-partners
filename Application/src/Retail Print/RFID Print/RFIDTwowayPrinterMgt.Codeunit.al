codeunit 6059830 "NPR RFID Two-way Printer Mgt."
{
    EventSubscriberInstance = Manual;

    var
        HandlerCodeunit: Integer;
        tmpRFIDPrintBuffer: Record "NPR RFID Print Buffer" temporary;
        LastLineQuantity: Decimal;
        ERR_PRINT_QUANTITY: Label 'Can only handle one RFID print per item quantity';
        RecordSend: Boolean;
        ERR_PRINT_RECORD: Label 'RFID module does not support more than one record at a time';
        ERR_HANDLER_OVERLAP: Label 'Cannot set multiple RFID handlers in one print batch';

    procedure PrintItem(Item: Record Item; ReportType: Integer)
    var
        LabelLibrary: Codeunit "NPR Label Library";
        This: Codeunit "NPR RFID Two-way Printer Mgt.";
    begin
        BindSubscription(This);

        LabelLibrary.PrintItem(Item, true, 1, true, ReportType);

        This.HandleRFIDBuffer();
    end;

    procedure PrintRetailJournal(var JournalLine: Record "NPR Retail Journal Line"; ReportType: Integer)
    var
        LabelLibrary: Codeunit "NPR Label Library";
        This: Codeunit "NPR RFID Two-way Printer Mgt.";
    begin
        BindSubscription(This);

        LabelLibrary.PrintRetailJournal(JournalLine, ReportType);

        This.HandleRFIDBuffer();
    end;

    local procedure PreparePrintBufferEntry(JournalLine: Record "NPR Retail Journal Line")
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

    local procedure PrintRetailJournalLineRecord(JournalLine: Record "NPR Retail Journal Line"; ReportType: Integer)
    var
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
        POSUnit: Record "NPR POS Unit";
    begin
        PreparePrintBufferEntry(JournalLine);
        RecRef.GetTable(JournalLine);
        RecRef.SetRecFilter();

        RetailReportSelectionMgt.SetMatrixPrintIterationFieldNo(JournalLine.FieldNo("Quantity to Print"));
        RetailReportSelectionMgt.SetRequestWindow(true);
        RetailReportSelectionMgt.SetRegisterNo(POSUnit.GetCurrentPOSUnit());
        RetailReportSelectionMgt.RunObjects(RecRef, ReportType);
    end;

    local procedure "// Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleRFIDBuffer(HandlerCodeunit: Integer; var tmpRFIDPrintBuffer: Record "NPR RFID Print Buffer" temporary)
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
    local procedure OnBeforeSendMatrixObjectOutput(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Codeunit "NPR RP Matrix Printer Interf."; NoOfPrints: Integer; var Skip: Boolean)
    var
        i: Integer;
        PrintJob: Text;
        OutStream: OutStream;
    begin
        if HandlerCodeunit = 0 then
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
            tmpRFIDPrintBuffer.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014413, 'OnBeforePrintRetailJournal', '', false, false)]
    local procedure OnBeforePrintRetailJournal(var JournalLine: Record "NPR Retail Journal Line"; ReportType: Integer; var Skip: Boolean)
    begin
        Skip := true;

        if JournalLine.FindSet() then
            repeat
                PrintRetailJournalLineRecord(JournalLine, ReportType);
            until JournalLine.Next() = 0;
    end;
}

