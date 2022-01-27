codeunit 6014568 "NPR POS Cust. Meth.: Balancing"
{
    Access = Internal;
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
        _POSWorkShiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        _POSUnit: Record "NPR POS Unit";
        _EodWorkShiftMode: Option XREPORT,ZREPORT,CLOSEWORKSHIFT;

    local procedure GetSectionBalancing() Balancing: JsonObject
    begin
        Balancing.Add('createdAt', Format(_POSWorkShiftCheckpoint."Created At"));
        Balancing.Add('directItemSalesCount', _POSWorkShiftCheckpoint."Direct Item Sales Line Count");
        Balancing.Add('directItemReturnCount', _POSWorkShiftCheckpoint."Direct Item Returns Line Count");
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
        OverviewSales.Add('directItemSalesLcy', _POSWorkShiftCheckpoint."Direct Item Sales (LCY)");
        OverviewSales.Add('directItemReturnsLcy', _POSWorkShiftCheckpoint."Direct Item Returns (LCY)");
        Overview.Add('sales', OverviewSales);

        OverviewCashMovement.Add('localCurrencyLcy', _POSWorkShiftCheckpoint."Local Currency (LCY)");
        OverviewCashMovement.Add('foreignCurrencyLcy', _POSWorkShiftCheckpoint."Foreign Currency (LCY)");
        Overview.Add('cashMovement', OverviewCashMovement);

        OverviewOtherPayments.Add('debtorPaymentLcy', _POSWorkShiftCheckpoint."Debtor Payment (LCY)");
        OverviewOtherPayments.Add('eftLcy', _POSWorkShiftCheckpoint."EFT (LCY)");
        OverviewOtherPayments.Add('glPaymentLcy', _POSWorkShiftCheckpoint."GL Payment (LCY)");
        Overview.Add('otherPayments', OverviewOtherPayments);

        OverviewVoucher.Add('redeemedVouchersLcy', _POSWorkShiftCheckpoint."Redeemed Vouchers (LCY)");
        OverviewVoucher.Add('issuedVouchersLcy', _POSWorkShiftCheckpoint."Issued Vouchers (LCY)");
        Overview.Add('voucher', OverviewVoucher);

        OverviewOther.Add('roundingLcy', _POSWorkShiftCheckpoint."Rounding (LCY)");
        OverviewOther.Add('binTransferOutAmountLcy', _POSWorkShiftCheckpoint."Bin Transfer Out Amount (LCY)");
        OverviewOther.Add('binTransferInAmountLcy', _POSWorkShiftCheckpoint."Bin Transfer In Amount (LCY)");
        Overview.Add('other', OverviewOther);

        OverviewCreditSales.Add('creditSalesCount', _POSWorkShiftCheckpoint."Credit Sales Count");
        OverviewCreditSales.Add('creditSalesAmountLcy', _POSWorkShiftCheckpoint."Credit Sales Amount (LCY)");
        OverviewCreditSales.Add('creditNetSalesAmountLcy', 100);
        Overview.Add('creditSales', OverviewCreditSales);

        OverviewDetails.Add('creditUnrealSaleAmtLcy', _POSWorkShiftCheckpoint."Credit Unreal. Sale Amt. (LCY)");
        OverviewDetails.Add('creditUnrealRetAmtLcy', _POSWorkShiftCheckpoint."Credit Unreal. Ret. Amt. (LCY)");
        OverviewDetails.Add('creditRealSaleAmtLcy', _POSWorkShiftCheckpoint."Credit Real. Sale Amt. (LCY)");
        OverviewDetails.Add('creditRealReturnAmtLcy', _POSWorkShiftCheckpoint."Credit Real. Return Amt. (LCY)");
        Overview.Add('details', OverviewDetails);
    end;

    local procedure GetSectionDiscount() Discount: JsonObject
    var
        DiscountAmounts: JsonObject;
        DiscountPercent: JsonObject;
        DiscountTotal: JsonObject;
    begin
        DiscountAmounts.Add('campaignDiscountLcy', _POSWorkShiftCheckpoint."Campaign Discount (LCY)");
        DiscountAmounts.Add('mixDiscountLcy', _POSWorkShiftCheckpoint."Mix Discount (LCY)");
        DiscountAmounts.Add('quantityDiscountLcy', _POSWorkShiftCheckpoint."Quantity Discount (LCY)");
        DiscountAmounts.Add('customDiscountLcy', _POSWorkShiftCheckpoint."Custom Discount (LCY)");
        DiscountAmounts.Add('bomDiscountLcy', _POSWorkShiftCheckpoint."BOM Discount (LCY)");
        DiscountAmounts.Add('customerDiscountLcy', _POSWorkShiftCheckpoint."Customer Discount (LCY)");
        DiscountAmounts.Add('lineDiscountLcy', _POSWorkShiftCheckpoint."Line Discount (LCY)");
        Discount.Add('discountAmounts', DiscountAmounts);

        DiscountPercent.Add('campaignDiscountPct', _POSWorkShiftCheckpoint."Campaign Discount %");
        DiscountPercent.Add('mixDiscountPct', _POSWorkShiftCheckpoint."Mix Discount %");
        DiscountPercent.Add('quantityDiscountPct', _POSWorkShiftCheckpoint."Quantity Discount %");
        DiscountPercent.Add('customDiscountPct', _POSWorkShiftCheckpoint."Custom Discount %");
        DiscountPercent.Add('bomDiscountPct', _POSWorkShiftCheckpoint."BOM Discount %");
        DiscountPercent.Add('customerDiscountPct', _POSWorkShiftCheckpoint."Customer Discount %");
        DiscountPercent.Add('lineDiscountPct', _POSWorkShiftCheckpoint."Line Discount %");
        Discount.Add('discountPercent', DiscountPercent);

        DiscountTotal.Add('totalDiscountLcy', _POSWorkShiftCheckpoint."Total Discount (LCY)");
        DiscountTotal.Add('totalDiscountPct', _POSWorkShiftCheckpoint."Total Discount %");
        Discount.Add('discountTotal', DiscountTotal);
    end;

    local procedure GetSectionTurnover() Turnover: JsonObject
    var
        TurnoverGeneral: JsonObject;
        TurnoverProfit: JsonObject;
        TurnoverDirect: JsonObject;
        TurnoverCredit: JsonObject;
    begin
        TurnoverGeneral.Add('turnoverLcy', _POSWorkShiftCheckpoint."Turnover (LCY)");
        TurnoverGeneral.Add('netTurnoverLcy', _POSWorkShiftCheckpoint."Net Turnover (LCY)");
        TurnoverGeneral.Add('netCostLcy', _POSWorkShiftCheckpoint."Net Cost (LCY)");
        Turnover.Add('general', TurnoverGeneral);

        TurnoverProfit.Add('profitAmountLcy', _POSWorkShiftCheckpoint."Profit Amount (LCY)");
        TurnoverProfit.Add('profitPct', _POSWorkShiftCheckpoint."Profit %");
        Turnover.Add('profit', TurnoverProfit);

        TurnoverDirect.Add('directTurnoverLcy', _POSWorkShiftCheckpoint."Direct Turnover (LCY)");
        TurnoverDirect.Add('directNetTurnoverLcy', _POSWorkShiftCheckpoint."Direct Net Turnover (LCY)");
        Turnover.Add('direct', TurnoverDirect);

        TurnoverCredit.Add('creditTurnoverLcy', _POSWorkShiftCheckpoint."Credit Turnover (LCY)");
        TurnoverCredit.Add('creditNetTurnoverLcy', _POSWorkShiftCheckpoint."Credit Net Turnover (LCY)");
        Turnover.Add('credit', TurnoverCredit);
    end;

    local procedure GetSectionTaxSummary() TaxSummary: JsonArray
    var
        Line: JsonObject;
        WorkShiftTaxCheckPoint: Record "NPR POS Worksh. Tax Checkp.";
    begin

        WorkShiftTaxCheckPoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', _POSWorkShiftCheckpoint."Entry No.");
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
        CoinTypeDescLbl: Label '%1 %2', Locked = true;
    begin
        POSPaymentBinCheckPoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', _POSWorkShiftCheckpoint."Entry No.");
        if (not POSPaymentBinCheckPoint.FindSet()) then
            exit;

        repeat
            CountingType.ReadFrom('{}');
            CountingType.Add('id', POSPaymentBinCheckPoint."Entry No.");
            CountingType.Add('paymentTypeNo', POSPaymentBinCheckPoint."Payment Type No.");
            CountingType.Add('description', POSPaymentBinCheckPoint.Description);
            CountingType.Add('difference', POSPaymentBinCheckPoint."Calculated Amount Incl. Float");
            CountingType.Add('calculatedAmount', POSPaymentBinCheckPoint."Calculated Amount Incl. Float");
            CountingType.Add('countedAmount', 0);

            PaymentMethodDenom.SetFilter("POS Payment Method Code", '=%1', POSPaymentBinCheckPoint."Payment Method No.");
            if (PaymentMethodDenom.FindSet()) then begin
                repeat
                    CoinType.ReadFrom('{}');
                    CountingType.Add('id', POSPaymentBinCheckPoint."Entry No.");
                    CoinType.Add('type', PaymentMethodDenom."Denomination Type");
                    CoinType.Add('description', StrSubstNo(CoinTypeDescLbl, PaymentMethodDenom.Denomination, PaymentMethodDenom."Denomination Type"));
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
        POSPaymentBinCheckPoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', _POSWorkShiftCheckpoint."Entry No.");
        if (not POSPaymentBinCheckPoint.FindSet()) then
            exit;

        repeat
            Line.ReadFrom('{}');
            Line.Add('id', POSPaymentBinCheckPoint."Entry No.");
            Line.Add('paymentTypeNo', POSPaymentBinCheckPoint."Payment Type No.");
            Line.Add('floatAmount', POSPaymentBinCheckPoint."Float Amount");
            Line.Add('transferredAmount', POSPaymentBinCheckPoint."Transfer In Amount" + POSPaymentBinCheckPoint."Transfer Out Amount");
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
    local procedure OnCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
    begin

        if (Method = 'BalancingGetState') then
            BalancingGetState(Context, POSSession, FrontEnd, Handled);

        if (Method = 'BalancingSetState') then
            BalancingSetState(Context, FrontEnd, Handled);

    end;

    local procedure BalancingGetState(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        Response: JsonObject;
        JsonText: Text;
        ResponseLbl: Label '%1 - %2', Locked = true;
        CheckpointEntryNo: Integer;
    begin

        Handled := true;
        Context.WriteTo(JsonText);

        CheckpointEntryNo := GetValueAsInteger(Context, 'endOfDayCheckpointEntryNo');

        _POSWorkShiftCheckpoint.get(CheckpointEntryNo);
        _POSUnit.Get(_POSWorkShiftCheckpoint."POS Unit No.");

        Response.Add('caption', StrSubstNo(ResponseLbl, _POSWorkShiftCheckpoint.TableCaption(), _POSWorkShiftCheckpoint."Entry No."));
        Response.Add('statistics', GetStatistics());
        Response.Add('cashCount', GetCashCount());
        Response.Add('isStatisticsEnabled', false);

        Response.WriteTo(JsonText);
        Message(JsonText);

        Handled := true;
        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
        POSSession.IsInAction();


    end;

    local procedure BalancingSetState(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        JsonText: Text;
        Response: JsonObject;
        CheckpointEntryNo: Integer;
    begin
        Handled := true;

        Context.WriteTo(JsonText);
        Message(JsonText);

        CheckpointEntryNo := GetValueAsInteger(Context, 'state.backEndContext.endOfDayCheckpointEntryNo');
        _POSWorkShiftCheckpoint.Get(CheckpointEntryNo);
        _POSUnit.Get(_POSWorkShiftCheckpoint."POS Unit No.");

        if (not GetValueAsBoolean(Context, 'confirmed')) then begin
            // User clicked cancel, balancing will be aborted. Return to invoking workflow
            POSManagePOSUnit.ReOpenLastPeriodRegister(_POSUnit."No.");
            FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
            exit;
        end;

        if (_POSWorkShiftCheckpoint.type = _POSWorkShiftCheckpoint.Type::ZREPORT) then
            FinalizeZReport(Context, CheckpointEntryNo);

        if (_POSWorkShiftCheckpoint.type = _POSWorkShiftCheckpoint.Type::XREPORT) then
            FinalizeXReport(CheckpointEntryNo);

        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);

    end;

    local procedure TransferCashCountToBinCheckpointRec(ClosingAndTransfer: JsonArray; var TempBinCheckpoint: Record "NPR POS Payment Bin Checkp." temporary)
    var
        CountedPayment: JsonToken;
        BinCheckpoint: Record "NPR POS Payment Bin Checkp.";
    begin
        foreach CountedPayment in ClosingAndTransfer do begin
            BinCheckpoint.Get(GetValueAsInteger(CountedPayment.AsObject(), 'id'));

            TempBinCheckpoint.TransferFields(BinCheckpoint, true);

            TempBinCheckpoint."Payment Type No." := CopyStr(GetValueAsText(CountedPayment.AsObject(), 'paymentTypeNo'), 1, MaxStrLen(TempBinCheckpoint."Payment Type No."));
            TempBinCheckpoint."New Float Amount" := GetValueAsDecimal(CountedPayment.AsObject(), 'newFloatAmount');

            TempBinCheckpoint."Bank Deposit Amount" := GetValueAsDecimal(CountedPayment.AsObject(), 'bankDepositAmount');
            TempBinCheckpoint."Bank Deposit Bin Code" := CopyStr(GetValueAsText(CountedPayment.AsObject(), 'bankDepositBinCode'), 1, MaxStrLen(TempBinCheckpoint."Bank Deposit Bin Code"));
            TempBinCheckpoint."Bank Deposit Reference" := CopyStr(GetValueAsText(CountedPayment.AsObject(), 'bankDepositReference'), 1, MaxStrLen(TempBinCheckpoint."Bank Deposit Reference"));

            TempBinCheckpoint."Move To Bin Amount" := GetValueAsDecimal(CountedPayment.AsObject(), 'moveToBinAmount');
            TempBinCheckpoint."Move To Bin Code" := CopyStr(GetValueAsText(CountedPayment.AsObject(), 'moveToBinNo'), 1, MaxStrLen(TempBinCheckpoint."Bank Deposit Bin Code"));
            TempBinCheckpoint."Move To Bin Reference" := CopyStr(GetValueAsText(CountedPayment.AsObject(), 'moveToBinTransId'), 1, MaxStrLen(TempBinCheckpoint."Bank Deposit Reference"));
            TempBinCheckpoint.Insert();
        end;
    end;

    local procedure TransferCountingToBinCheckpointRec(Counting: JsonArray; var TempBinCheckpoint: Record "NPR POS Payment Bin Checkp." temporary)
    var
        CountedPayment: JsonToken;
    begin
        foreach CountedPayment in Counting do begin
            TempBinCheckpoint.Get(GetValueAsInteger(CountedPayment.AsObject(), 'id'));

            TempBinCheckpoint."Counted Amount Incl. Float" := GetValueAsDecimal(CountedPayment.AsObject(), 'countedAmount');
            TempBinCheckpoint.Modify();
        end;
    end;

    internal procedure PrintEndOfDayReport(UnitNo: Code[10]; EntryNo: Integer)
    var
        POSEntry: Record "NPR POS Entry";
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        RecRef: RecordRef;
    begin
        if (not POSEntry.Get(EntryNo)) then
            exit;

        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::Balancing);

        POSWorkshiftCheckpoint.SetFilter("POS Entry No.", '=%1', EntryNo);
        POSWorkshiftCheckpoint.FindFirst();
        RecRef.GetTable(POSWorkshiftCheckpoint);

        RetailReportSelectionMgt.SetRegisterNo(UnitNo);
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Balancing (POS Entry)");
    end;

    local procedure GetValueAsText(JObject: JsonObject; KeyName: Text): Text
    var
        JToken: JsonToken;
    begin
        if (not JObject.SelectToken(KeyName, JToken)) then
            exit('');

        if (JToken.AsValue().IsNull()) then
            exit('');

        exit(JToken.AsValue().AsText());
    end;

    local procedure GetValueAsDecimal(JObject: JsonObject; KeyName: Text): Decimal
    var
        JToken: JsonToken;
    begin
        if (not JObject.SelectToken(KeyName, JToken)) then
            exit(0);

        if (JToken.AsValue().IsNull()) then
            exit(0);

        exit(JToken.AsValue().AsDecimal());
    end;

    local procedure GetValueAsInteger(JObject: JsonObject; KeyName: Text): Integer
    var
        JToken: JsonToken;
    begin
        if (not JObject.SelectToken(KeyName, JToken)) then
            exit(0);

        if (JToken.AsValue().IsNull()) then
            exit(0);

        exit(JToken.AsValue().AsInteger());
    end;

    local procedure GetValueAsBoolean(JObject: JsonObject; KeyName: Text): Boolean
    var
        JToken: JsonToken;
    begin
        if (not JObject.SelectToken(KeyName, JToken)) then
            exit(false);

        if (JToken.AsValue().IsNull()) then
            exit(false);

        exit(JToken.AsValue().AsBoolean());
    end;

    local procedure FinalizeZReport(Context: JsonObject; CheckpointEntryNo: Integer)
    var
        BinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        TempBinCheckpoint: Record "NPR POS Payment Bin Checkp." temporary;
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        CheckPointMgr: codeunit "NPR POS Workshift Checkpoint";
        AllPaymentMethodsConfirmed: Boolean;
        PaymentType: Code[10];
        SalesPersonCode: Code[10];
        BalanceEntryToPrint: Integer;
        DimId: Integer;
        ClosingEntryNo: Integer;
        ClosingAndTransfer: JsonArray;
        CountingArray: JsonArray;
        CashCountStatus: JsonObject;
        IsPaymentTypeConfirmed: JsonToken;
        JToken: JsonToken;
        UnexpectedJsonError: Label 'Invalid json returned by Balance View. Expected key %1 not found.';
        JPath: Text;
    begin
        JPath := 'state.cashCount.closingAndTransfer';
        if (not Context.SelectToken(JPath, JToken)) then
            Error(UnexpectedJsonError, JPath);
        ClosingAndTransfer := JToken.AsArray();
        TransferCashCountToBinCheckpointRec(ClosingAndTransfer, TempBinCheckpoint);

        JPath := 'state.cashCount.counting';
        if (not Context.SelectToken(JPath, JToken)) then
            Error(UnexpectedJsonError, JPath);
        CountingArray := JToken.AsArray();
        TransferCountingToBinCheckpointRec(CountingArray, TempBinCheckpoint);

        JPath := 'state.cashCount.confirmed';
        if (not Context.SelectToken(JPath, JToken)) then
            Error(UnexpectedJsonError, JPath);
        CashCountStatus := JToken.AsObject();
        AllPaymentMethodsConfirmed := true;
        foreach PaymentType in CashCountStatus.Keys() do begin
            CashCountStatus.Get(PaymentType, IsPaymentTypeConfirmed);
            TempBinCheckpoint.SetFilter("Payment Type No.", '=%1', PaymentType);
            TempBinCheckpoint.ModifyAll(Status, TempBinCheckpoint.Status::WIP);

            if (not IsPaymentTypeConfirmed.AsValue().AsBoolean()) then begin
                AllPaymentMethodsConfirmed := false;
                TempBinCheckpoint.ModifyAll(Status, TempBinCheckpoint.Status::WIP);
            end else begin
                TempBinCheckpoint.ModifyAll(Status, TempBinCheckpoint.Status::READY);
            end;
        end;

        TempBinCheckpoint.Reset();
        if (TempBinCheckpoint.FindSet()) then begin
            repeat
                BinCheckpoint.Get(TempBinCheckpoint."Entry No.");
                BinCheckpoint.TransferFields(TempBinCheckpoint, false);
                BinCheckpoint.Modify();
            until (TempBinCheckpoint.Next() = 0);
        end;

        if (AllPaymentMethodsConfirmed) then begin
            DimId := GetValueAsInteger(Context, 'state.backEndContext.DimensionSetId');
            SalesPersonCode := GetValueAsText(Context, 'state.backEndContext.SalesPersonCode');
            BalanceEntryToPrint := CheckPointMgr.CreateBalancingEntry(_EodWorkShiftMode::ZREPORT, _POSWorkShiftCheckpoint."POS Unit No.", CheckpointEntryNo, DimId);
            ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(_POSWorkShiftCheckpoint."POS Unit No.", SalesPersonCode);
            POSManagePOSUnit.ClosePOSUnitNo(_POSWorkShiftCheckpoint."POS Unit No.", ClosingEntryNo);
            Commit();

            PrintEndOfDayReport(_POSWorkShiftCheckpoint."POS Unit No.", BalanceEntryToPrint);
        end;
    end;

    local procedure FinalizeXReport(CheckpointEntryNo: Integer)
    var
        BinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        CheckPointMgr: codeunit "NPR POS Workshift Checkpoint";
        BalanceEntryToPrint: Integer;
    begin
        BinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', CheckpointEntryNo);
        BinCheckpoint.ModifyAll(Status, BinCheckpoint.Status::READY);
        BalanceEntryToPrint := CheckPointMgr.CreateBalancingEntry(_EodWorkShiftMode::XREPORT, _POSWorkShiftCheckpoint."POS Unit No.", CheckpointEntryNo, 0);
        Commit();

        PrintEndOfDayReport(_POSWorkShiftCheckpoint."POS Unit No.", BalanceEntryToPrint);
    end;
}
