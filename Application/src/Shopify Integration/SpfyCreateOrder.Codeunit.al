#if not BC17
codeunit 6184808 "NPR Spfy Create Order" implements "NPR Nc Import List IProcess"
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
        ImportOrder(ImportEntry."Store Code", Order);
        ClearLastError();  //Do not save error text in Import List, if order processing completed successfully
    end;


    local procedure ImportOrder(ShopifyStoreCode: Code[20]; Order: JsonToken)
    var
        SalesHeader: Record "Sales Header";
    begin
        if OrderMgt.OrderExists(ShopifyStoreCode, Order) then
            exit;

        OrderMgt.LockTables();
        OrderMgt.InsertSalesHeader(ShopifyStoreCode, Order, SalesHeader);
        OrderMgt.InsertSalesLines(Order, SalesHeader, false);
        OrderMgt.InsertPaymentLines(ShopifyStoreCode, Order, SalesHeader);
    end;
}
#endif