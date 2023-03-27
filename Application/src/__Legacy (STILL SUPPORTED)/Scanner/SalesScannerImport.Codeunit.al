codeunit 6059802 "NPR Sales Scanner Import" implements "NPR IScanner Import"
{
    Access = Internal;

    trigger OnRun()
    begin
        CreateLine();
    end;

    procedure GetInitialLine()
    var
        SalesLine: Record "Sales Line";
    begin
        LineNo := 10000;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            LineNo += SalesLine."Line No.";
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
        RecRef.SetTable(SalesHeader);
    end;

    procedure ShowErrors()
    begin
        if TempErrorMessage.IsEmpty() then
            exit;

        Page.Run(Page::"Error Messages", TempErrorMessage);
    end;

    local procedure CreateLine()
    var
        SalesLine: Record "Sales Line";
        ItemReference: Record "Item Reference";
        ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        ScannerImportMgt.GetItemAndVariantCodeFromScannedCode(ItemCode, ItemNo, VariantCode);

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert();

        SalesLine.Type := SalesLine.Type::Item;
        SalesLine.Validate("No.", ItemNo);
        if VariantCode <> '' then
            SalesLine.Validate("Variant Code", VariantCode);
        Evaluate(SalesLine.Quantity, Quantity);
        SalesLine.Validate(Quantity);
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference No.", ItemCode);
        if ItemReference.FindFirst() then
            SalesLine."Item Reference No." := ItemReference."Reference No.";
        SalesLine.Modify();

        LineNo += 10000;
    end;

    var
        SalesHeader: Record "Sales Header";
        TempErrorMessage: Record "Error Message" temporary;
        ItemCode: Text;
        Quantity: Text;
        LineNo: Integer;
}