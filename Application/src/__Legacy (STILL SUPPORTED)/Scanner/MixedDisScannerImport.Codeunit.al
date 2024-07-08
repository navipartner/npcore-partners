codeunit 6014405 "NPR Mixed Dis. Scanner Import" implements "NPR IScanner Import"
{
    Access = Internal;

    trigger OnRun()
    begin
        CreateLine();
    end;

    procedure GetInitialLine()
    begin
    end;

    procedure ImportLine(ScannedShelf: Text; ScannedItemCode: Text; ScannedQuantity: Text)
    var
        ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
    begin
        ItemCode := ScannedItemCode;
        if not Run() then
            ScannerImportMgt.CreateErrorMessage(TempErrorMessage);
    end;

    local procedure CreateLine()
    var
        NPRMixedDiscountLine: Record "NPR Mixed Discount Line";
        ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        ScannerImportMgt.GetItemAndVariantCodeFromScannedCode(ItemCode, ItemNo, VariantCode);
        NPRMixedDiscountLine.Code := NPRMixedDiscount.Code;
        NPRMixedDiscountLine.Validate("No.", ItemNo);
        NPRMixedDiscountLine.Validate("Disc. Grouping Type", NPRMixedDiscountLine."Disc. Grouping Type"::Item);
        if VariantCode <> '' then
            NPRMixedDiscountLine.Validate("Variant Code", VariantCode);
        NPRMixedDiscountLine.Insert();
    end;

    procedure SetRecordRef(RecRef: RecordRef)
    begin
        RecRef.SetTable(NPRMixedDiscount);
    end;

    procedure ShowErrors()
    begin
        if TempErrorMessage.IsEmpty() then
            exit;

        Page.Run(Page::"Error Messages", TempErrorMessage);
    end;

    var
        NPRMixedDiscount: Record "NPR Mixed Discount";
        TempErrorMessage: Record "Error Message" temporary;
        ItemCode: Text;
}
