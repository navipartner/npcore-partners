codeunit 6060020 "NPR POS Action: Layaway Pay-B"
{
    Access = Internal;
    procedure PayLayaway(var POSSession: Codeunit "NPR POS Session"; OrderPaymentTermsFilter: Text; SelectionMethod: Integer; SelectCustomer: Boolean; ConfirmInvDiscAmt: Boolean; POSSalesDocumentPost: Enum "NPR POS Sales Document Post")
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        POSApplyCustomerEntries: Codeunit "NPR POS Apply Customer Entries";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if not CheckCustomer(POSSession, SelectCustomer) then
            exit;

        if not SelectOrder(POSSession, SalesHeader, OrderPaymentTermsFilter) then
            exit;

        if not ConfirmImportInvDiscAmt(SalesHeader, ConfirmInvDiscAmt) then
            exit;

        CheckForUnpostedLinkedPOSEntries(SalesHeader);

        if not SelectPrepaymentInvoice(SalesHeader, SalesInvoiceHeader, SelectionMethod) then
            exit;

        POSApplyCustomerEntries.BalanceDocument(POSSession, CustLedgerEntry."Document Type"::Invoice, SalesInvoiceHeader."No.", true, false);
        InsertCompletionLine(POSSession, SalesHeader, SalesInvoiceHeader, POSSalesDocumentPost);
        CreateLayawayComments(POSSession, SalesHeader, SelectionMethod, SalesInvoiceHeader);
    end;

    local procedure CheckCustomer(POSSession: Codeunit "NPR POS Session"; SelectCustomer: Boolean): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then
            exit(true);

        if not SelectCustomer then
            exit(true);

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
            exit(false);

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit();
        exit(true);
    end;

    local procedure SelectOrder(POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"; OrderPaymentTermsFilter: Text): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if OrderPaymentTermsFilter <> '' then
            SalesHeader.SetRange("Payment Terms Code", OrderPaymentTermsFilter);
        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        exit(RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GetView(false), SalesHeader));
    end;

    local procedure ConfirmImportInvDiscAmt(SalesHeader: Record "Sales Header"; ConfirmInvDiscAmt: Boolean): Boolean
    var
        SalesLine: Record "Sales Line";
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        if ConfirmInvDiscAmt then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetFilter("Inv. Discount Amount", '>%1', 0);
            SalesLine.CalcSums("Inv. Discount Amount");
            if SalesLine."Inv. Discount Amount" > 0 then begin
                if not Confirm(SalesDocImpMgt.GetImportInvDiscAmtQst()) then
                    exit;
            end;
        end;
        exit(true);
    end;

    local procedure SelectPrepaymentInvoice(SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; SelectionMethod: Integer): Boolean
    begin
        if SelectionMethod = 0 then begin
            GetNextDuePrepayment(SalesHeader, SalesInvoiceHeader, 0D, true);
            exit(true);
        end else begin
            SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
            SalesInvoiceHeader.FindSet();
            exit(PAGE.RunModal(PAGE::"NPR POS Prepaym. Invoices", SalesInvoiceHeader) = ACTION::LookupOK);
        end;
    end;

    local procedure CreateLayawayComments(var POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; SelectionMethod: Integer; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NextInvoice: Record "Sales Invoice Header";
        LAYAWAY_REMAINING: Label 'Layaway Remaining Total: %1';
        LAYAWAY_NEXT_DATE: Label 'Layaway Next Due Date: %1';
        LAYAWAY_NEXT_AMOUNT: Label 'Layaway Next Amount: %1';
        LAYAWAY_COMPLETED: Label 'Layaway Fully Paid';

    begin
        if SelectionMethod > 0 then
            exit;

        POSSession.GetSaleLine(POSSaleLine);

        if GetNextDuePrepayment(SalesHeader, NextInvoice, SalesInvoiceHeader."Due Date", false) then begin
            InsertCommentLine(POSSaleLine, StrSubstNo(LAYAWAY_NEXT_DATE, Format(NextInvoice."Due Date")));
            InsertCommentLine(POSSaleLine, StrSubstNo(LAYAWAY_NEXT_AMOUNT, Format(NextInvoice."Amount Including VAT", 0, '<Standard Format,0>')));
            InsertCommentLine(POSSaleLine, StrSubstNo(LAYAWAY_REMAINING, Format(GetTotalRemainingLayawayAmount(SalesHeader, SalesInvoiceHeader."Due Date"), 0, '<Standard Format,0>')));
        end else
            InsertCommentLine(POSSaleLine, LAYAWAY_COMPLETED);
    end;

    local procedure InsertCompletionLine(var POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; SalesInvoiceHeader: Record "Sales Invoice Header"; SalePostingIn: Enum "NPR POS Sales Document Post")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NextInvoice: Record "Sales Invoice Header";
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        if GetNextDuePrepayment(SalesHeader, NextInvoice, SalesInvoiceHeader."Due Date", false) then
            exit;

        RetailSalesDocImpMgt.SalesDocumentAmountToPOS(POSSession, SalesHeader, true, true, true, false, false, false, SalePostingIn);

    end;

    local procedure GetTotalRemainingLayawayAmount(SalesHeader: Record "Sales Header"; DueLaterThan: Date): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InvoiceFilterString: Text;
        Amount: Decimal;
    begin
        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        SalesInvoiceHeader.FindSet();
        repeat
            if InvoiceFilterString <> '' then
                InvoiceFilterString += '|';
            InvoiceFilterString += '''' + SalesInvoiceHeader."No." + '''';
        until SalesInvoiceHeader.Next() = 0;

        CustLedgerEntry.SetAutoCalcFields("Remaining Amt. (LCY)");
        CustLedgerEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange(Positive, true);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetFilter("Document No.", InvoiceFilterString);
        if DueLaterThan <> 0D then
            CustLedgerEntry.SetFilter("Due Date", '>%1', DueLaterThan);

        if CustLedgerEntry.FindSet() then
            repeat
                Amount += CustLedgerEntry."Remaining Amt. (LCY)";
            until CustLedgerEntry.Next() = 0;

        exit(Amount);
    end;

    local procedure GetNextDuePrepayment(SalesHeader: Record "Sales Header"; var SalesInvoiceHeaderOut: Record "Sales Invoice Header"; DueLaterThan: Date; WithError: Boolean): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InvoiceFilterString: Text;
    begin
        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        SalesInvoiceHeader.FindSet();
        repeat
            if InvoiceFilterString <> '' then
                InvoiceFilterString += '|';
            InvoiceFilterString += '''' + SalesInvoiceHeader."No." + '''';
        until SalesInvoiceHeader.Next() = 0;

        CustLedgerEntry.SetCurrentKey("Customer No.", Open, Positive, "Due Date", "Currency Code");
        CustLedgerEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange(Positive, true);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetFilter("Document No.", InvoiceFilterString);
        if DueLaterThan <> 0D then
            CustLedgerEntry.SetFilter("Due Date", '>%1', DueLaterThan);
        if WithError then
            CustLedgerEntry.FindFirst()
        else begin
            if not CustLedgerEntry.FindFirst() then
                exit(false);
        end;

        SalesInvoiceHeaderOut.SetAutoCalcFields("Amount Including VAT");
        exit(SalesInvoiceHeaderOut.Get(CustLedgerEntry."Document No."));
    end;

    local procedure InsertCommentLine(POSSaleLine: Codeunit "NPR POS Sale Line"; Description: Text)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Comment;
        SaleLinePOS.Description := CopyStr(Description, 1, MaxStrLen(SaleLinePOS.Description));
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    local procedure CheckForUnpostedLinkedPOSEntries(SalesHeader: Record "Sales Header")
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        POSEntry: Record "NPR POS Entry";
        ERR_UNPOSTED_POS_ENTRY: Label '%1 %2, %3 %4 is related to %5 %6 but has not yet been posted.\All related entries must be posted before new layaway payment.';
    begin
        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        if SalesInvoiceHeader.FindSet() then
            repeat
                POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE);
                POSEntrySalesDocLink.SetRange("Sales Document No", SalesInvoiceHeader."No.");
                if POSEntrySalesDocLink.FindSet() then
                    repeat
                        POSEntry.Get(POSEntrySalesDocLink."POS Entry No.");
                        if POSEntry."Post Entry Status" <> POSEntry."Post Entry Status"::Posted then begin
                            Error(ERR_UNPOSTED_POS_ENTRY,
                              POSEntry.TableCaption,
                              POSEntry."Entry No.",
                              POSEntry.FieldCaption("Document No."),
                              POSEntry."Document No.",
                              SalesHeader."Document Type"::Invoice,
                              SalesInvoiceHeader."No.");
                        end;
                    until POSEntrySalesDocLink.Next() = 0;
            until SalesInvoiceHeader.Next() = 0;
    end;
}