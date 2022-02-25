codeunit 6059801 "NPR Purchase Scanner Import" implements "NPR IScanner Import"
{
    Access = Internal;

    trigger OnRun()
    begin
        CreateLine();
    end;

    procedure GetInitialLine()
    var
        PurchaseLine: Record "Purchase Line";
    begin
        LineNo := 10000;

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindLast() then
            LineNo += PurchaseLine."Line No.";
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

    procedure SetRecordRef(RecRef: RecordRef)
    begin
        RecRef.SetTable(PurchaseHeader);
    end;

    procedure ShowErrors()
    begin
        if TempErrorMessage.IsEmpty() then
            exit;

        Page.Run(Page::"Error Messages", TempErrorMessage);
    end;

    local procedure CreateLine()
    var
        PurchaseLine: Record "Purchase Line";
        ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
    begin
        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine."Line No." := LineNo;
        PurchaseLine.Insert();

        PurchaseLine.Type := PurchaseLine.Type::Item;
        PurchaseLine.Validate("No.", ScannerImportMgt.GetItemNoFromScannedCode(ItemCode));
        Evaluate(PurchaseLine.Quantity, Quantity);
        PurchaseLine.Validate(Quantity);
        PurchaseLine.Modify();

        LineNo += 10000;
    end;

    var
        PurchaseHeader: Record "Purchase Header";
        TempErrorMessage: Record "Error Message" temporary;
        ItemCode: Text;
        Quantity: Text;
        LineNo: Integer;
}