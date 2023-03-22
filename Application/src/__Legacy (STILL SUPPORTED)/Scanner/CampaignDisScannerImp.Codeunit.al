codeunit 6059812 "NPR Campaign Dis. Scanner Imp" implements "NPR IScanner Import"
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
        NPRPeriodDiscountLine: Record "NPR Period Discount Line";
        ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        ScannerImportMgt.GetItemAndVariantCodeFromScannedCode(ItemCode, ItemNo, VariantCode);
        NPRPeriodDiscountLine.Code := NPRPeriodDiscount.Code;
        NPRPeriodDiscountLine.Validate("Item No.", ItemNo);
        if VariantCode <> '' then
            NPRPeriodDiscountLine.Validate("Variant Code", VariantCode);
        NPRPeriodDiscountLine.Insert();
    end;

    procedure SetRecordRef(RecRef: RecordRef)
    begin
        RecRef.SetTable(NPRPeriodDiscount);
    end;

    procedure ShowErrors()
    begin
        if TempErrorMessage.IsEmpty() then
            exit;

        Page.Run(Page::"Error Messages", TempErrorMessage);
    end;

    var
        NPRPeriodDiscount: Record "NPR Period Discount";
        TempErrorMessage: Record "Error Message" temporary;
        ItemCode: Text;

}
