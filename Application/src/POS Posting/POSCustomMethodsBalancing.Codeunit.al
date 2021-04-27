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

    local procedure GetSectionBalancing() Balancing: JsonObject
    begin
        Balancing.Add('createdAt', CurrentDateTime);
        Balancing.Add('directSalescount', 100);
        Balancing.Add('directItemsReturnLine', 100);
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
        OverviewSales.Add('directItemSalesLcy', 100);
        OverviewSales.Add('directItemReturnsLcy', 100);
        Overview.Add('sales', OverviewSales);

        OverviewCashMovement.Add('localCurrencyLcy', 100);
        OverviewCashMovement.Add('foreignCurrencyLcy', 100);
        Overview.Add('cashMovement', OverviewCashMovement);

        OverviewOtherPayments.Add('doctorPaymentLcy', 100);
        OverviewOtherPayments.Add('eftLcy', 100);
        OverviewOtherPayments.Add('glPaymentLcy', 100);
        Overview.Add('otherPayments', OverviewOtherPayments);

        OverviewVoucher.Add('redeemedVouchersLcy', 100);
        OverviewVoucher.Add('issuedVouchersLcy', 100);
        Overview.Add('voucher', OverviewVoucher);

        OverviewOther.Add('roundingLcy', 100);
        OverviewOther.Add('binTransferOutAmountLcy', 100);
        OverviewOther.Add('binTransferInAmountLcy', 100);
        Overview.Add('other', OverviewOther);

        OverviewCreditSales.Add('creditSalesCountLcy', 100);
        OverviewCreditSales.Add('creditSalesAmountLcy', 100);
        OverviewCreditSales.Add('creditNetSalesAmountLcy', 100);
        Overview.Add('creditSales', OverviewCreditSales);

        OverviewDetails.Add('creditUnrealSaleAmtLcy', 100);
        OverviewDetails.Add('creditUnrealRetAmtLcy', 100);
        OverviewDetails.Add('creditRealSaleAmtLcy', 100);
        OverviewDetails.Add('creditRealReturnAmtLcy', 100);
        Overview.Add('details', OverviewDetails);
    end;

    local procedure GetSectionDiscount() Discount: JsonObject
    var
        DiscountAmounts: JsonObject;
        DiscountPercent: JsonObject;
        DiscountTotal: JsonObject;
    begin
        DiscountAmounts.Add('campaignDiscountLcy', 100);
        DiscountAmounts.Add('mixDiscountLcy', 100);
        DiscountAmounts.Add('quantityDiscountLcy', 100);
        DiscountAmounts.Add('customDiscountLcy', 100);
        DiscountAmounts.Add('bomDiscountLcy', 100);
        DiscountAmounts.Add('customerDiscountLcy', 100);
        DiscountAmounts.Add('lineDiscountLcy', 100);
        Discount.Add('discountAmounts', DiscountAmounts);

        DiscountPercent.Add('campaignDiscountPct', 100);
        DiscountPercent.Add('mixDiscountPct', 100);
        DiscountPercent.Add('quantityDiscountPct', 100);
        DiscountPercent.Add('customDiscountPct', 100);
        DiscountPercent.Add('bomDiscountPct', 100);
        DiscountPercent.Add('customerDiscountPct', 100);
        DiscountPercent.Add('lineDiscountPct', 100);
        Discount.Add('discountPercent', DiscountPercent);

        DiscountTotal.Add('totalDiscountLcy', 100);
        DiscountTotal.Add('totalDiscountPct', 100);
        Discount.Add('discountTotal', DiscountTotal);
    end;

    local procedure GetSectionTurnover() Turnover: JsonObject
    var
        TurnoverGeneral: JsonObject;
        TurnoverProfit: JsonObject;
        TurnoverDirect: JsonObject;
        TurnoverCredit: JsonObject;
    begin
        TurnoverGeneral.Add('turnoverLcy', 100);
        TurnoverGeneral.Add('netTurnoverLcy', 100);
        TurnoverGeneral.Add('netCostLcy', 100);
        Turnover.Add('general', TurnoverGeneral);

        TurnoverProfit.Add('profitAmountLcy', 100);
        TurnoverProfit.Add('profitPct', 100);
        Turnover.Add('profit', TurnoverProfit);

        TurnoverDirect.Add('directTurnoverLcy', 100);
        TurnoverDirect.Add('directNetTurnoverLcy', 100);
        Turnover.Add('direct', TurnoverDirect);

        TurnoverCredit.Add('creditTurnoverLcy', 100);
        TurnoverCredit.Add('creditNetTurnoverLcy', 100);
        Turnover.Add('credit', TurnoverCredit);
    end;

    local procedure GetSectionTaxSummary() TaxSummary: JsonArray
    var
        Line: JsonObject;
    begin
        // TODO: For each tax summary line, there should be one Line object added to the TaxSummary array
        Line.Add('taxIdentifier', 'VAT25');
        Line.Add('taxPct', 25);
        Line.Add('taxBaseAmount', 100);
        Line.Add('taxAmount', 100);
        Line.Add('amountIncludingTax', 100);
        TaxSummary.Add(Line);
    end;

    local procedure GetStatistics() Statistics: JsonObject
    var
        Balancing: JsonObject;
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
    begin
        // TODO: For each counting type (e.g. EURO, K, etc.) there should be one CountingType object added to the CashCounting array
        CountingType.Add('paymentTypeNo', 'EURO');
        CountingType.Add('description', 'EURO');
        CountingType.Add('difference', 100);
        CountingType.Add('calculatedAmount', 100);
        CountingType.Add('countedAmount', 100);
        // TODO: For each coin type, there should be a line with coin type identifier added to the CoinTypes array
        CoinTypes.Add('0.5');
        CoinTypes.Add('1.0');
        CoinTypes.Add('2.0');
        CoinTypes.Add('5.0');
        CoinTypes.Add('10.0');
        CoinTypes.Add('20.0');
        CoinTypes.Add('50.0');
        CoinTypes.Add('100.0');
        CoinTypes.Add('200.0');
        CoinTypes.Add('500.0');
        CoinTypes.Add('1000.0');
        CountingType.Add('coinTypes', CoinTypes);
        CashCounting.Add(CountingType);
    end;

    local procedure GetClosingAndTransfer() ClosingAndTransfer: JsonArray
    var
        Line: JsonObject;
    begin
        // TODO: For each closing and transfer line (e.g. EURO, GPB, K, NOR, ...) there should be one Line object added to the ClosingAndTransfer array
        Line.Add('paymentTypeNo', 'EURO');
        Line.Add('floatAmount', 100);
        Line.Add('transferedAmount', 100);
        Line.Add('calculatedAmount', 100);
        Line.Add('newFloatAmount', 100);
        Line.Add('bankDepositAmount', 100);
        Line.Add('bankDepositBinCode', '');
        Line.Add('bankDepositReference', '');
        Line.Add('moveToBinAmount', 100);
        Line.Add('moveToBinNo', '');
        Line.Add('moveToBinTransId', '');
        ClosingAndTransfer.Add(Line);
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
    begin
        if Method <> 'BalancingGetState' then
            exit;

        Handled := true;

        Response.Add('caption', 'Workshift Details - 484');
        Response.Add('statistics', GetStatistics());
        Response.Add('cashCount', GetCashCount());

        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;
}
