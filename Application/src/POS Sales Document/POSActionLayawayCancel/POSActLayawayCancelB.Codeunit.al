codeunit 6060008 "NPR POS Act.:Layaway Cancel-B"
{
    Access = Internal;
    procedure CancelLayaway(var Sale: Codeunit "NPR POS Sale"; var SaleLine: Codeunit "NPR POS Sale Line"; CancellationFeeItemNo: Text; OrderPaymentTermsFilter: Text; SelectCustomer: Boolean; SkipFeeInvoice: Boolean; ConfirmInvDiscAmt: Boolean)
    var
        SalesHeader: Record "Sales Header";
        POSLayawayMgt: Codeunit "NPR POS Layaway Mgt.";
        POSSession: Codeunit "NPR POS Session";
        ERR_APPLICATION: Label 'Layaway prepayments were credited and sales order %1 was deleted successfully but an error occurred while applying customer entries and calculating amount to refund:\%2';
        LAYAWAY_CANCEL_LINE: Label 'Layaway of %1 %2 cancelled.';
        CreditMemoNo: Text;
        ServiceInvoiceNo: Text;

    begin
        if not CheckCustomer(Sale, SelectCustomer) then
            exit;

        if not SelectOrder(Sale, SalesHeader, OrderPaymentTermsFilter) then
            exit;

        if not ConfirmImportInvDiscAmt(SalesHeader, ConfirmInvDiscAmt) then
            exit;

        CheckForUnpostedLinkedPOSEntries(SalesHeader);


        CreditMemoNo := CreditPrepayments(SalesHeader);
        InsertCancellationFeeItem(SalesHeader, CancellationFeeItemNo, SkipFeeInvoice);
        ServiceInvoiceNo := PostServiceInvoice(SalesHeader, SkipFeeInvoice); //COMMITS
        DeleteOrder(SalesHeader);
        InsertCommentLine(SaleLine, StrSubstNo(LAYAWAY_CANCEL_LINE, SalesHeader."Document Type", SalesHeader."No."));
        Commit();

        ClearLastError();
        Clear(POSLayawayMgt);
        POSLayawayMgt.SetRunApplyPrepmtCreditMemoAndRefund(POSSession, CreditMemoNo, ServiceInvoiceNo);
        if not POSLayawayMgt.Run(SalesHeader) then
            Error(ERR_APPLICATION, SalesHeader."No.", GetLastErrorText);
    end;

    local procedure CheckCustomer(POSSale: Codeunit "NPR POS Sale"; SelectCustomer: Boolean): Boolean
    var
        Customer: Record Customer;
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then
            exit(true);

        if not SelectCustomer then
            exit(true);

        if Page.RunModal(0, Customer) <> Action::LookupOK then
            exit(false);

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit();
        exit(true);
    end;

    local procedure SelectOrder(POSSale: Codeunit "NPR POS Sale"; var SalesHeader: Record "Sales Header"; OrderPaymentTermsFilter: Text): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        POSSale.GetCurrentSale(SalePOS);

        SalesHeader.SetRange("Payment Terms Code", OrderPaymentTermsFilter);
        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        exit(RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GetView(false), SalesHeader));
    end;

    local procedure ConfirmImportInvDiscAmt(SalesHeader: Record "Sales Header"; ConfirmInvDiscAmt: Boolean): Boolean
    var
        SalesLine: Record "Sales Line";
        SalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
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

    local procedure CreditPrepayments(var SalesHeader: Record "Sales Header"): Text
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        ERR_DOCUMENT_POSTED_LINE: Label '%1 %2 has partially posted lines. Aborting action.';
    begin
        if RetailSalesDocImpMgt.DocumentIsPartiallyPosted(SalesHeader) then
            Error(ERR_DOCUMENT_POSTED_LINE);

        SalesPostPrepayments.CreditMemo(SalesHeader);

        CustLedgerEntry.SetAutoCalcFields(Amount, "Remaining Amount");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesHeader."Last Prepmt. Cr. Memo No.");
        CustLedgerEntry.FindFirst();
        //If customer application method is set to apply to oldest, we error here before anything is committed as we won't be able to apply the credit memo correctly and trust the final refund amount.
        CustLedgerEntry.TestField(Open);
        CustLedgerEntry.TestField(Amount, CustLedgerEntry."Remaining Amount");

        exit(SalesHeader."Last Prepmt. Cr. Memo No.");
    end;

    local procedure InsertCancellationFeeItem(var SalesHeader: Record "Sales Header"; CancellationFeeItemNo: Text; Skip: Boolean)
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
    begin
        if (CancellationFeeItemNo = '') or Skip then
            exit;

        Item.Get(CancellationFeeItemNo);
        Item.TestField(Type, Item.Type::Service);

        SalesHeader.Status := SalesHeader.Status::Open;
        SalesHeader.Modify(true);

        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine.Validate("No.", CancellationFeeItemNo);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Insert(true);
    end;

    local procedure PostServiceInvoice(var SalesHeader: Record "Sales Header"; Skip: Boolean): Text
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        SalesPost: Codeunit "Sales-Post";
    begin
        if Skip then
            exit('');

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("No.", '<>%1', '');
        if SalesLine.FindSet(true) then
            repeat
                if Item.Get(SalesLine."No.") and (Item.Type = Item.Type::Service) then begin
                    SalesLine.Validate("Qty. to Invoice", SalesLine.Quantity);
                    SalesLine.Validate("Qty. to Ship", SalesLine.Quantity);
                end else begin
                    SalesLine.Validate("Qty. to Invoice", 0);
                    SalesLine.Validate("Qty. to Ship", 0);
                end;
                SalesLine.Modify(true);
            until SalesLine.Next() = 0;

        SalesHeader.Invoice := true;
        SalesHeader.Ship := true;
        SalesHeader.Status := SalesHeader.Status::Released;
        SalesHeader.Modify(true);

        SalesPost.Run(SalesHeader);

        if SalesHeader."Last Posting No." = '' then
            exit(SalesHeader."No.");
        exit(SalesHeader."Last Posting No.");
    end;

    local procedure DeleteOrder(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Delete(true);
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
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ERR_UNPOSTED_POS_ENTRY: Label '%1 %2, %3 %4 is related to %5 %6 but has not yet been posted.\All related entries must be posted before layaway cancellation.';
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