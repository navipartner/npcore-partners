codeunit 6151171 "NPR Spfy Legacy Return Posting"
{
    Access = Internal;

    var
        _RefundAccountMissingErr: Label '%1 must be set on %2 %3 before Shopify return %4 can be settled.', Comment = '%1 = Return Refund G/L Account No. caption, %2 = Shopify Store table caption, %3 = store code, %4 = Shopify return name';
        _PartialInvoicingErr: Label 'Shopify return %1 must be invoiced in one go. %2 %3 was invoiced in part, which the Shopify return import does not support.', Comment = '%1 = Shopify return name, %2 = Sales Header table caption, %3 = Return Order number';
        _RefundAppliedLbl: Label 'Shopify refund %1', Comment = '%1 = Shopify return name';
        _GiftCardRefundAppliedLbl: Label 'Shopify gift card refund %1', Comment = '%1 = Shopify return name';
        _OverRefundErr: Label '%1 %2 is worth %3 but Shopify refunded %4 for return %5, so the settlement would pay out more than was refunded. The %6 was changed after it was built; discard the draft and retry, or handle the return manually.', Comment = '%1 = Sales Cr.Memo Header table caption, %2 = credit memo no., %3 = credit memo total, %4 = refunded total, %5 = Shopify return name, %6 = Sales Header table caption';
        _VoucherMissingErr: Label '%1 %2, which Shopify return %3 refunds to, no longer exists, so the refund cannot be topped up onto it. Discard the draft and retry, or handle the return manually.', Comment = '%1 = Voucher table caption, %2 = voucher no., %3 = Shopify return name';
        _VoucherMissingReceivedErr: Label '%1 %2, which Shopify return %3 refunds to, no longer exists, so the refund cannot be topped up onto it. The return has already been received as %4, so the draft cannot be discarded; handle the return manually.', Comment = '%1 = Voucher table caption, %2 = voucher no., %3 = Shopify return name, %4 = return receipt no.';
        _VoucherDeactivatedErr: Label '%1 %2, which Shopify return %3 refunds to, was archived and then deactivated at Shopify, so it cannot be restored for the refund. Handle the return manually and dismiss the queue row.', Comment = '%1 = Voucher table caption, %2 = voucher no., %3 = Shopify return name';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure OnAfterFinalizePostingOnBeforeCommit(var SalesHeader: Record "Sales Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var PreviewMode: Boolean; var EverythingInvoiced: Boolean)
    var
        QueueRow: Record "NPR Spfy Legacy Return Queue";
        ShopifyStore: Record "NPR Spfy Store";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        PostedGiftCardShare: Decimal;
    begin
        if PreviewMode then
            exit;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::"Return Order" then
            exit;
        if not SpfyLegacyReturnMgt.FindQueueRowBySalesHeader(SalesHeader, QueueRow) then
            exit;
        // A second partial credit memo would settle the refund twice; the error rolls the posting back.
        if (SalesCrMemoHeader."No." <> '') and not EverythingInvoiced then
            Error(_PartialInvoicingErr, QueueRow."Return Name", SalesHeader.TableCaption(), SalesHeader."No.");
        if SalesCrMemoHeader."No." <> '' then begin
            QueueRow."Posted Doc. No." := SalesCrMemoHeader."No.";
            QueueRow.Status := QueueRow.Status::Imported;
            QueueRow."Last Error" := '';
        end else
            if ReturnReceiptHeader."No." <> '' then
                QueueRow."Posted Doc. No." := ReturnReceiptHeader."No."
            else
                exit;
        QueueRow.Modify();
        if SalesCrMemoHeader."No." = '' then
            exit;
        ShopifyStore.Get(QueueRow."Shopify Store Code");
        CheckCreditMemoWithinRefund(QueueRow, SalesCrMemoHeader);
        PostedGiftCardShare := SettleCreditMemo(ShopifyStore, QueueRow, SalesCrMemoHeader, GenJnlPostLine);
        TopUpVoucher(QueueRow, SalesCrMemoHeader, PostedGiftCardShare, ReturnReceiptHeader."No.");
        ArchiveRevokedVouchers(SalesCrMemoHeader);
    end;

    /// <summary>
    /// A draft edited by hand can be worth more than Shopify refunded; the Magento payment check skips that once the payment line allows adjusting.
    /// </summary>
    local procedure CheckCreditMemoWithinRefund(QueueRow: Record "NPR Spfy Legacy Return Queue"; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        Total: Decimal;
        Paid: Decimal;
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        PaymentLine.CalcSums(Amount);
        CustLedgerEntry.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields(Amount);
        // The Magento module rounds the total to the G/L precision and truncates the payment copy to it, so both sides compare at that precision.
        GLSetup.Get();
        Total := Round(Abs(CustLedgerEntry.Amount), GLSetup."Amount Rounding Precision");
        Paid := Round(PaymentLine.Amount, GLSetup."Amount Rounding Precision");
        if Total - Paid > InvoiceRoundingTolerance(SalesCrMemoHeader."Currency Code") then
            Error(_OverRefundErr, SalesCrMemoHeader.TableCaption(), SalesCrMemoHeader."No.", Total, Paid, QueueRow."Return Name", SalesHeader.TableCaption());
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

    local procedure SettleCreditMemo(ShopifyStore: Record "NPR Spfy Store"; QueueRow: Record "NPR Spfy Legacy Return Queue"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line") PostedGiftCardShare: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        TotalToSettle: Decimal;
        CardShare: Decimal;
        GiftCardAccountNo: Code[20];
    begin
        if ShopifyStore."Return Refund G/L Account No." = '' then
            Error(_RefundAccountMissingErr, ShopifyStore.FieldCaption("Return Refund G/L Account No."), ShopifyStore.TableCaption(), ShopifyStore.Code, QueueRow."Return Name");
        // The ledger amount, not the line sum: invoice rounding can differ.
        CustLedgerEntry.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        TotalToSettle := Abs(CustLedgerEntry."Remaining Amount");
        if TotalToSettle = 0 then
            exit(0);
        PostedGiftCardShare := QueueRow."Gift Card Refund Amount";
        if PostedGiftCardShare > TotalToSettle then
            PostedGiftCardShare := TotalToSettle;
        if PostedGiftCardShare < 0 then
            PostedGiftCardShare := 0;
        CardShare := TotalToSettle - PostedGiftCardShare;
        GiftCardAccountNo := ShopifyStore."Ret. Gift Card Refund G/L Acc.";
        if GiftCardAccountNo = '' then
            GiftCardAccountNo := ShopifyStore."Return Refund G/L Account No.";
        PostRefundJournalLine(SalesCrMemoHeader, CustLedgerEntry."Journal Templ. Name", ShopifyStore."Return Refund G/L Account No.", CardShare, StrSubstNo(_RefundAppliedLbl, QueueRow."Return Name"), GenJnlPostLine);
        PostRefundJournalLine(SalesCrMemoHeader, CustLedgerEntry."Journal Templ. Name", GiftCardAccountNo, PostedGiftCardShare, StrSubstNo(_GiftCardRefundAppliedLbl, QueueRow."Return Name"), GenJnlPostLine);
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

    local procedure TopUpVoucher(QueueRow: Record "NPR Spfy Legacy Return Queue"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PostedGiftCardShare: Decimal; ReceiptNoOfThisPosting: Code[20])
    var
        Voucher: Record "NPR NpRv Voucher";
        GLSetup: Record "General Ledger Setup";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        AmountLCY: Decimal;
    begin
        // Top up the gift card share that was settled, on the liability account or, when none is set up, on the refund account.
        if (QueueRow."Voucher No." = '') or (PostedGiftCardShare <= 0) then
            exit;
        if not Voucher.Get(QueueRow."Voucher No.") then
            if not RestoreArchivedVoucher(QueueRow, Voucher) then
                ErrorVoucherMissing(QueueRow, SalesCrMemoHeader, ReceiptNoOfThisPosting);
        GLSetup.Get();
        if SalesCrMemoHeader."Currency Code" = '' then
            AmountLCY := PostedGiftCardShare
        else
            AmountLCY := CurrencyExchangeRate.ExchangeAmtFCYToLCY(SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."Currency Code", PostedGiftCardShare, SalesCrMemoHeader."Currency Factor");
        AmountLCY := Round(AmountLCY, GLSetup."Amount Rounding Precision");
        NpRvVoucherMgt.PostTopUpForCreditMemo(Voucher, AmountLCY, SalesCrMemoHeader."Posting Date", SalesCrMemoHeader."No.", CopyStr(QueueRow."Return Name", 1, 50), true);
    end;

    /// <summary>
    /// A card spent to zero was archived with its Shopify id; the refund brings it back before the top-up, and the module's unarchive moves the id along.
    /// The row carries the voucher's own number, which the archive may hold under a number of its own series.
    /// </summary>
    local procedure RestoreArchivedVoucher(QueueRow: Record "NPR Spfy Legacy Return Queue"; var Voucher: Record "NPR NpRv Voucher"): Boolean
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        ArchVoucher.SetRange("Arch. No.", QueueRow."Voucher No.");
        if not ArchVoucher.FindFirst() then
            if not ArchVoucher.Get(QueueRow."Voucher No.") then
                exit(false);
        // Deactivation at Shopify is permanent, so a card deactivated after archiving cannot carry the refund.
        if ArchVoucher."Disabled at Shopify" then
            Error(_VoucherDeactivatedErr, Voucher.TableCaption(), QueueRow."Voucher No.", QueueRow."Return Name");
        NpRvVoucherMgt.UnarchiveVoucher(ArchVoucher."No.", false);
        exit(Voucher.Get(QueueRow."Voucher No."));
    end;

    /// <summary>
    /// A receipt posted before this transaction stops the draft from being discarded, so the advice depends on whether one exists.
    /// </summary>
    local procedure ErrorVoucherMissing(QueueRow: Record "NPR Spfy Legacy Return Queue"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; ReceiptNoOfThisPosting: Code[20])
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        Voucher: Record "NPR NpRv Voucher";
    begin
        ReturnReceiptHeader.SetRange("Return Order No.", SalesCrMemoHeader."Return Order No.");
        ReturnReceiptHeader.SetFilter("No.", '<>%1', ReceiptNoOfThisPosting);
        if ReturnReceiptHeader.FindFirst() then
            Error(_VoucherMissingReceivedErr, Voucher.TableCaption(), QueueRow."Voucher No.", QueueRow."Return Name", ReturnReceiptHeader."No.");
        Error(_VoucherMissingErr, Voucher.TableCaption(), QueueRow."Voucher No.", QueueRow."Return Name");
    end;
}
