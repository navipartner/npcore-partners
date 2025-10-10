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
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
        NpCsStore: Record "NPR NpCs Store";
        NpCsWorkflow: Record "NPR NpCs Workflow";
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if OrderMgt.OrderExists(ShopifyStoreCode, Order) then
            exit;

        if OrderMgt.SkipOrderImport(ShopifyStoreCode, Order) then
            exit;

        OrderMgt.LockTables();
        OrderMgt.InsertSalesHeader(ShopifyStoreCode, Order, SalesHeader);
        OrderMgt.UpsertSalesLines(ShopifyStoreCode, Order, SalesHeader, false);
        OrderMgt.InsertPaymentLines(ShopifyStoreCode, Order, SalesHeader);

        if CheckIfClickCollectOrder(ShopifyStoreCode, SalesHeader, NpCsStore, NpCsWorkflow) then begin
            NpCsCollectMgt.InitSendToStoreDocument(SalesHeader, NpCsStore, NpCsWorkflow, NpCsDocument);
            UpdateNotificationsAndRunWorkflow(SalesHeader, NpCsDocument);
        end;

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

    local procedure CheckIfClickCollectOrder(ShopifyStoreCode: Code[20]; SalesHeader: Record "Sales Header"; var NpCsStore: Record "NPR NpCs Store"; var NpCsWorkflow: Record "NPR NpCs Workflow"): Boolean
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        if SalesHeader."NPR Spfy Collect Store" = '' then
            exit(false);
        if not NpCsStore.Get(SalesHeader."NPR Spfy Collect Store") then
            exit(false);

        ShopifyStore.Get(ShopifyStoreCode);
        ShopifyStore.TestField("Spfy C&C Order Workflow Code");
        NpCsWorkflow.Get(ShopifyStore."Spfy C&C Order Workflow Code");

        exit(true);
    end;

    local procedure UpdateNotificationsAndRunWorkflow(SalesHeader: Record "Sales Header"; var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        PaymentLines: Record "NPR Magento Payment Line";
    begin
        NpCsDocument."Customer No." := SalesHeader."Sell-to Customer No.";
        NpCsDocument."Salesperson Code" := SalesHeader."Salesperson Code";
        NpCsDocument."From Store Code" := NpCsDocument."To Store Code";
        NpCsDocument."To Document Type" := NpCsDocument."To Document Type"::Order;
        NpCsDocument."Customer E-mail" := SalesHeader."NPR Bill-to E-mail";
        NpCsDocument."Notify Customer via E-mail" := NpCsDocument."Customer E-mail" <> '';
        NpCsDocument."Customer Phone No." := SalesHeader."NPR Bill-to Phone No.";
        NpCsDocument."Notify Customer via Sms" := SalesHeader."NPR Bill-to Phone No." <> '';
        if not NpCsDocument."Notify Customer via Sms" then
            NpCsDocument."Notify Customer via E-mail" := true;

        PaymentLines.SetRange("Document No.", SalesHeader."No.");
        PaymentLines.SetRange("Document Type", PaymentLines."Document Type"::Order);
        PaymentLines.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLines.CalcSums(Amount);
        NpCsDocument."Prepaid Amount" := PaymentLines.Amount;
        NpCsDocument.Modify(true);

        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
    end;
}
#endif