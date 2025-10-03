#if not BC17
codeunit 6184808 "NPR Spfy Create Order" implements "NPR Nc Import List IProcess"
{
    Access = Internal;

    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";

    procedure RunProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        Order: JsonToken;
        AnonymizedCustomerOrderErr: Label 'The order is for an anonymous customer and has therefore been skipped.';
    begin
        ImportEntry.Find();
        ImportEntry.TestField("Store Code");
        OrderMgt.LoadOrder(ImportEntry, Order);
        if OrderMgt.IsAnonymizedCustomerOrder(ImportEntry, Order, AnonymizedCustomerOrderErr) then
            exit;
        ImportOrder(ImportEntry."Store Code", Order);
        ClearLastError();  //Do not save error text in Import List, if order processing completed successfully
    end;

    local procedure ImportOrder(ShopifyStoreCode: Code[20]; Order: JsonToken)
    var
        SalesHeader: Record "Sales Header";
    begin
        if OrderMgt.OrderExists(ShopifyStoreCode, Order) then
            exit;

        if OrderMgt.SkipOrderImport(ShopifyStoreCode, Order) then
            exit;

        OrderMgt.LockTables();
        OrderMgt.InsertSalesHeader(ShopifyStoreCode, Order, SalesHeader);
        OrderMgt.UpsertSalesLines(ShopifyStoreCode, Order, SalesHeader, false);
        OrderMgt.InsertPaymentLines(ShopifyStoreCode, Order, SalesHeader);

        if not OrderMgt.PostOrder(SalesHeader) then begin
            OrderMgt.SetMaxQtyToShipAndInvoice(SalesHeader);
            ReleaseOrder(SalesHeader);
        end;
    end;

    local procedure ReleaseOrder(var SalesHeader: Record "Sales Header")
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
    begin
        if not SalesHeader.Find() then
            exit;  //Wasn't created or has already been posted (deleted)
        Clear(NpEcStore);
        NpEcDocument.SetCurrentKey("Document Type", "Document No.");
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Order");
        NpEcDocument.SetRange("Document No.", SalesHeader."No.");
        if NpEcDocument.FindFirst() then
            if NpEcStore.Get(NpEcDocument."Store Code") then;

        if NpEcStore."Release Order on Import" then begin
            Commit();
            SalesHeader.SetHideValidationDialog(true);
            if Codeunit.Run(Codeunit::"Release Sales Document", SalesHeader) then;  //no errors during the release process should result in a failed import
        end;
    end;
}
#endif