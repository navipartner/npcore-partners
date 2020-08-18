codeunit 6059833 "RFID Post Print Restore Record"
{
    // NPR5.48/MMV /20181205 CASE 327107 Created object
    // 
    // This object can be set as "Post processing codeunit" on a template.
    // It will show a list of all tags printed with their unique values
    // 
    // CU 6059832 should be "Pre Processing" on those same templates
    // 
    // NPR5.55/MMV /20200708 CASE 407265 Changed commit timing.


    trigger OnRun()
    begin
    end;

    local procedure RestoreRecord(var RecRef: RecordRef)
    var
        RFIDPrePrintGenerateValues: Codeunit "RFID Pre Print Generate Buffer";
        OriginalRetailJournalLine: Record "Retail Journal Line";
    begin
        if not RFIDPrePrintGenerateValues.GetOriginalRecord(OriginalRetailJournalLine) then
          exit;

        RecRef.Close;
        RecRef.GetTable(OriginalRetailJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014547, 'OnAfterPrintMatrix', '', false, false)]
    local procedure OnAfterPrintMatrix(var RecRef: RecordRef;TemplateHeader: Record "RP Template Header")
    var
        RetailJournalLine: Record "Retail Journal Line";
    begin
        if TemplateHeader."Post Processing Codeunit" <> CODEUNIT::"RFID Post Print Restore Record" then
          exit;
        if RecRef.Number <> DATABASE::"Retail Journal Line" then
          exit;

        //-NPR5.55 [407265]
        //SaveRFIDValues(RecRef);
        //+NPR5.55 [407265]
        RestoreRecord(RecRef);
    end;
}

