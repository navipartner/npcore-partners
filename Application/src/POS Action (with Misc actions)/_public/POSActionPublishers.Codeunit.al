codeunit 6151068 "NPR POS Action Publishers"
{
    //Use this codeunit for POS Action Events and Public Access
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetItemFromItemSearch(var ItemIdentifierString: Text; var ItemFound: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeAddCustomertoSales(SaleHeader: Record "NPR POS Sale"; Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeInsertSaleLinePOSXml2POSSale(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;


    #region CUSTOMER_DEPOSIT
    procedure CreateCustomerDeposit(DepositType: Option ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance,CrMemoNoPrompt;
                            CustomerEntryView: Text;
                            POSSale: Codeunit "NPR POS Sale";
                            POSSaleLine: Codeunit "NPR POS Sale Line";
                            PromptValue: Code[20];
                            PromptAmt: Decimal;
                            CopyDesc: Boolean)
    var
        POSActionCustDepositB: Codeunit "NPR POS Action: Cust.Deposit B";
    begin
        POSActionCustDepositB.CreateDeposit(DepositType, CustomerEntryView, POSSale, POSSaleLine, PromptValue, PromptAmt, CopyDesc);
    end;

    procedure SetNewDescriptionCustomerDeposit(NewDesciption: Text[100]; SaleLine: Codeunit "NPR POS Sale Line"; CopyNewDesc: Boolean)
    var
        POSActionCustDepositB: Codeunit "NPR POS Action: Cust.Deposit B";
    begin
        POSActionCustDepositB.SetNewDesc(NewDesciption, SaleLine, CopyNewDesc);
    end;
    #endregion

    #region BIN_TRANSFER
    [IntegrationEvent(false, false)]
    internal procedure OnAddPostWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; SalePOS: Record "NPR POS Sale"; var PostWorkflows: JsonObject)
    begin
    end;
    #endregion

    #region QUANTITY
    [IntegrationEvent(false, false)]
    internal procedure OnAddPostWorkflowsToRunOnQuantity(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line"; var PostWorkflows: JsonObject)
    begin
    end;
    #endregion

    #region DELETE_POS_LINE
    [IntegrationEvent(false, false)]
    internal procedure OnAddPreWorkflowsToRunOnDeletePOSLine(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; POSSession: Codeunit "NPR POS Session"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; var PreWorkflows: JsonObject)
    begin
    end;
    #endregion

    #region CHANGE_VIEW
    [IntegrationEvent(false, false)]
    internal procedure OnAddPostWorkflowsToRunOnChangeView(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; var PostWorkflows: JsonObject)
    begin
    end;
    #endregion

    #region DISCOUNT
    [IntegrationEvent(false, false)]
    internal procedure OnAddPostWorkflowsToRunOnDiscount(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; var PostWorkflows: JsonObject)
    begin
    end;
    #endregion
}