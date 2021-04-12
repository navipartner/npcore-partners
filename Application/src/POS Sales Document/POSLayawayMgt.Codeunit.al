codeunit 6014425 "NPR POS Layaway Mgt."
{
    TableNo = "Sales Header";

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        NotInitialized: Label 'Codeunit 6014425 wasn''t initialized properly. This is a programming bug, not a user error. Please contact system vendor.';
    begin
        SalesHeader := Rec;
        case FunctionToRun of
            FunctionToRun::ApplyPrepmtCreditMemoAndRefund:
                ApplyPrepmtCreditMemoAndRefund(SalesHeader);
            FunctionToRun::CreateAndPostDownpmtAndLayawayInvoices:
                CreateAndPostDownpmtAndLayawayInvoices(SalesHeader);
            FunctionToRun::HandleDownpayment:
                HandleDownpayment();
            else
                Error(NotInitialized);
        end;
        Rec := SalesHeader;
    end;

    var
        POSSession: Codeunit "NPR POS Session";
        FunctionToRun: Option " ",ApplyPrepmtCreditMemoAndRefund,CreateAndPostDownpmtAndLayawayInvoices,HandleDownpayment;
        Instalments: Integer;
        DownpaymentPct: Decimal;
        CreditMemoNo: Text;
        DownpaymentInvoiceNo: Text;
        PrepaymentPaymentTerms: Text;
        ServiceInvoiceNo: Text;

    procedure SetRunApplyPrepmtCreditMemoAndRefund(POSSessionIn: Codeunit "NPR POS Session"; CreditMemoNoIn: Text; ServiceInvoiceNoIn: Text)
    begin
        FunctionToRun := FunctionToRun::ApplyPrepmtCreditMemoAndRefund;
        POSSession := POSSessionIn;
        CreditMemoNo := CreditMemoNoIn;
        ServiceInvoiceNo := ServiceInvoiceNoIn;
    end;

    procedure SetRunCreateAndPostDownpmtAndLayawayInvoices(DownpaymentPctIn: Decimal; PrepaymentPaymentTermsIn: Text; InstalmentsIn: Integer)
    begin
        FunctionToRun := FunctionToRun::CreateAndPostDownpmtAndLayawayInvoices;
        DownpaymentPct := DownpaymentPctIn;
        Instalments := InstalmentsIn;
        PrepaymentPaymentTerms := PrepaymentPaymentTermsIn;
    end;

    procedure GetDownpaymentInvoiceNo(): Text
    begin
        exit(DownpaymentInvoiceNo);
    end;

    procedure SetRunHandleDownpayment(POSSessionIn: Codeunit "NPR POS Session"; DownpaymentInvoiceNoIn: Text)
    begin
        FunctionToRun := FunctionToRun::HandleDownpayment;
        POSSession := POSSessionIn;
        DownpaymentInvoiceNo := DownpaymentInvoiceNoIn;
    end;

    local procedure ApplyPrepmtCreditMemoAndRefund(var SalesHeader: Record "Sales Header")
    var
        POSRefundAmount: Decimal;
        LAYAWAY_CANCEL_REFUND: Label 'Layaway order credited and deleted.\Refund line has been created for total paid amount minus fees.';
        LAYAWAY_CANCEL: Label 'Layaway order credited and deleted';
    begin
        ApplyPrepaymentCreditMemoToOpenPrepaymentInvoices(CreditMemoNo, SalesHeader); //COMMITS
        ApplyPrepaymentCreditMemoToServiceInvoice(CreditMemoNo, ServiceInvoiceNo); //COMMITS
        POSRefundAmount := CreatePOSRefundForRemainingCreditMemoAmount(POSSession, CreditMemoNo);

        if POSRefundAmount <> 0 then
            Message(LAYAWAY_CANCEL_REFUND)
        else
            Message(LAYAWAY_CANCEL);
    end;

    local procedure CreateAndPostDownpmtAndLayawayInvoices(var SalesHeader: Record "Sales Header")
    begin
        DownpaymentInvoiceNo := CreateAndPostDownpaymentInvoice(SalesHeader, DownpaymentPct, PrepaymentPaymentTerms);
        CreateAndPostLayawayInvoices(SalesHeader, Instalments, PrepaymentPaymentTerms, DownpaymentPct);
    end;

    local procedure HandleDownpayment()
    var
        POSApplyCustomerEntries: Codeunit "NPR POS Apply Customer Entries";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        POSApplyCustomerEntries.BalanceDocument(POSSession, CustLedgerEntry."Document Type"::Invoice, DownpaymentInvoiceNo, true);
    end;

    local procedure ApplyPrepaymentCreditMemoToOpenPrepaymentInvoices(CreditMemoNo: Text; var SalesHeader: Record "Sales Header")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InvoiceFilterString: Text;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CreditMemoCustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if not SalesCrMemoHeader.Get(CreditMemoNo) then
            exit;

        CreditMemoCustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        CreditMemoCustLedgerEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        CreditMemoCustLedgerEntry.SetRange("Document Type", CreditMemoCustLedgerEntry."Document Type"::"Credit Memo");
        CreditMemoCustLedgerEntry.SetRange("Document No.", CreditMemoNo);
        CreditMemoCustLedgerEntry.FindFirst();
        CreditMemoCustLedgerEntry.TestField(Open);

        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        if not SalesInvoiceHeader.FindSet() then
            exit;

        repeat
            if InvoiceFilterString <> '' then
                InvoiceFilterString += '|';
            InvoiceFilterString += '''' + SalesInvoiceHeader."No." + '''';
        until SalesInvoiceHeader.Next() = 0;

        CustLedgerEntry.SetRange("Applies-to ID", UserId);
        if not CustLedgerEntry.IsEmpty then
            CustLedgerEntry.ModifyAll("Applies-to ID", '', true);
        CustLedgerEntry.Reset();

        CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        CustLedgerEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange(Positive, true);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetFilter("Document No.", InvoiceFilterString);

        ApplyCustomerEntry(CreditMemoCustLedgerEntry, CustLedgerEntry);
    end;

    local procedure ApplyPrepaymentCreditMemoToServiceInvoice(CreditMemoNo: Text; ServiceInvoiceNo: Text)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CreditMemoCustLedgerEntry: Record "Cust. Ledger Entry";
        InvoiceCustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if not SalesCrMemoHeader.Get(CreditMemoNo) then
            exit;
        if not SalesInvoiceHeader.Get(ServiceInvoiceNo) then
            exit;

        CreditMemoCustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        CreditMemoCustLedgerEntry.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
        CreditMemoCustLedgerEntry.SetRange("Document Type", CreditMemoCustLedgerEntry."Document Type"::"Credit Memo");
        CreditMemoCustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CreditMemoCustLedgerEntry.FindFirst();
        if not CreditMemoCustLedgerEntry.Open then
            exit;
        if CreditMemoCustLedgerEntry."Remaining Amount" = 0 then
            exit;

        InvoiceCustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        InvoiceCustLedgerEntry.SetRange("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
        InvoiceCustLedgerEntry.SetRange("Document Type", InvoiceCustLedgerEntry."Document Type"::Invoice);
        InvoiceCustLedgerEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        InvoiceCustLedgerEntry.FindFirst();
        if not InvoiceCustLedgerEntry.Open then
            exit;
        if InvoiceCustLedgerEntry."Remaining Amount" = 0 then
            exit;

        CustLedgerEntry.SetRange("Applies-to ID", UserId);
        if not CustLedgerEntry.IsEmpty then
            CustLedgerEntry.ModifyAll("Applies-to ID", '', true);

        ApplyCustomerEntry(CreditMemoCustLedgerEntry, InvoiceCustLedgerEntry);
    end;

    local procedure CreatePOSRefundForRemainingCreditMemoAmount(var POSSession: Codeunit "NPR POS Session"; CreditMemoNo: Text): Decimal
    var
        CreditMemoCustLedgerEntry: Record "Cust. Ledger Entry";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        LAYAWAY_REFUND: Label 'Layaway Refund';
    begin
        if not SalesCrMemoHeader.Get(CreditMemoNo) then
            exit(0);

        CreditMemoCustLedgerEntry.SetAutoCalcFields("Remaining Amt. (LCY)");
        CreditMemoCustLedgerEntry.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
        CreditMemoCustLedgerEntry.SetRange("Document Type", CreditMemoCustLedgerEntry."Document Type"::"Credit Memo");
        CreditMemoCustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CreditMemoCustLedgerEntry.FindFirst();
        if CreditMemoCustLedgerEntry."Remaining Amt. (LCY)" = 0 then
            exit(0);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
        SaleLinePOS.Type := SaleLinePOS.Type::Customer;
        SaleLinePOS.Validate("No.", CreditMemoCustLedgerEntry."Customer No.");
        SaleLinePOS.Validate("Unit Price", CreditMemoCustLedgerEntry."Remaining Amt. (LCY)");
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS."Buffer Document Type" := SaleLinePOS."Buffer Document Type"::"Credit Memo";
        SaleLinePOS."Buffer Document No." := SalesCrMemoHeader."No.";
        SaleLinePOS.Description := LAYAWAY_REFUND;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);

        exit(CreditMemoCustLedgerEntry."Remaining Amt. (LCY)");
    end;

    local procedure ApplyCustomerEntry(var ApplyingCustLedgerEntry: Record "Cust. Ledger Entry"; var ApplyToCustLedgerEntries: Record "Cust. Ledger Entry")
    begin
        if not ApplyToCustLedgerEntries.FindSet(true) then
            exit;
        repeat
            ApplyToCustLedgerEntries.Validate("Applies-to ID", UserId);
            ApplyToCustLedgerEntries.Validate("Amount to Apply", ApplyToCustLedgerEntries."Remaining Amount");
            ApplyToCustLedgerEntries.Modify(true);
        until ApplyToCustLedgerEntries.Next() = 0;

        ApplyingCustLedgerEntry.Validate("Applying Entry", true);
        ApplyingCustLedgerEntry.Validate("Applies-to ID", UserId);
        ApplyingCustLedgerEntry.Validate("Amount to Apply", ApplyingCustLedgerEntry."Remaining Amount");
        CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", ApplyingCustLedgerEntry);
        Commit();

        CODEUNIT.Run(CODEUNIT::"CustEntry-Apply Posted Entries", ApplyingCustLedgerEntry);
    end;

    local procedure CreateAndPostDownpaymentInvoice(var SalesHeader: Record "Sales Header"; DownpaymentPct: Decimal; PrepaymentPaymentTerms: Text): Text
    var
        SalesLine: Record "Sales Line";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
    begin
        SalesHeader.Validate("Prepayment %", 0);
        SalesHeader.Validate("Prepmt. Payment Terms Code", PrepaymentPaymentTerms);
        SalesHeader.Validate("Prepayment Due Date", WorkDate());
        SalesHeader.Modify(true);

        if DownpaymentPct <= 0 then
            exit('');

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("No.", '<>%1', '');

        if not SalesLine.FindSet(true) then
            exit('');

        repeat
            SalesLine.Validate("Prepayment %", DownpaymentPct);
            SalesLine.Modify(true);
        until SalesLine.Next() = 0;

        SalesPostPrepayments.Invoice(SalesHeader);
        SalesHeader.Validate(Status, SalesHeader.Status::Open);
        SalesHeader.Modify(true);
        exit(SalesHeader."Last Prepayment No.");
    end;

    local procedure CreateAndPostLayawayInvoices(var SalesHeader: Record "Sales Header"; Instalments: Integer; PrepaymentPaymentTerms: Text; DownpaymentPct: Decimal)
    var
        InstalmentPct: Decimal;
        i: Integer;
        PaymentTerms: Record "Payment Terms";
    begin
        //Split the remaining amount out over X prepayment invoices ie. calculate the percentage.
        //Set the remaining amount on the last instalment so any rounding diff is put onto this one.
        SalesHeader.Validate("Prepmt. Payment Terms Code", PrepaymentPaymentTerms);
        SalesHeader.Modify(true);

        InstalmentPct := (100 - DownpaymentPct) / Instalments;
        PaymentTerms.Get(PrepaymentPaymentTerms);

        for i := 1 to Instalments do begin
            if i > 1 then begin
                SalesHeader.Validate("Prepayment Due Date", CalcDate(PaymentTerms."Due Date Calculation", SalesHeader."Prepayment Due Date"));
                SalesHeader.Modify(true);
            end;
            AppendPrepaymentPctAndPostPrepaymentInvoice(SalesHeader, InstalmentPct, (i = Instalments));
        end;
    end;

    local procedure AppendPrepaymentPctAndPostPrepaymentInvoice(SalesHeader: Record "Sales Header"; PrepaymentPct: Decimal; FullPrepayment: Boolean): Text
    var
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        SalesLine: Record "Sales Line";
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
    begin
        if FullPrepayment then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            SalesLine.SetFilter("No.", '<>%1', '');
            if SalesLine.FindSet(true) then
                repeat
                    SalesLine.Validate("Prepayment %", 100);
                    SalesLine.Modify(true);
                until SalesLine.Next() = 0;
        end else
            POSPrepaymentMgt.SetPrepaymentPercentageToPay(SalesHeader, true, PrepaymentPct);

        SalesPostPrepayments.Invoice(SalesHeader);

        if not FullPrepayment then begin
            SalesHeader.Validate(Status, SalesHeader.Status::Open);
            SalesHeader.Modify(true);
        end;

        exit(SalesHeader."Last Prepayment No.");
    end;
}