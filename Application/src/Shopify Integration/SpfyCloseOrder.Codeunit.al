#if not BC17
codeunit 6184807 "NPR Spfy Close Order"
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        Rec.TestField("Table No.", Rec."Record ID".TableNo);
        case Rec."Table No." of
            Database::"Sales Invoice Header":
                begin
                    CloseShopifyOrder(Rec);
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnRunOnBeforeFinalizePosting', '', true, false)]
    local procedure ScheduleCloseShopifyOrder(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        NcTask: Record "NPR Nc Task";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        SpfyOrderId: Text[30];
    begin
        if not SalesHeader.Invoice then
            exit;
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Close Order Requests") then
            exit;

        NcTask."Store Code" :=
            CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(SalesInvoiceHeader.RecordId(), "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));
        if NcTask."Store Code" = '' then begin
            NcTask."Store Code" := GetShopifyStore(SalesInvoiceHeader."Currency Code");
            if NcTask."Store Code" <> '' then
                SpfyAssignedIDMgt.AssignShopifyID(SalesInvoiceHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", NcTask."Store Code", false);
        end;

        if not SpfyIntegrationMgt.ShopifyStoreIsEnabled(NcTask."Store Code") then
            exit;

        SpfyOrderId := SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if SpfyOrderId = '' then
            exit;

        case true of
            SalesInvoiceHeader."No." <> '':
                RecRef.GetTable(SalesInvoiceHeader);
            else
                exit;
        end;

        SpfyScheduleSend.InitNcTask(NcTask."Store Code", RecRef, SpfyOrderId, NcTask.Type::Insert, NcTask);
    end;

    local procedure CloseShopifyOrder(var NcTask: Record "NPR Nc Task")
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        Success := false;
        Success := SpfyCommunicationHandler.SendCloseOrderRequest(NcTask);

        NcTask.Modify();
        Commit();
        if not Success then
            Error(GetLastErrorText);
    end;

    local procedure GetShopifyStore(CurrencyCode: Code[10]): Code[20]
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        ShopifyStore.SetRange("Currency Code", CurrencyCode);
        ShopifyStore.SetRange(Enabled, true);
        if ShopifyStore.IsEmpty() then
            ShopifyStore.SetRange(Enabled);
        if not ShopifyStore.FindFirst() then
            exit('');

        exit(ShopifyStore.Code);
    end;
}
#endif