codeunit 6059924 "NPR NpCs POS Action Events"
{
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetUnprocessedFilter(LocationFilter: Text; var NpCsDocument: Record "NPR NpCs Document"; var IsHandeled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetProcessedFilter(LocationFilter: Text; var NpCsDocument: Record "NPR NpCs Document"; var IsHandeled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetUnprocessedOrderQty(LocationFilter: Text; var UnprocessedOrderQty: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDeliverDocument(POSSession: Codeunit "NPR POS Session"; NpCsDocument: Record "NPR NpCs Document"; DeliverText: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnDeliverOrderFilterSalesLine(NpCsDocument: Record "NPR NpCs Document"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSelectToStore(var TempNpCsStore: Record "NPR NpCs Store" temporary; FromStoreCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSelectCustomer(var CustomerNo: Code[20]; WorkflowCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure CreateOrderOnAfterGetCreatedSalesHeader(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInitSendToStoreDocument(SalesHeader: Record "Sales Header"; NpCsStore: Record "NPR NpCs Store"; NpCsWorkflow: Record "NPR NpCs Workflow"; var NpCsDocument: Record "NPR NpCs Document")
    begin

    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCreateCollectOrderBeforeScheduleRunWorkflow(NpCsDocument: Record "NPR NpCs Document")
    begin
    end;

}
