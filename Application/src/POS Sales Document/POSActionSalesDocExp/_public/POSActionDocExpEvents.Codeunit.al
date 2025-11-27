codeunit 6151367 "NPR POS Action Doc Exp Events"
{
    [IntegrationEvent(false, false)]
    internal procedure OnAddPreWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; SalePOS: Record "NPR POS Sale"; var PreWorkflows: JsonObject; PaymentParameters: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAddExternalDocNoLabel(var ExternalDocumentNoText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAddAttentionLabel(var AttentionText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetDocumentTypeFromBalanceAmount(Context: Codeunit "NPR POS JSON Helper"; var BalanceInclVAT: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeHandlePrepayment(SalesHeader: Record "Sales Header"; PrepaymentValue: Decimal; PrepaymentIsAmount: Boolean; var Print: Boolean; var Send: Boolean; var Pdf2Nav: Boolean; var SalePosting: Enum "NPR POS Sales Document Post"; PrepaymentManualLineControl: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeHandlePayAndPost(SalesHeader: Record "Sales Header"; var Print: Boolean; var Pdf2Nav: Boolean; var Send: Boolean; FullPosting: Boolean; var SalePosting: Enum "NPR POS Sales Document Post")
    begin
    end;

}