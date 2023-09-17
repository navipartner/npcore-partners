codeunit 6151025 "NPR POS Action MScanFind ItemB"
{
    Access = Internal;


    #region FindItemBarcodeFromSalesLine
    internal procedure FindItemBarcodeFromSalesLine(SalesLine: Codeunit "NPR POS Sale Line";
                                                    var Barcode: Text[50]) Found: Boolean
    var

        CurrPOSSalesLine: Record "NPR POS Sale Line";
        BarcodeLibrary: Codeunit "NPR Barcode Lookup Mgt.";
        ResolvingTable: Integer;
    begin
        SalesLine.GetCurrentSaleLine(CurrPOSSalesLine);

        if not (CurrPOSSalesLine."Line Type" = CurrPOSSalesLine."Line Type"::Item) then
            exit;

        Found := BarcodeLibrary.GetItemVariantBarcode(Barcode,
                                                      CurrPOSSalesLine."No.",
                                                      CurrPOSSalesLine."Variant Code",
                                                      ResolvingTable,
                                                      true);
    end;
    #endregion FindItemBarcodeFromSalesLine
}
