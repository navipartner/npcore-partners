#if not BC17
codeunit 6184815 "NPR Spfy Post Order" implements "NPR Nc Import List IProcess"
{
    Access = Internal;

    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";

    procedure RunProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        SpfyDeleteOrder: Codeunit "NPR Spfy Delete Order";
        Order: JsonToken;
        AnonymizedCustomerOrderErr: Label 'The order is for an anonymous customer. If the order has not yet been posted, the system has deleted it. Further processing has been skipped.';
    begin
        ImportEntry.Find();
        ImportEntry.TestField("Store Code");
        OrderMgt.LoadOrder(ImportEntry, Order);
        if OrderMgt.IsAnonymizedCustomerOrder(ImportEntry, Order, AnonymizedCustomerOrderErr) then begin
            SpfyDeleteOrder.DeleteOrder(ImportEntry."Store Code", Order);
            exit;
        end;
        PostOrder(ImportEntry."Store Code", Order, ImportEntry);
        ClearLastError();  //Do not save error text in Import List, if order processing completed successfully
    end;

    local procedure PostOrder(ShopifyStoreCode: Code[20]; Order: JsonToken; var ImportEntry: Record "NPR Nc Import Entry")
    var
        SalesHeader: Record "Sales Header";
        TempSalesInvHeader: Record "Sales Invoice Header" temporary;
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        SpfyDeleteOrder: Codeunit "NPR Spfy Delete Order";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        AlreadyPostedMsg: Label 'The order has already been posted. Further processing has been skipped.';
    begin
        if OrderMgt.SkipOrderImport(ShopifyStoreCode, Order) then
            exit;

        if not OrderMgt.FindSalesOrder(ShopifyStoreCode, Order, SalesHeader) then begin
            if OrderMgt.FindSalesInvoices(ShopifyStoreCode, Order, TempSalesInvHeader) then begin
                OrderMgt.SetImportEntryErrorMsg(ImportEntry, AlreadyPostedMsg);
                exit;
            end;
            OrderMgt.InsertSalesHeader(ShopifyStoreCode, Order, SalesHeader)
        end else begin
            SalesHeader.SetHideValidationDialog(true);
            if SalesHeader.Status = SalesHeader.Status::Released then
                ReleaseSalesDoc.PerformManualReopen(SalesHeader);
            OrderMgt.UpdateSalesHeader(ShopifyStoreCode, Order, SalesHeader);
        end;

        OrderMgt.UpsertSalesLines(ShopifyStoreCode, Order, SalesHeader, true);
        OrderMgt.InsertPaymentLines(ShopifyStoreCode, Order, SalesHeader);
        Commit();

        if OrderMgt.PostOrder(SalesHeader) then
            if SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then
                if SpfyIntegrationMgt.DeleteAfterFinalPosting(ShopifyStoreCode) then begin
                    Commit();
                    SpfyDeleteOrder.DeleteOrder(SalesHeader);
                end;
    end;
}
#endif