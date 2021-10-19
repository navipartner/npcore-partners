codeunit 6059832 "NPR RFID PrePrint Gen. Buffer"
{
    // NPR5.48/MMV /20181205 CASE 327107 Created object
    // 
    // This single instance object can be set as "Pre processing codeunit" on a template - it will substitute the record from a physical Retail Journal Line to a temporary instance where all quantities have been
    // exploded, and rfid value has been filled on each record.
    // 
    // CU 6059833 should be "Post Processing" on those same templates to return the record variable back to the physical variable.
    // 
    // NPR5.50/MMV /20190220 CASE 343434 Number temp reocrds based on last line to avoid clashes with small gaps.
    // NPR5.55/MMV /20200708 CASE 407265 Changed commit timing and show all printed values.

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        GlobalRetailJournalLine: Record "NPR Retail Journal Line";
        GlobalPrintBatchID: Guid;
        Saved: Boolean;

    local procedure ConvertToBuffer(var RecRef: RecordRef)
    var
        TempRetailJournalLine: Record "NPR Retail Journal Line" temporary;
        RetailJournalLine: Record "NPR Retail Journal Line";
        RetailJournalLineIn: Record "NPR Retail Journal Line";
        i: Integer;
        RFIDMgt: Codeunit "NPR RFID Mgt.";
        LineNo: Integer;
    begin
        RecRef.SetTable(RetailJournalLineIn);
        RetailJournalLine.Copy(RetailJournalLineIn);
        RetailJournalLine.SetFilter("Quantity to Print", '>%1', 0);
        if not RetailJournalLine.FindLast() then
            exit;
        LineNo := RetailJournalLine."Line No.";

        RetailJournalLine.FindSet();

        SetOriginalRecord(RetailJournalLineIn);

        repeat
            for i := 1 to RetailJournalLine."Quantity to Print" do begin
                TempRetailJournalLine := RetailJournalLine;
                LineNo += 1;
                TempRetailJournalLine."Line No." := LineNo;
                TempRetailJournalLine."Quantity to Print" := 1;
                TempRetailJournalLine."RFID Tag Value" := RFIDMgt.GetNextRFIDValue();
                RFIDMgt.CheckItemReference(TempRetailJournalLine."RFID Tag Value");
                TempRetailJournalLine.Insert();
            end;
        until RetailJournalLine.Next() = 0;

        if TempRetailJournalLine.FindSet() then begin
            GlobalPrintBatchID := CreateGuid();
            repeat
                RFIDMgt.OnBeforeSaveItemReferenceValue(TempRetailJournalLine);
                RFIDMgt.InsertItemReference(TempRetailJournalLine."Item No.", TempRetailJournalLine."Variant Code", TempRetailJournalLine."RFID Tag Value");
                RFIDMgt.LogRFIDPrint(TempRetailJournalLine, GlobalPrintBatchID);
            until TempRetailJournalLine.Next() = 0;
        end;

        RecRef.Close();
        RecRef.GetTable(TempRetailJournalLine);
    end;

    procedure SetOriginalRecord(var RetailJournalLineIn: Record "NPR Retail Journal Line")
    begin
        GlobalRetailJournalLine.Copy(RetailJournalLineIn);
        Saved := true;
    end;

    procedure GetOriginalRecord(var RetailJournalLineOut: Record "NPR Retail Journal Line"): Boolean
    begin
        if not Saved then
            exit(false);

        RetailJournalLineOut.Copy(GlobalRetailJournalLine);
        Clear(GlobalRetailJournalLine);
        Saved := false;

        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR RP Matrix Print Mgt.", 'OnBeforePrintMatrix', '', false, false)]
    local procedure OnBeforeMatrixPrint(var RecRef: RecordRef; TemplateHeader: Record "NPR RP Template Header"; var Skip: Boolean)
    var
        RFIDPrintLog: Record "NPR RFID Print Log";
    begin
        if TemplateHeader."Pre Processing Codeunit" <> CODEUNIT::"NPR RFID PrePrint Gen. Buffer" then
            exit;
        if RecRef.Number <> DATABASE::"NPR Retail Journal Line" then
            exit;

        ConvertToBuffer(RecRef);
        Commit();
        //-NPR5.55 [407265]
        RFIDPrintLog.SetRange("Batch ID", GlobalPrintBatchID);
        PAGE.Run(PAGE::"NPR RFID Print Log", RFIDPrintLog);
        //+NPR5.55 [407265]
    end;
}

