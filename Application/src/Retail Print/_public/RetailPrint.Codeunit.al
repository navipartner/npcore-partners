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
}