codeunit 6151042 "NPR Payment Processing Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAddPreWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; SalePOS: Record "NPR POS Sale"; var PreWorkflows: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCalculateSuggestionPaymentAmount(SalesTicketNo: Code[20]; SalesAmount: Decimal; PaidAmount: Decimal; POSPaymentMethod: Record "NPR POS Payment Method"; ReturnPOSPaymentMethod: Record "NPR POS Payment Method"; var SuggestPaymentAmount: Decimal; var CollectReturnInformation: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAddAmountPromptLblToResponse(POSPaymentMethod: Record "NPR POS Payment Method";var TextAmountLabel: Text)
    begin
    end;
}