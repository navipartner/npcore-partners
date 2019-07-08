codeunit 6059832 "RFID Pre Print Generate Values"
{
    // NPR5.48/MMV /20181205 CASE 327107 Created object
    // 
    // This single instance object can be set as "Pre processing codeunit" on a template - it will substitute the record from a physical Retail Journal Line to a temporary instance where all quantities have been
    // exploded, and rfid value has been filled on each record.
    // 
    // CU 6059833 should be "Post Processing" on those same templates to return the record variable back to the physical variable - it will also prompt about saving the generated RFID values if the print was successful.
    // 
    // NPR5.50/MMV /20190220 CASE 343434 Number temp reocrds based on last line to avoid clashes with small gaps.

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        GlobalRetailJournalLine: Record "Retail Journal Line";
        Saved: Boolean;

    local procedure ConvertToBuffer(var RecRef: RecordRef)
    var
        tmpRetailJournalLine: Record "Retail Journal Line" temporary;
        RetailJournalLine: Record "Retail Journal Line";
        RetailJournalLineIn: Record "Retail Journal Line";
        i: Integer;
        RFIDMgt: Codeunit "RFID Mgt.";
        LineNo: Integer;
    begin
        RecRef.SetTable(RetailJournalLineIn);
        RetailJournalLine.Copy(RetailJournalLineIn);
        RetailJournalLine.SetFilter("Quantity to Print", '>%1', 0);
        //-NPR5.50 [343434]
        if not RetailJournalLine.FindLast then
          exit;
        LineNo := RetailJournalLine."Line No.";

        RetailJournalLine.FindSet;

        // IF NOT RetailJournalLine.FINDSET THEN
        //  EXIT;
        //+NPR5.50 [343434]

        SetOriginalRecord(RetailJournalLineIn);

        repeat
          for i := 1 to RetailJournalLine."Quantity to Print" do begin
            tmpRetailJournalLine := RetailJournalLine;
        //-NPR5.50 [343434]
        //    tmpRetailJournalLine."Line No." += i-1;
            LineNo += 1;
            tmpRetailJournalLine."Line No." := LineNo;
        //+NPR5.50 [343434]
            tmpRetailJournalLine."Quantity to Print" := 1;
            tmpRetailJournalLine."RFID Tag Value" := RFIDMgt.GetNextRFIDValue();
            tmpRetailJournalLine.Insert;
          end;
        until RetailJournalLine.Next = 0;

        RecRef.Close;
        RecRef.GetTable(tmpRetailJournalLine);
    end;

    procedure SetOriginalRecord(var RetailJournalLineIn: Record "Retail Journal Line")
    begin
        GlobalRetailJournalLine.Copy(RetailJournalLineIn);
        Saved := true;
    end;

    procedure GetOriginalRecord(var RetailJournalLineOut: Record "Retail Journal Line"): Boolean
    begin
        if not Saved then
          exit(false);

        RetailJournalLineOut.Copy(GlobalRetailJournalLine);
        Clear(GlobalRetailJournalLine);
        Saved := false;

        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014547, 'OnBeforePrintMatrix', '', false, false)]
    local procedure OnBeforeMatrixPrint(var RecRef: RecordRef;TemplateHeader: Record "RP Template Header";var Skip: Boolean)
    begin
        if TemplateHeader."Pre Processing Codeunit" <> CODEUNIT::"RFID Pre Print Generate Values" then
          exit;
        if RecRef.Number <> DATABASE::"Retail Journal Line" then
          exit;

        ConvertToBuffer(RecRef);
        Commit;
    end;
}

