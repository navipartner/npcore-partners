codeunit 6151171 "NPR Spfy Legacy Return Posting"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure OnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var PreviewMode: Boolean; var EverythingInvoiced: Boolean)
    var
        Settlement: Record "NPR Spfy Refund Settlement";
        ShopifyStore: Record "NPR Spfy Store";
        PostedGiftCardShare: Decimal;
        PartialInvoicingErr: Label 'Shopify %1 must be invoiced in one go. %2 %3 was invoiced in part, which the Shopify return and refund import does not support.', Comment = '%1 = Shopify document caption, %2 = Sales Header table caption, %3 = Return Order number';
    begin
        if PreviewMode then
            exit;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::"Return Order" then
            exit;
        if not Settlement.FindForSalesHeader(SalesHeader) then
            exit;
        // A second partial credit memo would settle the refund twice; the error rolls the posting back.
        if (SalesCrMemoHeader."No." <> '') and not EverythingInvoiced then
            Error(PartialInvoicingErr, Settlement."Display Name", SalesHeader.TableCaption(), SalesHeader."No.");
        if SalesCrMemoHeader."No." = '' then
            exit;
        ShopifyStore.Get(Settlement."Shopify Store Code");
        CheckCreditMemoWithinRefund(Settlement, SalesCrMemoHeader);
        PostedGiftCardShare := SettleCreditMemo(ShopifyStore, Settlement, SalesCrMemoHeader, GenJnlPostLine);
        CreditVoucherBack(Settlement, SalesCrMemoHeader, PostedGiftCardShare, ReturnReceiptHeader."No.");
        ArchiveRevokedVouchers(SalesCrMemoHeader);
    end;

    /// <summary>
    /// A draft edited by hand below what Shopify refunded is refused before posting: the Magento posting caps the copied payments at the document total, so a short credit memo cannot be seen afterwards. An excess is refused after posting, within invoice rounding.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure CheckDraftNotShortOfRefund(var SalesHeader: Record "Sales Header")
    var
        Settlement: Record "NPR Spfy Refund Settlement";
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyRefundDocBuilder: Codeunit "NPR Spfy Refund Doc. Builder";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::"Return Order" then
            exit;
        if not SalesHeader.Invoice then
            exit;
        if not Settlement.FindForSalesHeader(SalesHeader) then
            exit;
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.CalcSums(Amount);
        SpfyRefundDocBuilder.VerifyDocumentNotShort(SalesHeader, Settlement."Display Name", PaymentLine.Amount + Settlement."Applied Amount");
    end;

    /// <summary>
    /// BC must have applied the credit memo as the import planned, and a draft edited by hand can be worth more than Shopify refunded; what BC's application leaves must be covered by the payment lines.
    /// </summary>
    local procedure CheckCreditMemoWithinRefund(Settlement: Record "NPR Spfy Refund Settlement"; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        Total: Decimal;
        Paid: Decimal;
        Applied: Decimal;
        Tolerance: Decimal;
        OverRefundErr: Label '%1 %2 is worth %3 but Shopify refunded %4 for Shopify %5, so the settlement would pay out more than was refunded. The %6 was changed after it was built; discard the draft and retry, or handle it manually.', Comment = '%1 = Sales Cr.Memo Header table caption, %2 = credit memo no., %3 = credit memo total, %4 = refunded total, %5 = Shopify document caption, %6 = Sales Header table caption';
        ApplicationDiffersErr: Label '%1 %2 for Shopify %3 was applied to %4 of open entries when posted, but it was built to settle %5 that way, so the settlement would not match what Shopify paid out. Business Central applied it differently, for example through an Applies-to ID or the %6 of %7 %8. Set the %6 to Manual or clear the application on the %9 and post again, or handle the refund manually.', Comment = '%1 = Sales Cr.Memo Header table caption, %2 = credit memo no., %3 = Shopify document caption, %4 = amount applied at posting, %5 = amount the import planned to apply, %6 = Application Method field caption, %7 = Customer table caption, %8 = customer no., %9 = Sales Header table caption';
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        PaymentLine.CalcSums(Amount);
        CustLedgerEntry.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields(Amount, "Remaining Amount");
        // The Magento module rounds the total to the G/L precision and truncates the payment copy to it, so both sides compare at that precision.
        GLSetup.Get();
        Tolerance := InvoiceRoundingTolerance(SalesCrMemoHeader."Currency Code");
        // Only the planned application is settled by the open invoice; anything else BC applied (Apply to Oldest, an Applies-to ID set by hand,
        // an invoice that is more open than when the draft was built) would leave the refund unpaid and the gift card share unreversed.
        Applied := Round(Abs(CustLedgerEntry.Amount) - Abs(CustLedgerEntry."Remaining Amount"), GLSetup."Amount Rounding Precision");
        if Abs(Applied - Round(Settlement."Applied Amount", GLSetup."Amount Rounding Precision")) > Tolerance then
            Error(ApplicationDiffersErr, SalesCrMemoHeader.TableCaption(), SalesCrMemoHeader."No.", Settlement."Display Name", Applied, Settlement."Applied Amount",
                Customer.FieldCaption("Application Method"), Customer.TableCaption(), SalesCrMemoHeader."Bill-to Customer No.", SalesHeader.TableCaption());
        // What BC applied to an open invoice at posting is settled; only the rest has to be covered by the payment lines.
        Total := Round(Abs(CustLedgerEntry."Remaining Amount"), GLSetup."Amount Rounding Precision");
        Paid := Round(PaymentLine.Amount, GLSetup."Amount Rounding Precision");
        if Total - Paid > Tolerance then
            Error(OverRefundErr, SalesCrMemoHeader.TableCaption(), SalesCrMemoHeader."No.", Total, Paid, Settlement."Display Name", SalesHeader.TableCaption());
    end;

    /// <summary>
    /// The most invoice rounding can lift a document: half the precision to nearest, just under it upwards, nothing downwards; at least one G/L unit in a finer currency. More is an edit.
    /// </summary>
    local procedure InvoiceRoundingTolerance(CurrencyCode: Code[10]): Decimal
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        Tolerance: Decimal;
    begin
        SalesReceivablesSetup.Get();
        if not SalesReceivablesSetup."Invoice Rounding" then
            exit(0);
        if CurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else
            Currency.Get(CurrencyCode);
        case Currency."Invoice Rounding Type" of
            Currency."Invoice Rounding Type"::Nearest:
                Tolerance := Currency."Invoice Rounding Precision" / 2;
            Currency."Invoice Rounding Type"::Up:
                Tolerance := Currency."Invoice Rounding Precision" - Currency."Amount Rounding Precision";
        end;
        if Tolerance < 0 then
            Tolerance := 0;
        // In a currency finer than the G/L precision the comparison sees nothing below a G/L unit, and the Magento copy is truncated to the
        // G/L-rounded total, so a legitimate lift shows as up to one G/L unit, or as the whole precision when rounding up.
        GLSetup.Get();
        if Currency."Amount Rounding Precision" < GLSetup."Amount Rounding Precision" then begin
            if Currency."Invoice Rounding Type" = Currency."Invoice Rounding Type"::Up then
                Tolerance := Currency."Invoice Rounding Precision";
            if Tolerance < GLSetup."Amount Rounding Precision" then
                Tolerance := GLSetup."Amount Rounding Precision";
        end;
        exit(Tolerance);
    end;

    local procedure SettleCreditMemo(ShopifyStore: Record "NPR Spfy Store"; Settlement: Record "NPR Spfy Refund Settlement"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line") PostedGiftCardShare: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        TotalToSettle: Decimal;
        CardShare: Decimal;
        GiftCardAccountNo: Code[20];
        RefundAccountMissingErr: Label '%1 must be set on %2 %3 before Shopify %4 can be settled.', Comment = '%1 = Return Refund G/L Account No. caption, %2 = Shopify Store table caption, %3 = store code, %4 = Shopify document caption';
        RefundAppliedLbl: Label 'Refund for Shopify %1', Comment = '%1 = Shopify document caption';
        GiftCardRefundAppliedLbl: Label 'Gift card refund for Shopify %1', Comment = '%1 = Shopify document caption';
    begin
        if ShopifyStore."Return Refund G/L Account No." = '' then
            Error(RefundAccountMissingErr, ShopifyStore.FieldCaption("Return Refund G/L Account No."), ShopifyStore.TableCaption(), ShopifyStore.Code, Settlement."Display Name");
        // The ledger amount, not the line sum: invoice rounding can differ.
        CustLedgerEntry.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        TotalToSettle := Abs(CustLedgerEntry."Remaining Amount");
        if TotalToSettle = 0 then
            exit(0);
        PostedGiftCardShare := Settlement."Gift Card Refund Amount";
        if PostedGiftCardShare > TotalToSettle then
            PostedGiftCardShare := TotalToSettle;
        if PostedGiftCardShare < 0 then
            PostedGiftCardShare := 0;
        CardShare := TotalToSettle - PostedGiftCardShare;
        GiftCardAccountNo := ShopifyStore."Ret. Gift Card Refund G/L Acc.";
        if GiftCardAccountNo = '' then
            GiftCardAccountNo := ShopifyStore."Return Refund G/L Account No.";
        PostRefundJournalLine(SalesCrMemoHeader, CustLedgerEntry."Journal Templ. Name", ShopifyStore."Return Refund G/L Account No.", CardShare, StrSubstNo(RefundAppliedLbl, Settlement."Display Name"), GenJnlPostLine);
        PostRefundJournalLine(SalesCrMemoHeader, CustLedgerEntry."Journal Templ. Name", GiftCardAccountNo, PostedGiftCardShare, StrSubstNo(GiftCardRefundAppliedLbl, Settlement."Display Name"), GenJnlPostLine);
    end;

    local procedure PostRefundJournalLine(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; JournalTemplateName: Code[10]; BalAccountNo: Code[20]; Amount: Decimal; Description: Text; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
    begin
        if (BalAccountNo = '') or (Amount = 0) then
            exit;
        GenJnlLine.Init();
        // A refund carries no VAT.
        GenJnlLine."Copy VAT Setup to Jnl. Lines" := false;
        GLSetup.Get();
        if GLSetup."Journal Templ. Name Mandatory" then
            GenJnlLine."Journal Template Name" := JournalTemplateName;
        GenJnlLine."Posting Date" := SalesCrMemoHeader."Posting Date";
        GenJnlLine."Document Date" := SalesCrMemoHeader."Posting Date";
        GenJnlLine.Description := CopyStr(Description, 1, MaxStrLen(GenJnlLine.Description));
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine.Validate("Account No.", SalesCrMemoHeader."Bill-to Customer No.");
        GenJnlLine."Document No." := SalesCrMemoHeader."No.";
        GenJnlLine."External Document No." := SalesCrMemoHeader."External Document No.";
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine.Validate("Bal. Account No.", BalAccountNo);
        GenJnlLine."Currency Code" := SalesCrMemoHeader."Currency Code";
        if SalesCrMemoHeader."Currency Code" = '' then
            GenJnlLine."Currency Factor" := 1
        else
            GenJnlLine."Currency Factor" := SalesCrMemoHeader."Currency Factor";
        GenJnlLine.Amount := Amount;
        GenJnlLine."Source Currency Code" := SalesCrMemoHeader."Currency Code";
        GenJnlLine."Source Currency Amount" := Amount;
        GenJnlLine.Validate(Amount);
        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::"Credit Memo";
        GenJnlLine."Applies-to Doc. No." := SalesCrMemoHeader."No.";
        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
        GenJnlLine."Source No." := SalesCrMemoHeader."Bill-to Customer No.";
        GenJnlLine."Shortcut Dimension 1 Code" := SalesCrMemoHeader."Shortcut Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := SalesCrMemoHeader."Shortcut Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := SalesCrMemoHeader."Dimension Set ID";
        GenJnlLine."Source Code" := SalesCrMemoHeader."Source Code";
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    /// <summary>
    /// The credit memo's corrective entries wrote the returned cards down; archiving makes them unusable in BC and, through the voucher sync, in Shopify.
    /// </summary>
    local procedure ArchiveRevokedVouchers(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        Voucher: Record "NPR NpRv Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VoucherNos: List of [Code[20]];
        VoucherNo: Code[20];
    begin
        VoucherEntry.SetCurrentKey("Entry Type", "Document Type", "Document No.");
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
        VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::"Credit Memo");
        VoucherEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        VoucherEntry.SetRange(Correction, true);
        if VoucherEntry.FindSet() then
            repeat
                if not VoucherNos.Contains(VoucherEntry."Voucher No.") then
                    VoucherNos.Add(VoucherEntry."Voucher No.");
            until VoucherEntry.Next() = 0;
        foreach VoucherNo in VoucherNos do
            if Voucher.Get(VoucherNo) then
                NpRvVoucherMgt.ArchiveRevokedVoucher(Voucher);
    end;

    /// <summary>
    /// The gift card share Shopify paid back to the card reverses what the card paid, as a corrective credit memo does: the card's initial amount stays and its balance goes back up.
    /// </summary>
    local procedure CreditVoucherBack(Settlement: Record "NPR Spfy Refund Settlement"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PostedGiftCardShare: Decimal; ReceiptNoOfThisPosting: Code[20])
    var
        Voucher: Record "NPR NpRv Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VoucherShare: Decimal;
    begin
        if (Settlement."Voucher No." = '') or (PostedGiftCardShare <= 0) then
            exit;
        if not Voucher.Get(Settlement."Voucher No.") then
            if not RestoreArchivedVoucher(Settlement, Voucher) then
                ErrorVoucherMissing(Settlement, SalesCrMemoHeader, ReceiptNoOfThisPosting);
        // The card's own share; store credit in the same refund has no voucher. Rows written before the share was recorded give the card the whole liability share.
        VoucherShare := PostedGiftCardShare;
        if (Settlement."Voucher Refund Amount" > 0) and (Settlement."Voucher Refund Amount" < VoucherShare) then
            VoucherShare := Settlement."Voucher Refund Amount";
        CheckWithinVoucherPayment(Settlement, SalesCrMemoHeader, VoucherShare, Voucher);
        NpRvVoucherMgt.PostPaymentReversalForCreditMemo(Voucher, VoucherReversalAmountLCY(Settlement, SalesCrMemoHeader, VoucherShare), SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."No.", CopyStr(Settlement."Display Name", 1, 50));
    end;

    /// <summary>
    /// What the card gets back in LCY: the share at the rate Shopify booked it in the shop currency when that is the LCY, as the order import booked the card's payment; else at the credit memo's rate.
    /// </summary>
    local procedure VoucherReversalAmountLCY(Settlement: Record "NPR Spfy Refund Settlement"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; VoucherShare: Decimal): Decimal
    var
        GLSetup: Record "General Ledger Setup";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        AmountLCY: Decimal;
    begin
        if SalesCrMemoHeader."Currency Code" = '' then
            exit(VoucherShare);
        GLSetup.Get();
        if ShopifyRateKnown(Settlement) then
            AmountLCY := VoucherShare * Settlement."Voucher Refund Amount (LCY)" / Settlement."Voucher Refund Amount"
        else
            AmountLCY := CurrencyExchangeRate.ExchangeAmtFCYToLCY(SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."Currency Code", VoucherShare, SalesCrMemoHeader."Currency Factor");
        exit(Round(AmountLCY, GLSetup."Amount Rounding Precision"));
    end;

    local procedure ShopifyRateKnown(Settlement: Record "NPR Spfy Refund Settlement"): Boolean
    begin
        exit((Settlement."Voucher Refund Amount" > 0) and (Settlement."Voucher Refund Amount (LCY)" > 0));
    end;

    /// <summary>
    /// A reversal may give back only what the card paid on the order's invoices, less what earlier credit memos of the order gave back to it; more would be a top-up in disguise. Compared in the document currency, as the payment lines carry it.
    /// </summary>
    local procedure CheckWithinVoucherPayment(Settlement: Record "NPR Spfy Refund Settlement"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; GiftCardShare: Decimal; Voucher: Record "NPR NpRv Voucher")
    var
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        PaymentLine: Record "NPR Magento Payment Line";
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        Builder: Codeunit "NPR Spfy Refund Doc. Builder";
        Available: Decimal;
        Tolerance: Decimal;
        RefundBeyondVoucherPaymentErr: Label 'Shopify %1 refunds %2 to %3 %4, but the card paid only %5 on the invoices of the order that earlier refunds have not already put back. Crediting more would raise the card beyond what was spent from it, so this Return Order cannot be posted; delete it and handle the refund manually.', Comment = '%1 = Shopify document caption, %2 = gift card share of the refund, %3 = Voucher table caption, %4 = voucher no., %5 = amount the card paid and that is not yet reversed';
    begin
        if Builder.CollectOrderInvoices(Settlement."Shopify Store Code", Settlement."Order Id", TempSalesInvoiceHeader) then begin
            TempSalesInvoiceHeader.FindSet();
            repeat
                PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
                PaymentLine.SetRange("Document No.", TempSalesInvoiceHeader."No.");
                PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::Voucher);
                PaymentLine.SetRange("Source No.", Voucher."No.");
                PaymentLine.CalcSums(Amount);
                Available += PaymentLine.Amount;
            until TempSalesInvoiceHeader.Next() = 0;
        end;
        Available -= ReversedForOrder(Settlement, Voucher."No.");
        Currency.Initialize(SalesCrMemoHeader."Currency Code");
        Tolerance := Currency."Amount Rounding Precision";
        // Earlier reversals are posted in LCY, so converting them back can miss by an LCY rounding unit.
        if SalesCrMemoHeader."Currency Factor" <> 0 then begin
            GLSetup.Get();
            Tolerance += GLSetup."Amount Rounding Precision" * SalesCrMemoHeader."Currency Factor";
        end;
        if GiftCardShare - Available > Tolerance then
            Error(RefundBeyondVoucherPaymentErr, Settlement."Display Name", GiftCardShare, Voucher.TableCaption(), Voucher."No.", Available);
    end;

    /// <summary>
    /// What earlier credit memos of the same Shopify order gave back to the card, in their document currency: reversed payments, and top-ups as released builds posted them.
    /// Only entries that raised the balance count; a credit memo that reverses a sold top-up lowers it. A credit memo without a settlement row, such as a corrective one made by hand, may be this order's, so it counts too.
    /// </summary>
    local procedure ReversedForOrder(Settlement: Record "NPR Spfy Refund Settlement"; VoucherNo: Code[20]) Reversed: Decimal
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        OtherSettlement: Record "NPR Spfy Refund Settlement";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        SourceDocType: Enum "NPR Spfy Legacy Return Source";
        ShopifyId: Text[30];
        HasSettlement: Boolean;
    begin
        VoucherEntry.SetRange("Voucher No.", VoucherNo);
        VoucherEntry.SetFilter("Entry Type", '%1|%2', VoucherEntry."Entry Type"::Payment, VoucherEntry."Entry Type"::"Top-up");
        VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::"Credit Memo");
        VoucherEntry.SetFilter(Amount, '>0');
        if VoucherEntry.FindSet() then
            repeat
                if SalesCrMemoHeader.Get(VoucherEntry."Document No.") then begin
                    HasSettlement := false;
                    if SpfyLegacyReturnMgt.GetSourceDocStamp(SalesCrMemoHeader.RecordId(), SourceDocType, ShopifyId) then
                        HasSettlement := OtherSettlement.Get(Settlement."Shopify Store Code", SourceDocType, ShopifyId);
                    if not HasSettlement then
                        Reversed += ReversalInDocumentCurrency(VoucherEntry.Amount, SalesCrMemoHeader, OtherSettlement, false)
                    else
                        if OtherSettlement."Order Id" = Settlement."Order Id" then
                            Reversed += ReversalInDocumentCurrency(VoucherEntry.Amount, SalesCrMemoHeader, OtherSettlement, true);
                end;
            until VoucherEntry.Next() = 0;
    end;

    /// <summary>
    /// Reads a reversal back at the rate it was posted at: Shopify's when VoucherReversalAmountLCY used it, else the credit memo's. Another rate would be off by the rate difference, not by a rounding unit.
    /// </summary>
    local procedure ReversalInDocumentCurrency(AmountLCY: Decimal; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; OtherSettlement: Record "NPR Spfy Refund Settlement"; HasSettlement: Boolean): Decimal
    begin
        if SalesCrMemoHeader."Currency Code" = '' then
            exit(AmountLCY);
        if HasSettlement then
            if ShopifyRateKnown(OtherSettlement) then
                exit(AmountLCY * OtherSettlement."Voucher Refund Amount" / OtherSettlement."Voucher Refund Amount (LCY)");
        if SalesCrMemoHeader."Currency Factor" <> 0 then
            exit(AmountLCY * SalesCrMemoHeader."Currency Factor");
        exit(AmountLCY);
    end;

    /// <summary>
    /// A card spent to zero was archived with its Shopify id; the refund brings it back before the reversal, and the module's unarchive moves the id along.
    /// The row carries the voucher's own number, which the archive may hold under a number of its own series.
    /// </summary>
    local procedure RestoreArchivedVoucher(Settlement: Record "NPR Spfy Refund Settlement"; var Voucher: Record "NPR NpRv Voucher"): Boolean
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VoucherDeactivatedErr: Label '%1 %2, which Shopify %3 refunds to, was archived and then deactivated at Shopify, so it cannot be restored for the refund. Handle it manually and dismiss the queue row.', Comment = '%1 = Voucher table caption, %2 = voucher no., %3 = Shopify document caption';
    begin
        ArchVoucher.SetRange("Arch. No.", Settlement."Voucher No.");
        if not ArchVoucher.FindFirst() then
            if not ArchVoucher.Get(Settlement."Voucher No.") then
                exit(false);
        // Deactivation at Shopify is permanent, so a card deactivated after archiving cannot carry the refund.
        if ArchVoucher."Disabled at Shopify" then
            Error(VoucherDeactivatedErr, Voucher.TableCaption(), Settlement."Voucher No.", Settlement."Display Name");
        NpRvVoucherMgt.UnarchiveVoucher(ArchVoucher."No.", false);
        exit(Voucher.Get(Settlement."Voucher No."));
    end;

    /// <summary>
    /// A receipt posted before this transaction stops the draft from being discarded, so the advice depends on whether one exists.
    /// </summary>
    local procedure ErrorVoucherMissing(Settlement: Record "NPR Spfy Refund Settlement"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; ReceiptNoOfThisPosting: Code[20])
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        Voucher: Record "NPR NpRv Voucher";
        VoucherMissingErr: Label '%1 %2, which Shopify %3 refunds to, no longer exists, so the refund cannot be credited back to it. Discard the draft and retry, or handle it manually.', Comment = '%1 = Voucher table caption, %2 = voucher no., %3 = Shopify document caption';
        VoucherMissingReceivedErr: Label '%1 %2, which Shopify %3 refunds to, no longer exists, so the refund cannot be credited back to it. The goods have already been received as %4, so the draft cannot be discarded; handle it manually.', Comment = '%1 = Voucher table caption, %2 = voucher no., %3 = Shopify document caption, %4 = return receipt no.';
    begin
        ReturnReceiptHeader.SetRange("Return Order No.", SalesCrMemoHeader."Return Order No.");
        ReturnReceiptHeader.SetFilter("No.", '<>%1', ReceiptNoOfThisPosting);
        if ReturnReceiptHeader.FindFirst() then
            Error(VoucherMissingReceivedErr, Voucher.TableCaption(), Settlement."Voucher No.", Settlement."Display Name", ReturnReceiptHeader."No.");
        Error(VoucherMissingErr, Voucher.TableCaption(), Settlement."Voucher No.", Settlement."Display Name");
    end;
}
