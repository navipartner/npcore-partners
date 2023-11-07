codeunit 6151068 "NPR POS Action Publishers"
{
    //Use this codeunit for POS Action Events and Public Access
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetItemFromItemSearch(var ItemIdentifierString: Text; var ItemFound: Boolean; var Handled: Boolean)
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
}