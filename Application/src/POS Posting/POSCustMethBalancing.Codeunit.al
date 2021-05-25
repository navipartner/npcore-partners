codeunit 6014568 "NPR POS Cust. Meth.: Balancing"
{
    // TODO: Delete the following explanation section when everything is done with this codeunit
    /*
        The purpose of this codeunit is to feed state to the front-end balancing view. The state is a JSON object that
        corresponds to content and structure explained in the specification document with case #310085, in the 2nd
        chapter "Proposed Screen Layout" (on page 5 and onwards).
        The state is one big JSON object that contains properties for each described balancing screen, section, subsection,
        and field, and all of them are identified with a JSON property name (a camelCase text, e.g. 'createdAt').
        For each JSON property in this codeunit, whenever a value is added, replace the hardcoded proof-of-concept value
        with an actual value calculated using the end-of-day procedures.
    */
    var
        _POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        _POSUnit: Record "NPR POS Unit";


    local procedure GetSectionBalancing() Balancing: JsonObject
    begin
        Balancing.Add('createdAt', Format(_POSWorkshiftCheckpoint."Created At"));
        Balancing.Add('directSalescount', _POSWorkshiftCheckpoint."Direct Item Sales Line Count"); // Check Name
        Balancing.Add('directItemsReturnLine', _POSWorkshiftCheckpoint."Direct Item Returns Line Count"); // Check Name
    end;

    local procedure GetSectionOverview() Overview: JsonObject
    var
        OverviewSales: JsonObject;
        OverviewCashMovement: JsonObject;
        OverviewOtherPayments: JsonObject;
        OverviewVoucher: JsonObject;
        OverviewOther: JsonObject;
        OverviewCreditSales: JsonObject;
        OverviewDetails: JsonObject;
    begin
        OverviewSales.Add('directItemSalesLcy', _POSWorkshiftCheckpoint."Direct Item Sales (LCY)");
        OverviewSales.Add('directItemReturnsLcy', _POSWorkshiftCheckpoint."Direct Item Returns (LCY)");
        Overview.Add('sales', OverviewSales);

        OverviewCashMovement.Add('localCurrencyLcy', _POSWorkshiftCheckpoint."Local Currency (LCY)");
        OverviewCashMovement.Add('foreignCurrencyLcy', _POSWorkshiftCheckpoint."Foreign Currency (LCY)");
        Overview.Add('cashMovement', OverviewCashMovement);

        OverviewOtherPayments.Add('debtorPaymentLcy', _POSWorkshiftCheckpoint."Debtor Payment (LCY)");
        OverviewOtherPayments.Add('eftLcy', _POSWorkshiftCheckpoint."EFT (LCY)");
        OverviewOtherPayments.Add('glPaymentLcy', _POSWorkshiftCheckpoint."GL Payment (LCY)");
        Overview.Add('otherPayments', OverviewOtherPayments);

        OverviewVoucher.Add('redeemedVouchersLcy', _POSWorkshiftCheckpoint."Redeemed Vouchers (LCY)");
        OverviewVoucher.Add('issuedVouchersLcy', _POSWorkshiftCheckpoint."Issued Vouchers (LCY)");
        Overview.Add('voucher', OverviewVoucher);

        OverviewOther.Add('roundingLcy', _POSWorkshiftCheckpoint."Rounding (LCY)");
        OverviewOther.Add('binTransferOutAmountLcy', _POSWorkshiftCheckpoint."Bin Transfer Out Amount (LCY)");
        OverviewOther.Add('binTransferInAmountLcy', _POSWorkshiftCheckpoint."Bin Transfer In Amount (LCY)");
        Overview.Add('other', OverviewOther);

        OverviewCreditSales.Add('creditSalesCountLcy', _POSWorkshiftCheckpoint."Credit Sales Count"); // Check Name
        OverviewCreditSales.Add('creditSalesAmountLcy', _POSWorkshiftCheckpoint."Credit Sales Amount (LCY)");
        OverviewCreditSales.Add('creditNetSalesAmountLcy', 100);
        Overview.Add('creditSales', OverviewCreditSales);

        OverviewDetails.Add('creditUnrealSaleAmtLcy', _POSWorkshiftCheckpoint."Credit Unreal. Sale Amt. (LCY)");
        OverviewDetails.Add('creditUnrealRetAmtLcy', _POSWorkshiftCheckpoint."Credit Unreal. Ret. Amt. (LCY)");
        OverviewDetails.Add('creditRealSaleAmtLcy', _POSWorkshiftCheckpoint."Credit Real. Sale Amt. (LCY)");
        OverviewDetails.Add('creditRealReturnAmtLcy', _POSWorkshiftCheckpoint."Credit Real. Return Amt. (LCY)");
        Overview.Add('details', OverviewDetails);
    end;

    local procedure GetSectionDiscount() Discount: JsonObject
    var
        DiscountAmounts: JsonObject;
        DiscountPercent: JsonObject;
        DiscountTotal: JsonObject;
    begin
        DiscountAmounts.Add('campaignDiscountLcy', _POSWorkshiftCheckpoint."Campaign Discount (LCY)");
        DiscountAmounts.Add('mixDiscountLcy', _POSWorkshiftCheckpoint."Mix Discount (LCY)");
        DiscountAmounts.Add('quantityDiscountLcy', _POSWorkshiftCheckpoint."Quantity Discount (LCY)");
        DiscountAmounts.Add('customDiscountLcy', _POSWorkshiftCheckpoint."Custom Discount (LCY)");
        DiscountAmounts.Add('bomDiscountLcy', _POSWorkshiftCheckpoint."BOM Discount (LCY)");
        DiscountAmounts.Add('customerDiscountLcy', _POSWorkshiftCheckpoint."Customer Discount (LCY)");
        DiscountAmounts.Add('lineDiscountLcy', _POSWorkshiftCheckpoint."Line Discount (LCY)");
        Discount.Add('discountAmounts', DiscountAmounts);

        DiscountPercent.Add('campaignDiscountPct', _POSWorkshiftCheckpoint."Campaign Discount %");
        DiscountPercent.Add('mixDiscountPct', _POSWorkshiftCheckpoint."Mix Discount %");
        DiscountPercent.Add('quantityDiscountPct', _POSWorkshiftCheckpoint."Quantity Discount %");
        DiscountPercent.Add('customDiscountPct', _POSWorkshiftCheckpoint."Custom Discount %");
        DiscountPercent.Add('bomDiscountPct', _POSWorkshiftCheckpoint."BOM Discount %");
        DiscountPercent.Add('customerDiscountPct', _POSWorkshiftCheckpoint."Customer Discount %");
        DiscountPercent.Add('lineDiscountPct', _POSWorkshiftCheckpoint."Line Discount %");
        Discount.Add('discountPercent', DiscountPercent);

        DiscountTotal.Add('totalDiscountLcy', _POSWorkshiftCheckpoint."Total Discount (LCY)");
        DiscountTotal.Add('totalDiscountPct', _POSWorkshiftCheckpoint."Total Discount %");
        Discount.Add('discountTotal', DiscountTotal);
    end;

    local procedure GetSectionTurnover() Turnover: JsonObject
    var
        TurnoverGeneral: JsonObject;
        TurnoverProfit: JsonObject;
        TurnoverDirect: JsonObject;
        TurnoverCredit: JsonObject;
    begin
        TurnoverGeneral.Add('turnoverLcy', _POSWorkshiftCheckpoint."Turnover (LCY)");
        TurnoverGeneral.Add('netTurnoverLcy', _POSWorkshiftCheckpoint."Net Turnover (LCY)");
        TurnoverGeneral.Add('netCostLcy', _POSWorkshiftCheckpoint."Net Cost (LCY)");
        Turnover.Add('general', TurnoverGeneral);

        TurnoverProfit.Add('profitAmountLcy', _POSWorkshiftCheckpoint."Profit Amount (LCY)");
        TurnoverProfit.Add('profitPct', _POSWorkshiftCheckpoint."Profit %");
        Turnover.Add('profit', TurnoverProfit);

        TurnoverDirect.Add('directTurnoverLcy', _POSWorkshiftCheckpoint."Direct Turnover (LCY)");
        TurnoverDirect.Add('directNetTurnoverLcy', _POSWorkshiftCheckpoint."Direct Net Turnover (LCY)");
        Turnover.Add('direct', TurnoverDirect);

        TurnoverCredit.Add('creditTurnoverLcy', _POSWorkshiftCheckpoint."Credit Turnover (LCY)");
        TurnoverCredit.Add('creditNetTurnoverLcy', _POSWorkshiftCheckpoint."Credit Net Turnover (LCY)");
        Turnover.Add('credit', TurnoverCredit);
    end;

    local procedure GetSectionTaxSummary() TaxSummary: JsonArray
    var
        Line: JsonObject;
        WorkShiftTaxCheckPoint: Record "NPR POS Worksh. Tax Checkp.";
    begin

        WorkShiftTaxCheckPoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', _POSWorkshiftCheckpoint."Entry No.");
        if (not WorkShiftTaxCheckPoint.FindSet()) then
            exit;

        repeat
            Line.ReadFrom('{}');
            Line.Add('taxIdentifier', WorkShiftTaxCheckPoint."VAT Identifier");
            Line.Add('taxPct', WorkShiftTaxCheckPoint."Tax %");
            Line.Add('taxBaseAmount', WorkShiftTaxCheckPoint."Tax Base Amount");
            Line.Add('taxAmount', WorkShiftTaxCheckPoint."Tax Amount");
            Line.Add('amountIncludingTax', WorkShiftTaxCheckPoint."Amount Including Tax");
            TaxSummary.Add(Line);
        until (WorkShiftTaxCheckPoint.Next() = 0);
    end;

    local procedure GetStatistics() Statistics: JsonObject
    begin
        Statistics.Add('balancing', GetSectionBalancing());
        Statistics.Add('overview', GetSectionOverview());
        Statistics.Add('discount', GetSectionDiscount());
        Statistics.Add('turnover', GetSectionTurnover());
        Statistics.Add('taxSummary', GetSectionTaxSummary());
    end;

    local procedure GetCashCountingTypes() CashCounting: JsonArray
    var
        CountingType: JsonObject;
        CoinTypes: JsonArray;
        CoinType: JsonObject;
        POSPaymentBinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        PaymentMethodDenom: Record "NPR Payment Method Denom";
    begin
        POSPaymentBinCheckPoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', _POSWorkshiftCheckpoint."Entry No.");
        if (not POSPaymentBinCheckPoint.FindSet()) then
            exit;

        repeat
            CountingType.ReadFrom('{}');
            CountingType.Add('paymentTypeNo', POSPaymentBinCheckPoint."Payment Type No.");
            CountingType.Add('description', POSPaymentBinCheckPoint.Description);
            CountingType.Add('difference', POSPaymentBinCheckPoint."Calculated Amount Incl. Float");
            CountingType.Add('calculatedAmount', POSPaymentBinCheckPoint."Calculated Amount Incl. Float");
            CountingType.Add('countedAmount', 0);

            PaymentMethodDenom.SetFilter("POS Payment Method Code", '=%1', POSPaymentBinCheckPoint."Payment Method No.");
            if (PaymentMethodDenom.FindSet()) then begin
                repeat
                    CoinType.ReadFrom('{}');
                    CoinType.Add('type', PaymentMethodDenom."Denomination Type");
                    CoinType.Add('description', StrSubstNo('%1 %2', PaymentMethodDenom.Denomination, PaymentMethodDenom."Denomination Type"));
                    CoinType.Add('value', PaymentMethodDenom.Denomination);
                    CoinTypes.Add(CoinType);
                until (PaymentMethodDenom.Next() = 0);
            end;

            CountingType.Add('coinTypes', CoinTypes);
            CashCounting.Add(CountingType);

        until (POSPaymentBinCheckPoint.Next() = 0);
    end;

    local procedure GetClosingAndTransfer() ClosingAndTransfer: JsonArray
    var
        Line: JsonObject;
        POSPaymentBinCheckPoint: Record "NPR POS Payment Bin Checkp.";
    begin
        POSPaymentBinCheckPoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', _POSWorkshiftCheckpoint."Entry No.");
        if (not POSPaymentBinCheckPoint.FindSet()) then
            exit;

        repeat
            Line.ReadFrom('{}');
            Line.Add('paymentTypeNo', POSPaymentBinCheckPoint."Payment Type No.");
            Line.Add('floatAmount', POSPaymentBinCheckPoint."Float Amount");
            Line.Add('transferedAmount', POSPaymentBinCheckPoint."Transfer In Amount" + POSPaymentBinCheckPoint."Transfer Out Amount"); // Check Spelling - Net Transferred Amount
            Line.Add('calculatedAmount', POSPaymentBinCheckPoint."Calculated Amount Incl. Float");
            Line.Add('newFloatAmount', POSPaymentBinCheckPoint."New Float Amount");
            Line.Add('bankDepositAmount', POSPaymentBinCheckPoint."Bank Deposit Amount");
            Line.Add('bankDepositBinCode', POSPaymentBinCheckPoint."Bank Deposit Bin Code");
            Line.Add('bankDepositReference', POSPaymentBinCheckPoint."Bank Deposit Reference");
            Line.Add('moveToBinAmount', POSPaymentBinCheckPoint."Move to Bin Amount");
            Line.Add('moveToBinNo', POSPaymentBinCheckPoint."Move to Bin Code");
            Line.Add('moveToBinTransId', POSPaymentBinCheckPoint."Move to Bin Reference");
            ClosingAndTransfer.Add(Line);
        until (POSPaymentBinCheckPoint.Next() = 0);

    end;

    local procedure GetCashCount() CashCount: JsonObject
    begin
        CashCount.Add('counting', GetCashCountingTypes());
        CashCount.Add('closingAndTransfer', GetClosingAndTransfer());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    procedure OnCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        Response: JsonObject;
        JsonText: Text;
    begin
        if Method <> 'BalancingGetState' then
            exit;

        Handled := true;

        Context.WriteTo(JsonText);
        _POSWorkshiftCheckpoint.FindLast();
        _POSUnit.Get(_POSWorkshiftCheckpoint."POS Unit No.");

        Response.Add('caption', StrSubstNo('%1 - %2', _POSWorkshiftCheckpoint.TableCaption(), _POSWorkshiftCheckpoint."Entry No."));
        Response.Add('statistics', GetStatistics());
        Response.Add('cashCount', GetCashCount());
        Response.Add('isStatisticsEnabled', false);

        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);

        Message('Context is: ' + JsonText);
        Message('%1 - %2', _POSWorkshiftCheckpoint."Entry No.", _POSWorkshiftCheckpoint."Created At");
    end;
}
