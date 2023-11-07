codeunit 6059978 "NPR POS Action: Cust.Deposit B"
{
    Access = Internal;

    procedure CreateDeposit(DepositType: Option ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance,CrMemoNoPrompt;
                            CustomerEntryView: Text;
                            POSSale: Codeunit "NPR POS Sale";
                            POSSaleLine: Codeunit "NPR POS Sale Line";
                            PromptValue: Code[20];
                            PromptAmt: Decimal;
                            CopyDesc: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);

        case DepositType of
            DepositType::ApplyCustomerEntries:
                ApplyCustomerEntries(CustomerEntryView, POSSale, CopyDesc);
            DepositType::InvoiceNoPrompt:
                DocumentNoPrompt(PromptValue, CopyDesc);
            DepositType::MatchCustomerBalance:
                MatchCustomerBalance(POSSale, POSSaleLine, CopyDesc);
            DepositType::AmountPrompt:
                AmountPrompt(POSSale, POSSaleLine, PromptAmt, CopyDesc);
            DepositType::CrMemoNoPrompt:
                CrMemoNoPrompt(PromptValue, CopyDesc);
        end;
    end;

    local procedure AmountPrompt(POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line"; Amount: Decimal; CopyDesc: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
    begin
        SelectCustomer(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");

        InsertDepositLine(POSSaleLine, SalePOS, Amount, CopyDesc);
    end;

    local procedure ApplyCustomerEntries(CustomerEntryView: Text; POSSale: Codeunit "NPR POS Sale"; CopyDesc: Boolean)
    var
        POSApplyCustomerEntries: Codeunit "NPR POS Apply Customer Entries";
        POSSession: Codeunit "NPR POS Session";
    begin
        SelectCustomer(POSSale);
        POSApplyCustomerEntries.SelectCustomerEntries(POSSession, CustomerEntryView, CopyDesc);
    end;

    local procedure DocumentNoPrompt(InvoiceNo: Code[20]; CopyDesc: Boolean)
    var
        POSApplyCustomerEntries: Codeunit "NPR POS Apply Customer Entries";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        POSSession: Codeunit "NPR POS Session";
    begin
        if (InvoiceNo = '') then
            exit;

        POSApplyCustomerEntries.BalanceDocument(POSSession, CustLedgerEntry."Document Type"::Invoice, InvoiceNo, false, CopyDesc);
    end;

    local procedure CrMemoNoPrompt(CrMemoNo: Code[20]; CopyDesc: Boolean)
    var
        POSApplyCustomerEntries: Codeunit "NPR POS Apply Customer Entries";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        POSSession: Codeunit "NPR POS Session";
    begin
        if (CrMemoNo = '') then
            exit;

        POSApplyCustomerEntries.BalanceDocument(POSSession, CustLedgerEntry."Document Type"::"Credit Memo", CrMemoNo, false, CopyDesc);
    end;

    local procedure MatchCustomerBalance(POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line"; CopyDesc: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
    begin
        SelectCustomer(POSSale);

        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");

        Customer.SetAutoCalcFields("Balance (LCY)");
        Customer.Get(SalePOS."Customer No.");
        Customer.TestField("Balance (LCY)");

        InsertDepositLine(POSSaleLine, SalePOS, Customer."Balance (LCY)", CopyDesc);
    end;

    local procedure InsertDepositLine(var POSSaleLine: Codeunit "NPR POS Sale Line"; SalePOS: Record "NPR POS Sale"; Amount: Decimal; CopyDesc: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TextDeposit: Label 'Deposit from: %1';
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::"Customer Deposit";
        SaleLinePOS.Validate("No.", SalePOS."Customer No.");
        SaleLinePOS.Quantity := 1;
        SaleLinePOS.Amount := Amount;
        SaleLinePOS."Amount Including VAT" := Amount;
        SaleLinePOS."Unit Price" := Amount;
        SaleLinePOS.Description := StrSubstNo(TextDeposit, SalePOS.Name);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        SaleLinePOS."Copy Description" := CopyDesc;
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    procedure SetNewDesc(NewDesc: Text[100]; SaleLine: Codeunit "NPR POS Sale Line"; CopyNewDesc: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.Description := NewDesc;
        SaleLinePOS."Copy Description" := CopyNewDesc;
        SaleLinePOS.Modify();
    end;

    local procedure SelectCustomer(POSSale: Codeunit "NPR POS Sale"): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
    begin
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then
            exit(true);

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
            exit(false);

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit();
        exit(true);
    end;

}