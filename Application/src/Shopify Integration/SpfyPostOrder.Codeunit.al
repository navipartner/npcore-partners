#if not BC17
codeunit 6184815 "NPR Spfy Post Order" implements "NPR Nc Import List IProcess"
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
        PostOrder(ImportEntry."Store Code", Order);
        ClearLastError();  //Do not save error text in Import List, if order processing completed successfully
    end;

    local procedure PostOrder(ShopifyStoreCode: Code[20]; Order: JsonToken)
    var
        SalesHeader: Record "Sales Header";
        TempSalesInvHeader: Record "Sales Invoice Header" temporary;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        if OrderMgt.FindSalesInvoices(ShopifyStoreCode, Order, TempSalesInvHeader) then
            exit;

        OrderMgt.LockTables();
        if not OrderMgt.FindSalesOrder(ShopifyStoreCode, Order, SalesHeader) then
            OrderMgt.InsertSalesHeader(ShopifyStoreCode, Order, SalesHeader)
        else begin
            SalesHeader.SetHideValidationDialog(true);
            if SalesHeader.Status = SalesHeader.Status::Released then
                ReleaseSalesDoc.PerformManualReopen(SalesHeader);

            OrderMgt.DeleteSalesLines(SalesHeader);
            OrderMgt.UpdateSalesHeader(ShopifyStoreCode, Order, SalesHeader);
        end;

        OrderMgt.InsertSalesLines(Order, SalesHeader, true);
        Commit();

        OrderMgt.PostOrder(SalesHeader);
    end;
}
#endif