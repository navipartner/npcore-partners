codeunit 6059844 "NPR Retail Print"
{
    Access = Public;

    procedure GetItemVariantBarcode(var Barcode: Text[50]; ItemNo: Code[20]; VariantCode: Code[10]; var ResolvingTable: Integer; AllowDiscontinued: Boolean): Boolean
    var
        BarcodeLookupMgt: Codeunit "NPR Barcode Lookup Mgt.";
    begin
        exit(BarcodeLookupMgt.GetItemVariantBarcode(Barcode, ItemNo, VariantCode, ResolvingTable, AllowDiscontinued));
    end;

    procedure EnterTransferItemCrossRef(var TransferLine: Record "Transfer Line")
    var
        BarcodeLookupMgt: Codeunit "NPR Barcode Lookup Mgt.";
    begin
        BarcodeLookupMgt.EnterTransferItemCrossRef(TransferLine);
    end;

    procedure ItemToRetailJnlLine(ItemNo: Code[20]; VariantCode: Code[10]; Quantity: Integer; PK: Code[40]; var RetailJournalLineOut: Record "NPR Retail Journal Line")
    var
        LabelManagement: Codeunit "NPR Label Management";
    begin
        LabelManagement.ItemToRetailJnlLine(ItemNo, VariantCode, Quantity, PK, RetailJournalLineOut);
    end;

    procedure PrintRetailJournal(var JournalLine: Record "NPR Retail Journal Line"; ReportType: Integer)
    var
        LabelManagement: Codeunit "NPR Label Management";
    begin
        LabelManagement.PrintRetailJournal(JournalLine, ReportType);
    end;

    procedure GetDataItemTableId(Code: Code[10]; Level: Integer): Integer
    var
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin
        exit(RPTemplateMgt.GetDataItemTableId(Code, Level));
    end;
}