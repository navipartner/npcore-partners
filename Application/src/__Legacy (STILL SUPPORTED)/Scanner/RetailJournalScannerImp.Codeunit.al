codeunit 6059910 "NPR Retail Journal Scanner Imp" implements "NPR IScanner Import"
{
    Access = Internal;

    trigger OnRun()
    begin
        CreateLine();
    end;

    procedure GetInitialLine()
    var
        NPRRetailJournalLine: Record "NPR Retail Journal Line";
    begin
        LineNo := 10000;

        NPRRetailJournalLine.SetRange("No.", NPRRetailJournalHeader."No.");
        if NPRRetailJournalLine.FindLast() then
            LineNo += NPRRetailJournalLine."Line No.";
    end;

    procedure ImportLine(ScannedShelf: Text; ScannedItemCode: Text; ScannedQuantity: Text)
    var
        ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
    begin
        ItemCode := ScannedItemCode;
        Quantity := ScannedQuantity;

        if not Run() then
            ScannerImportMgt.CreateErrorMessage(TempErrorMessage);
    end;

    local procedure CreateLine()
    var
        NPRRetailJournalLine: Record "NPR Retail Journal Line";
        ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        ScannerImportMgt.GetItemAndVariantCodeFromScannedCode(ItemCode, ItemNo, VariantCode);

        NPRRetailJournalLine.Init();
        NPRRetailJournalLine."No." := NPRRetailJournalHeader."No.";
        NPRRetailJournalLine."Calculation Date" := NPRRetailJournalHeader."Date of creation";
        NPRRetailJournalLine."Line No." := LineNo;
        if VariantCode <> '' then
            NPRRetailJournalLine.Validate("Variant Code", VariantCode);

        NPRRetailJournalLine.Validate("Item No.", ItemNo);
        Evaluate(NPRRetailJournalLine."Quantity to Print", Quantity);
        NPRRetailJournalLine.Validate("Quantity to Print");
        NPRRetailJournalLine.Insert();
        LineNo += 10000;
    end;

    procedure SetRecordRef(RecRef: RecordRef)
    begin
        RecRef.SetTable(NPRRetailJournalHeader);
    end;

    procedure ShowErrors()
    begin
        if TempErrorMessage.IsEmpty() then
            exit;
        Page.Run(Page::"Error Messages", TempErrorMessage);
    end;

    var
        NPRRetailJournalHeader: Record "NPR Retail Journal Header";
        TempErrorMessage: Record "Error Message" temporary;
        ItemCode: Text;
        Quantity: Text;
        LineNo: Integer;
}
