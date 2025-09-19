#if not BC17
codeunit 6184809 "NPR Spfy Delete Order" implements "NPR Nc Import List IProcess"
{
    Access = Internal;

    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";

    procedure RunProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        Order: JsonToken;
    begin
        ImportEntry.TestField("Store Code");
        OrderMgt.LoadOrder(ImportEntry, Order);
        DeleteOrder(ImportEntry."Store Code", Order);
    end;

    internal procedure DeleteOrder(ShopifyStoreCode: Code[20]; Order: JsonToken)
    var
        SalesHeader: Record "Sales Header";
    begin
        if not OrderMgt.FindSalesOrder(ShopifyStoreCode, Order, SalesHeader) then
            exit;
        DeleteOrder(SalesHeader);
    end;

    internal procedure DeleteOrder(var SalesHeader: Record "Sales Header")
    var
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        if SalesHeader.Status = SalesHeader.Status::Released then
            ReleaseSalesDoc.PerformManualReopen(SalesHeader);

        SalesHeader.Delete(true);
    end;
}
#endif