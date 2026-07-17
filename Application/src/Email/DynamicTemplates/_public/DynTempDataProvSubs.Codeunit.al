codeunit 6248568 "NPR DynTempDataProvSubs"
{
    [IntegrationEvent(false, false)]
    procedure OnAfterMemberGetContent(var MemberNotificationEntryBuffer: Record "NPR MMMemberNotificEntryBuf"; var CustomJObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterMemberGenerateContentExample(var CustomJObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCGetContent(var NpCsDocument: Record "NPR NpCs Document"; var CustomJObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCGenerateContentExample(var CustomJObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCAddHeaderFields(var NpCsDocument: Record "NPR NpCs Document"; var JObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCAddHeaderFieldsExample(var JObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCAddCustomerCardFields(var NpCsDocument: Record "NPR NpCs Document"; var Customer: Record Customer; var JObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCAddCustomerCardFieldsExample(var JObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCAddSalesDocumentHeaderFields(var NpCsDocument: Record "NPR NpCs Document"; var JObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCAddSalesDocumentHeaderFieldsExample(var JObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCAddTotals(var NpCsDocument: Record "NPR NpCs Document"; var JObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCAddTotalsExample(var JObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCAddSalesLine(var SalesLine: Record "Sales Line"; var JObjectLine: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCAddSalesInvoiceLine(var SalesInvoiceLine: Record "Sales Invoice Line"; var JObjectLine: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCAddSalesCrMemoLine(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var JObjectLine: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCnCAddDocumentLineExample(var JObjectLine: JsonObject)
    begin
    end;
}