codeunit 6059800 "NPR Transfer Scanner Import" implements "NPR IScanner Import"
{
    Access = Internal;

    trigger OnRun()
    begin
        CreateLine();
    end;

    procedure GetInitialLine()
    var
        TransferLine: Record "Transfer Line";
    begin
        LineNo := 10000;

        TransferLine.SetRange("Document No.", TransferHeader."No.");
        if TransferLine.FindLast() then
            LineNo += TransferLine."Line No.";
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
        RecRef.SetTable(TransferHeader);
    end;

    procedure ShowErrors()
    begin
        if TempErrorMessage.IsEmpty() then
            exit;

        Page.Run(Page::"Error Messages", TempErrorMessage);
    end;

    local procedure CreateLine()
    var
        TransferLine: Record "Transfer Line";
        ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
    begin
        TransferLine.Init();
        TransferLine."Document No." := TransferHeader."No.";
        TransferLine."Line No." := LineNo;
        TransferLine.Insert();

        TransferLine.Validate("Item No.", ScannerImportMgt.GetItemNoFromScannedCode(ItemCode));
        Evaluate(TransferLine.Quantity, Quantity);
        TransferLine.Validate(Quantity);
        TransferLine.Modify();

        LineNo += 10000;
    end;

    var
        TransferHeader: Record "Transfer Header";
        TempErrorMessage: Record "Error Message" temporary;
        ItemCode: Text;
        Quantity: Text;
        LineNo: Integer;
}