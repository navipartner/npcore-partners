codeunit 6059833 "RFID Post Print Save Values"
{
    // NPR5.48/MMV /20181205 CASE 327107 Created object
    // 
    // This object can be set as "Post processing codeunit" on a template.
    // If any RFID values were printed it will prompt the user about storing these as item cross reference in the system. This implies that the users has first double check the print quality.
    // 
    // CU 6059832 should be "Pre Processing" on those same templates


    trigger OnRun()
    begin
    end;

    local procedure SaveRFIDValues(var RecRef: RecordRef)
    var
        RFIDMgt: Codeunit "RFID Mgt.";
        tmpRetailJournalLine: Record "Retail Journal Line" temporary;
    begin
        RFIDMgt.SaveRFIDValues(RecRef);
    end;

    local procedure RestoreRecord(var RecRef: RecordRef)
    var
        RFIDPrePrintGenerateValues: Codeunit "RFID Pre Print Generate Values";
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
        if TemplateHeader."Post Processing Codeunit" <> CODEUNIT::"RFID Post Print Save Values" then
          exit;
        if RecRef.Number <> DATABASE::"Retail Journal Line" then
          exit;

        SaveRFIDValues(RecRef);
        RestoreRecord(RecRef);
    end;
}

