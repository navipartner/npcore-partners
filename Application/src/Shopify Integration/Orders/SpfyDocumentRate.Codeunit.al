/// <summary>
/// Keeps a Shopify document valued at the exchange rate Shopify used, instead of the one BC would take from the Currency Exchange Rate table without asking anyone.
/// A user who is asked by BC's own prompt still decides; once the factor differs from the one kept, the document is no longer protected.
/// A credit for a Shopify order reverses at the order invoice's factor. Money paid out on a refund goes at the refund's own rate: the LCY Shopify booked for it, else the table rate on the refund's posting date.
/// Two exceptions: a currency without realized FX accounts keeps the credit's own rate, and a gift card's share of the refund is valued at the LCY its voucher gets back.
/// </summary>
codeunit 6184575 "NPR Spfy Document Rate"
{
    Access = Internal;
    SingleInstance = true;

    var
        // The protected document whose Posting Date or Currency Code trigger is running, and the factor it must end with unless a user takes the new one.
        _RevaluedDocType: Enum "Sales Document Type";
        _RevaluedDocNo: Code[20];
        _RevaluedKeptFactor: Decimal;
        _ReReadAllowed: Boolean;
        _UserConfirmed: Boolean;

    internal procedure SetShopifyCurrencyFactor(var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Currency Code" = '' then begin
            ForgetShopifyCurrencyFactor(SalesHeader);
            exit;
        end;
        SalesHeader."NPR Spfy Currency Factor" := SalesHeader."Currency Factor";
        SalesHeader."NPR Spfy Currency Code" := SalesHeader."Currency Code";
    end;

    local procedure ForgetShopifyCurrencyFactor(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader."NPR Spfy Currency Factor" := 0;
        SalesHeader."NPR Spfy Currency Code" := '';
    end;

    /// <summary>
    /// Takes the document back to the BC rate table when the rate it carries no longer comes from Shopify.
    /// </summary>
    internal procedure ReleaseShopifyCurrencyFactor(var SalesHeader: Record "Sales Header")
    var
        KeptCurrencyFactor: Decimal;
        TableCurrencyFactor: Decimal;
    begin
        if SalesHeader."NPR Spfy Currency Factor" = 0 then
            exit;
        ForgetShopifyCurrencyFactor(SalesHeader);
        if SalesHeader."Currency Code" = '' then
            exit;
        KeptCurrencyFactor := SalesHeader."Currency Factor";
        SalesHeader.UpdateCurrencyFactor();
        TableCurrencyFactor := SalesHeader."Currency Factor";
        if TableCurrencyFactor = KeptCurrencyFactor then
            exit;
        // Validated from the kept factor so the lines follow the new one.
        SalesHeader."Currency Factor" := KeptCurrencyFactor;
        SalesHeader.Validate("Currency Factor", TableCurrencyFactor);
    end;

    /// <summary>
    /// The kept factor protects the document only in the currency it was kept for; the currency can change where xRec already holds the new code (the Bill-to customer chain) or without a validate at all.
    /// </summary>
    internal procedure IsLocked(SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(HoldsKeptRate(SalesHeader."Currency Code", SalesHeader."Currency Factor", SalesHeader."NPR Spfy Currency Code", SalesHeader."NPR Spfy Currency Factor"));
    end;

    internal procedure IsLocked(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Boolean
    begin
        exit(HoldsKeptRate(SalesCrMemoHeader."Currency Code", SalesCrMemoHeader."Currency Factor", SalesCrMemoHeader."NPR Spfy Currency Code", SalesCrMemoHeader."NPR Spfy Currency Factor"));
    end;

    local procedure HoldsKeptRate(CurrencyCode: Code[10]; CurrencyFactor: Decimal; KeptCurrencyCode: Code[10]; KeptCurrencyFactor: Decimal): Boolean
    begin
        exit((CurrencyCode <> '') and (CurrencyCode = KeptCurrencyCode) and (KeptCurrencyFactor <> 0) and (CurrencyFactor = KeptCurrencyFactor));
    end;

    /// <summary>
    /// A credit built for a Shopify order takes the factor the order's invoices posted at, so revenue, receivable and voucher liability reverse exactly what they posted.
    /// Left at the BC table rate when the order has no invoice, any of its invoices is in another currency, or they posted at different factors.
    /// </summary>
    internal procedure KeepOrderInvoiceCurrencyFactor(ShopifyStoreCode: Code[20]; OrderId: Text[30]; var SalesHeader: Record "Sales Header")
    var
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        SpfyRefundDocBuilder: Codeunit "NPR Spfy Refund Doc. Builder";
        InvoiceCurrencyFactor: Decimal;
    begin
        if SalesHeader."Currency Code" = '' then
            exit;
        if not SpfyRefundDocBuilder.CollectOrderInvoices(ShopifyStoreCode, OrderId, TempSalesInvoiceHeader) then
            exit;
        TempSalesInvoiceHeader.FindSet();
        repeat
            if TempSalesInvoiceHeader."Currency Code" <> SalesHeader."Currency Code" then
                exit;
            if InvoiceCurrencyFactor = 0 then
                InvoiceCurrencyFactor := TempSalesInvoiceHeader."Currency Factor";
            if TempSalesInvoiceHeader."Currency Factor" <> InvoiceCurrencyFactor then
                exit;
        until TempSalesInvoiceHeader.Next() = 0;
        if InvoiceCurrencyFactor = 0 then
            exit;
        if InvoiceCurrencyFactor <> SalesHeader."Currency Factor" then
            SalesHeader.Validate("Currency Factor", InvoiceCurrencyFactor);
        SetShopifyCurrencyFactor(SalesHeader);
    end;

    /// <summary>
    /// The LCY a refund of the credit pays out per unit: what Shopify booked in LCY when the payment lines carry it, otherwise, on a credit held at the order invoice's earlier rate, the table rate on the day the refund is posted, since a refund is made at that day's rate.
    /// 0 keeps the credit's own rate: the currency has nowhere to book the realized FX the difference creates, or the credit is not held at an earlier rate.
    /// </summary>
    internal procedure RefundAmountLCYPerAmount(DocumentCurrencyCode: Code[10]; PostingDate: Date; HeldAtInvoiceRate: Boolean; var PaymentLine: Record "NPR Magento Payment Line"): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        AmountLCYPerAmount: Decimal;
    begin
        if not HasRealizedFXAccounts(DocumentCurrencyCode) then
            exit(0);
        AmountLCYPerAmount := ShopifyAmountLCYPerAmount(PaymentLine);
        if (AmountLCYPerAmount <> 0) or not HeldAtInvoiceRate then
            exit(AmountLCYPerAmount);
        exit(1 / CurrencyExchangeRate.ExchangeRate(PostingDate, DocumentCurrencyCode));
    end;

    internal procedure HasRealizedFXAccounts(CurrencyCode: Code[10]): Boolean
    var
        Currency: Record Currency;
    begin
        if not Currency.Get(CurrencyCode) then
            exit(false);
        exit((Currency."Realized Gains Acc." <> '') and (Currency."Realized Losses Acc." <> ''));
    end;

    /// <summary>
    /// The LCY Shopify booked per unit of the payment lines in the filter, from their shop money; 0 when there are none, any of them lacks it, or the shop currency is not the LCY.
    /// </summary>
    internal procedure ShopifyAmountLCYPerAmount(var PaymentLine: Record "NPR Magento Payment Line"): Decimal
    var
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        TotalAmount: Decimal;
        TotalAmountLCY: Decimal;
    begin
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        if not PaymentLine.FindSet() then
            exit(0);
        repeat
            if (PaymentLine."Amount (Store Currency)" = 0) or (PaymentLine."Store Currency Code" = '') or not SpfyPaymentGatewayHdlr.IsLCY(PaymentLine."Store Currency Code") then
                exit(0);
            TotalAmount += PaymentLine.Amount;
            TotalAmountLCY += PaymentLine."Amount (Store Currency)";
        until PaymentLine.Next() = 0;
        if TotalAmount = 0 then
            exit(0);
        exit(TotalAmountLCY / TotalAmount);
    end;

    /// <summary>
    /// BC re-reads the rate table on a protected document only inside the Posting Date and Currency Code triggers that can ask a user about it; everywhere else (batch Replace Posting Date, a currency code validated again from code) the re-read is skipped.
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeUpdateCurrencyFactor', '', false, false)]
    local procedure KeepShopifyCurrencyFactor(var SalesHeader: Record "Sales Header"; var Updated: Boolean)
    begin
        if Updated then
            exit;
        if not IsLocked(SalesHeader) then
            exit;
        if ReReadAllowed(SalesHeader) then
            exit;
        Updated := true;
    end;

    /// <summary>
    /// Without a user to ask, BC would apply the new rate to the lines; the document keeps the rate it had instead.
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeConfirmUpdateCurrencyFactor', '', false, false)]
    local procedure KeepShopifyCurrencyFactorUnlessUserDecides(var SalesHeader: Record "Sales Header"; var HideValidationDialog: Boolean; var xSalesHeader: Record "Sales Header"; var IsHandled: Boolean; var ForceConfirm: Boolean)
    begin
        if IsHandled or ForceConfirm then
            exit;
        if GuiAllowed() and not HideValidationDialog then
            exit;
        if not IsLocked(xSalesHeader) or (SalesHeader."Currency Code" <> xSalesHeader."Currency Code") then
            exit;
        SalesHeader."Currency Factor" := xSalesHeader."Currency Factor";
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterConfirmCurrencyFactorUpdate', '', false, false)]
    local procedure RememberUserConfirmed(var SalesHeader: Record "Sales Header"; var Confirmed: Boolean)
    begin
        if IsRevalued(SalesHeader) then
            _UserConfirmed := Confirmed;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnValidatePostingDateOnBeforeCheckNeedUpdateCurrencyFactor', '', false, false)]
    local procedure StartPostingDateRevaluation(var SalesHeader: Record "Sales Header"; var NeedUpdateCurrencyFactor: Boolean)
    begin
        StartRevaluation(SalesHeader, NeedUpdateCurrencyFactor);
    end;

    /// <summary>
    /// A warehouse document validates the posting date without BC's prompt after the re-read, so the decision is taken once the trigger has run.
    /// </summary>
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnValidatePostingDateOnAfterCheckNeedUpdateCurrencyFactor', '', false, false)]
    local procedure EndPostingDateRevaluation(var SalesHeader: Record "Sales Header")
    begin
        EndRevaluation(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Currency Code', false, false)]
    local procedure OnBeforeValidateCurrencyCode(var Rec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        // A rate kept for one currency must never stick to another. Compared with the kept currency, not xRec, which already holds the new code when the Bill-to customer validates it.
        if Rec."Currency Code" <> Rec."NPR Spfy Currency Code" then
            ForgetShopifyCurrencyFactor(Rec);
        // Only an unchanged code validated on the field itself of an open document reaches BC's prompt; validated from code it does not, and a released one fails first.
        StartRevaluation(Rec, (CurrFieldNo = Rec.FieldNo("Currency Code")) and (Rec.Status = Rec.Status::Open));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Currency Code', false, false)]
    local procedure OnAfterValidateCurrencyCode(var Rec: Record "Sales Header")
    begin
        EndRevaluation(Rec);
    end;

    /// <summary>
    /// A credit copied from a Shopify invoice carries the invoice's own factor, which is what it must reverse at, even if the invoice was revalued. Any other copy is a new sale and takes BC's rates.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopySalesHeaderDone', '', false, false)]
    local procedure KeepInvoiceCurrencyFactorOnCopy(var ToSalesHeader: Record "Sales Header"; FromDocType: Enum "Sales Document Type From")
    begin
        if (FromDocType = FromDocType::"Posted Invoice") and ToSalesHeader.IsCreditDocType() and (ToSalesHeader."NPR Spfy Currency Factor" <> 0) then
            SetShopifyCurrencyFactor(ToSalesHeader)
        else
            ForgetShopifyCurrencyFactor(ToSalesHeader);
    end;

    /// <summary>
    /// The refund BC posts as the credit's balancing entry pays out at the refund's own rate, not the credit's; BC books the difference as realized FX when it applies the two.
    /// A gift card's share is no money paid out: on the credit's balancing account it is valued at the LCY the voucher is credited with.
    /// Only a credit with Shopify's shop money on its payment lines or held at a kept rate is affected; any other credit posts as before.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Post Invoice Events", 'OnPostBalancingEntryOnBeforeGenJnlPostLine', '', false, false)]
    local procedure PayRefundAtRefundRate(var GenJnlLine: Record "Gen. Journal Line"; var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AmountLCYPerAmount: Decimal;
        VoucherAmount: Decimal;
        VoucherAmountLCY: Decimal;
        VoucherAtShopifyLCY: Boolean;
    begin
        if not SalesHeader.IsCreditDocType() then
            exit;
        if SalesHeader."Currency Code" = '' then
            exit;
        if GenJnlLine.Amount = 0 then
            exit;
        // By now the posting has moved what the payment lines refund onto the credit memo's copies.
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", GenJnlLine."Document No.");
        SumVoucherShare(PaymentLine, SalesHeader, VoucherAmount, VoucherAmountLCY, VoucherAtShopifyLCY);
        PaymentLine.SetFilter("Payment Type", '<>%1', PaymentLine."Payment Type"::Voucher);
        AmountLCYPerAmount := RefundAmountLCYPerAmount(SalesHeader."Currency Code", GenJnlLine."Posting Date", IsLocked(SalesHeader), PaymentLine);
        if VoucherAmount = 0 then begin
            SetRefundAmountLCY(AmountLCYPerAmount, GenJnlLine);
            exit;
        end;
        if (AmountLCYPerAmount = 0) and not VoucherAtShopifyLCY then
            exit;
        if not HasRealizedFXAccounts(SalesHeader."Currency Code") then
            exit;
        SetAmountLCY(AmountLCYWithVoucherShare(GenJnlLine, SalesHeader, AmountLCYPerAmount, VoucherAmount, VoucherAmountLCY), GenJnlLine);
    end;

    /// <summary>
    /// The credit's voucher payment lines, in the document currency and at the LCY the voucher module credits the voucher with.
    /// </summary>
    local procedure SumVoucherShare(var PaymentLine: Record "NPR Magento Payment Line"; SalesHeader: Record "Sales Header"; var VoucherAmount: Decimal; var VoucherAmountLCY: Decimal; var AtShopifyLCY: Boolean)
    var
        Precalculated: Boolean;
    begin
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::Voucher);
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        if PaymentLine.FindSet() then
            repeat
                VoucherAmount += Abs(PaymentLine.Amount);
                VoucherAmountLCY += Abs(PaymentLine.AmountLCY(SalesHeader."Currency Code", SalesHeader."Currency Factor", Precalculated));
                if Precalculated then
                    AtShopifyLCY := true;
            until PaymentLine.Next() = 0;
        PaymentLine.SetRange("Payment Type");
        PaymentLine.SetRange(Amount);
    end;

    /// <summary>
    /// The balancing entry's LCY: the voucher share as the voucher is credited, the rest at the refund's rate per unit, or at the credit's own rate when that is 0.
    /// </summary>
    local procedure AmountLCYWithVoucherShare(GenJnlLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header"; AmountLCYPerAmount: Decimal; VoucherAmount: Decimal; VoucherAmountLCY: Decimal): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GeneralLedgerSetup: Record "General Ledger Setup";
        RestAmount: Decimal;
        RestAmountLCY: Decimal;
    begin
        GeneralLedgerSetup.Get();
        RestAmount := Abs(GenJnlLine.Amount) - VoucherAmount;
        if AmountLCYPerAmount <> 0 then
            RestAmountLCY := RestAmount * AmountLCYPerAmount
        else
            RestAmountLCY := CurrencyExchangeRate.ExchangeAmtFCYToLCY(GenJnlLine."Posting Date", SalesHeader."Currency Code", RestAmount, SalesHeader."Currency Factor");
        exit((VoucherAmountLCY + Round(RestAmountLCY, GeneralLedgerSetup."Amount Rounding Precision")) * (GenJnlLine.Amount / Abs(GenJnlLine.Amount)));
    end;

    /// <summary>
    /// Books the journal line's amount at the refund's LCY per unit.
    /// </summary>
    internal procedure SetRefundAmountLCY(AmountLCYPerAmount: Decimal; var GenJnlLine: Record "Gen. Journal Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if (AmountLCYPerAmount = 0) or (GenJnlLine.Amount = 0) then
            exit;
        GeneralLedgerSetup.Get();
        SetAmountLCY(Round(GenJnlLine.Amount * AmountLCYPerAmount, GeneralLedgerSetup."Amount Rounding Precision"), GenJnlLine);
    end;

    /// <summary>
    /// Assigned rather than validated, because validating "Amount (LCY)" recalculates Amount for a currency with fixed exchange rates.
    /// </summary>
    local procedure SetAmountLCY(AmountLCY: Decimal; var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine."Amount (LCY)" := AmountLCY;
        if AmountLCY <> 0 then
            GenJnlLine."Currency Factor" := GenJnlLine.Amount / AmountLCY;
    end;

    local procedure StartRevaluation(SalesHeader: Record "Sales Header"; AllowReRead: Boolean)
    begin
        _RevaluedKeptFactor := 0;
        _ReReadAllowed := false;
        _UserConfirmed := false;
        if not IsLocked(SalesHeader) then
            exit;
        _RevaluedDocType := SalesHeader."Document Type";
        _RevaluedDocNo := SalesHeader."No.";
        _RevaluedKeptFactor := SalesHeader."Currency Factor";
        _ReReadAllowed := AllowReRead;
    end;

    /// <summary>
    /// A factor that changed without a user's Yes goes back to the one kept. BC only applies a new factor to the lines after a Yes, so the lines still carry the kept one.
    /// </summary>
    local procedure EndRevaluation(var SalesHeader: Record "Sales Header")
    begin
        if IsRevalued(SalesHeader) and not _UserConfirmed then
            if SalesHeader."Currency Factor" <> _RevaluedKeptFactor then
                SalesHeader."Currency Factor" := _RevaluedKeptFactor;
        _RevaluedKeptFactor := 0;
        _ReReadAllowed := false;
        _UserConfirmed := false;
    end;

    local procedure IsRevalued(SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(
            (_RevaluedKeptFactor <> 0) and
            (SalesHeader."Document Type" = _RevaluedDocType) and
            (SalesHeader."No." = _RevaluedDocNo) and
            (SalesHeader."NPR Spfy Currency Factor" = _RevaluedKeptFactor));
    end;

    /// <summary>
    /// One re-read per permission. A currency code entered on a released document fails before BC reaches the re-read, so it is never granted one.
    /// </summary>
    local procedure ReReadAllowed(SalesHeader: Record "Sales Header") Result: Boolean
    begin
        Result := _ReReadAllowed and IsRevalued(SalesHeader);
        _ReReadAllowed := false;
    end;
}
