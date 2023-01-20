codeunit 6059978 "NPR POS Action: Cust.Deposit B"
{
    Access = Internal;

    procedure CreateDeposit(DepositType: Option ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance,CrMemoNoPrompt;
                            CustomerEntryView: Text;
                            POSSale: Codeunit "NPR POS Sale";
                            POSSaleLine: Codeunit "NPR POS Sale Line";
                            PromptValue: Text;
                            PromptAmt: Decimal)
    var
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);

        case DepositType of
            DepositType::ApplyCustomerEntries:
                ApplyCustomerEntries(CustomerEntryView, POSSale);
            DepositType::InvoiceNoPrompt:
                DocumentNoPrompt(PromptValue);
            DepositType::MatchCustomerBalance:
                MatchCustomerBalance(POSSale, POSSaleLine);
            DepositType::AmountPrompt:
                AmountPrompt(POSSale, POSSaleLine, PromptAmt);
            DepositType::CrMemoNoPrompt:
                CrMemoNoPrompt(PromptValue);
        end;
    end;

    local procedure AmountPrompt(POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line"; Amount: Decimal)
    var
        SalePOS: Record "NPR POS Sale";
    begin
        SelectCustomer(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");
        SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);

        InsertDepositLine(POSSaleLine, SalePOS, Amount);
    end;

    local procedure ApplyCustomerEntries(CustomerEntryView: Text; POSSale: Codeunit "NPR POS Sale")
    var
        POSApplyCustomerEntries: Codeunit "NPR POS Apply Customer Entries";
        POSSession: Codeunit "NPR POS Session";
    begin
        SelectCustomer(POSSale);
        POSApplyCustomerEntries.SelectCustomerEntries(POSSession, CustomerEntryView);
    end;

    local procedure DocumentNoPrompt(InvoiceNo: Code[20])
    var
        POSApplyCustomerEntries: Codeunit "NPR POS Apply Customer Entries";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        POSSession: Codeunit "NPR POS Session";
    begin
        if (InvoiceNo = '') then
            exit;

        POSApplyCustomerEntries.BalanceDocument(POSSession, CustLedgerEntry."Document Type"::Invoice, InvoiceNo, false);
    end;

    local procedure CrMemoNoPrompt(CrMemoNo: Code[20])
    var
        POSApplyCustomerEntries: Codeunit "NPR POS Apply Customer Entries";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        POSSession: Codeunit "NPR POS Session";
    begin
        if (CrMemoNo = '') then
            exit;

        POSApplyCustomerEntries.BalanceDocument(POSSession, CustLedgerEntry."Document Type"::"Credit Memo", CrMemoNo, false);
    end;

    local procedure MatchCustomerBalance(POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
    begin
        SelectCustomer(POSSale);

        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");
        SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);

        Customer.SetAutoCalcFields("Balance (LCY)");
        Customer.Get(SalePOS."Customer No.");
        Customer.TestField("Balance (LCY)");

        InsertDepositLine(POSSaleLine, SalePOS, Customer."Balance (LCY)");
    end;

    local procedure InsertDepositLine(var POSSaleLine: Codeunit "NPR POS Sale Line"; SalePOS: Record "NPR POS Sale"; Amount: Decimal)
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
        if SalePOS."Customer No." <> '' then begin
            SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
            exit(true);
        end;

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
            exit(false);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit();
        exit(true);
    end;

}