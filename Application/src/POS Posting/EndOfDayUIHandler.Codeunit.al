﻿codeunit 6014568 "NPR End Of Day UI Handler"
{
    Access = Internal;

    var
        _POSWorkShiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        _POSUnit: Record "NPR POS Unit";
        _EodWorkShiftMode: Option XREPORT,ZREPORT,CLOSEWORKSHIFT;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    begin
        if (Method = 'BalancingGetState') then
            BalancingGetState(Context, FrontEnd, Handled);

        if (Method = 'BalancingSetState') then
            BalancingSetState(Context, Handled);
    end;

    local procedure GetEndOfDayContext(Context: JsonObject) EODContext: JsonObject
    begin
        EODContext.Add('createdAt', Format(_POSWorkShiftCheckpoint."Created At"));
        EODContext.Add('checkPointId', GetValueAsInteger(Context, 'checkPointId'));
        EODContext.Add('salesPersonCode', GetValueAsText(Context, 'salesPersonCode'));
        EODContext.Add('dimensionId', GetValueAsInteger(Context, 'dimensionId'));
    end;

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
        //OverviewCreditSales.Add('creditNetSalesAmountLcy', 100);
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
        TurnoverProfit.Add('profitPct', Round(_POSWorkShiftCheckpoint."Profit %", 0.01));
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
        PaymentMethod: Record "NPR POS Payment Method";
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

            if (PaymentMethod.Get(POSPaymentBinCheckPoint."Payment Method No.")) then begin
                if (PaymentMethod."Include In Counting" <> PaymentMethod."Include In Counting"::NO) then begin
                    CountingType.ReadFrom('{}');
                    CountingType.Add('id', POSPaymentBinCheckPoint."Entry No.");
                    CountingType.Add('paymentTypeNo', POSPaymentBinCheckPoint."Payment Type No.");
                    CountingType.Add('description', POSPaymentBinCheckPoint.Description);
                    CountingType.Add('difference', POSPaymentBinCheckPoint."Calculated Amount Incl. Float");
                    CountingType.Add('calculatedAmount', POSPaymentBinCheckPoint."Calculated Amount Incl. Float");
                    CountingType.Add('countedAmount', 0);

                    case (PaymentMethod."Include In Counting") of
                        PaymentMethod."Include In Counting"::YES:
                            CountingType.Add('includeInCounting', 'yes');
                        PaymentMethod."Include In Counting"::BLIND:
                            CountingType.Add('includeInCounting', 'blind');
                        PaymentMethod."Include In Counting"::VIRTUAL:
                            begin
                                CountingType.Add('includeInCounting', 'auto');
                                CountingType.Replace('countedAmount', POSPaymentBinCheckPoint."Calculated Amount Incl. Float");
                            end;
                    end;
                    CountingType.Add('disableDifferenceField', false);

                    PaymentMethodDenom.SetFilter("POS Payment Method Code", '=%1', POSPaymentBinCheckPoint."Payment Method No.");
                    if (PaymentMethodDenom.FindSet()) then begin
                        repeat
                            CoinType.ReadFrom('{}');
                            CoinType.Add('id', POSPaymentBinCheckPoint."Entry No.");
                            CoinType.Add('type', PaymentMethodDenom."Denomination Type");
                            CoinType.Add('description', StrSubstNo(CoinTypeDescLbl, PaymentMethodDenom.Denomination, PaymentMethodDenom."Denomination Type"));
                            CoinType.Add('value', PaymentMethodDenom.Denomination);
                            CoinTypes.Add(CoinType);
                        until (PaymentMethodDenom.Next() = 0);
                    end;

                    CountingType.Add('coinTypes', CoinTypes);
                    if (PaymentMethod."Include In Counting" in [PaymentMethod."Include In Counting"::YES, PaymentMethod."Include In Counting"::BLIND]) then
                        CashCounting.Add(CountingType);

                    if (PaymentMethod."Include In Counting" = PaymentMethod."Include In Counting"::VIRTUAL) then
                        if (PaymentMethod."Bin for Virtual-Count" = '') then
                            CashCounting.Add(CountingType);
                end;
            end;

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

    local procedure GetBins(BinType: Option) BinList: JsonArray
    var
        Bin: JsonObject;
        Bins: Record "NPR POS Payment Bin";
    begin
        if (BinType = 1) then
            Bins.SetFilter("Bin Type", '=%1', Bins."Bin Type"::BANK);
        if (BinType = 2) then
            Bins.SetFilter("Bin Type", '=%1', Bins."Bin Type"::SAFE);

        Bins.SetFilter("Attached to POS Unit No.", '=%1|=%2', '', _POSWorkShiftCheckpoint."POS Unit No.");
        if (Bins.FindSet()) then begin
            repeat
                Bin.ReadFrom('{}');
                Bin.Add('binCode', Bins."No.");
                Bin.Add('description', Bins.Description);
                BinList.Add(Bin);
            until (Bins.Next() = 0);
        end;
    end;

    local procedure GetAvailableBins() Bins: JsonObject
    begin
        Bins.ReadFrom('{}');
        Bins.Add('bankBins', GetBins(1));
        Bins.Add('otherBins', GetBins(2));
    end;

    local procedure BalancingGetState(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        EndOfDayProfile: Record "NPR POS End of Day Profile";
        Response: JsonObject;
        JsonText: Text;
        ResponseLbl: Label '%1 - %2', Locked = true;
        CheckpointEntryNo: Integer;
    begin

        Handled := true;
        Context.WriteTo(JsonText);

        CheckpointEntryNo := GetValueAsInteger(Context, 'checkPointId');

        _POSWorkShiftCheckpoint.get(CheckpointEntryNo);
        _POSUnit.Get(_POSWorkShiftCheckpoint."POS Unit No.");
        if (not EndOfDayProfile.Get(_POSUnit."POS End of Day Profile")) then
            EndOfDayProfile.Init();

        Response.Add('caption', StrSubstNo(ResponseLbl, _POSWorkShiftCheckpoint.TableCaption(), _POSWorkShiftCheckpoint."Entry No."));
        Response.Add('statistics', GetStatistics());
        Response.Add('cashCount', GetCashCount());
        Response.Add('bins', GetAvailableBins());
        Response.Add('isStatisticsEnabled', (EndOfDayProfile."Z-Report UI" = EndOfDayProfile."Z-Report UI"::SUMMARY_BALANCING));
        Response.Add('backendContext', GetEndOfDayContext(Context));

        Response.WriteTo(JsonText);

        Handled := true;
        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    local procedure BalancingSetState(Context: JsonObject; var Handled: Boolean);
    var
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSSession: Codeunit "NPR POS Session";
        JsonText: Text;
        CheckpointEntryNo: Integer;
    begin
        Handled := true;

        Context.WriteTo(JsonText);

        CheckpointEntryNo := GetValueAsInteger(Context, 'state.backendContext.checkPointId');
        _POSWorkShiftCheckpoint.Get(CheckpointEntryNo);
        _POSUnit.Get(_POSWorkShiftCheckpoint."POS Unit No.");

        if (not GetValueAsBoolean(Context, 'confirmed')) then begin
            // User clicked cancel, balancing will be aborted. Return to invoking workflow
            POSManagePOSUnit.ReOpenLastPeriodRegister(_POSUnit."No.");
            Commit();
            POSSession.ChangeViewLogin();
            exit;
        end;

        if (_POSWorkShiftCheckpoint.type = _POSWorkShiftCheckpoint.Type::ZREPORT) then
            FinalizeZReport(Context);

        if (_POSWorkShiftCheckpoint.type = _POSWorkShiftCheckpoint.Type::XREPORT) then
            FinalizeXReport();

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

    local procedure TransferCountingToBinCheckpointRec(Counting: JsonArray; var TempBinCheckpoint: Record "NPR POS Payment Bin Checkp." temporary; POSUnitNo: Code[10])
    var
        CountedPayment: JsonToken;
        ManualCountComment: Label 'Counted by %1', MaxLength = 25;
        Denominations: JsonArray;
        CoinTypesToken, Denomination : JsonToken;
        EODDenomination: Record "NPR EOD Denomination";
    begin
        foreach CountedPayment in Counting do begin
            TempBinCheckpoint.Get(GetValueAsInteger(CountedPayment.AsObject(), 'id'));

            TempBinCheckpoint."Counted Amount Incl. Float" := GetValueAsDecimal(CountedPayment.AsObject(), 'countedAmount');
            TempBinCheckpoint.Comment := StrSubstNo(ManualCountComment, CopyStr(UserId, 1, 25));
            TempBinCheckpoint.Modify();

            if (CountedPayment.AsObject().Get('coinTypes', CoinTypesToken)) then
                if (CoinTypesToken.IsArray) then begin
                    Denominations := CoinTypesToken.AsArray();
                    foreach Denomination in Denominations do begin
                        EODDenomination."POS Payment Method Code" := TempBinCheckpoint."Payment Method No.";
                        EODDenomination."POS Unit No." := POSUnitNo;
                        EODDenomination."Denomination Type" := GetValueAsInteger(Denomination.AsObject(), 'type');
                        EODDenomination.Denomination := GetValueAsDecimal(Denomination.AsObject(), 'value');
                        EODDenomination.Quantity := GetValueAsInteger(Denomination.AsObject(), 'quantity');
                        EODDenomination.Amount := EODDenomination.Denomination * EODDenomination.Quantity;
                        if (EODDenomination.Quantity <> 0) then
                            if (not EODDenomination.Insert()) then
                                ;
                    end;
                end;
        end;
    end;

    local procedure HandleVirtualCounting(var TempBinCheckpoint: Record "NPR POS Payment Bin Checkp." temporary)
    var
        PaymentMethod: Record "NPR POS Payment Method";
        POSPaymentBinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        VirtualCountComment: Label 'Virtual Count', MaxLength = 50;
    begin
        POSPaymentBinCheckPoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', _POSWorkShiftCheckpoint."Entry No.");
        if (not POSPaymentBinCheckPoint.FindSet()) then
            exit;

        repeat
            if (PaymentMethod.Get(POSPaymentBinCheckPoint."Payment Method No.")) then begin
                if ((PaymentMethod."Include In Counting" = PaymentMethod."Include In Counting"::VIRTUAL) and (PaymentMethod."Bin for Virtual-Count" <> '')) then begin
                    TempBinCheckpoint.TransferFields(POSPaymentBinCheckPoint, true);
                    TempBinCheckpoint."Bank Deposit Bin Code" := PaymentMethod."Bin for Virtual-Count";
                    TempBinCheckpoint."Bank Deposit Amount" := POSPaymentBinCheckPoint."Calculated Amount Incl. Float";
                    TempBinCheckpoint."Bank Deposit Reference" := StrSubstNo('%1 %2', PaymentMethod.Code, CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, 7));
                    TempBinCheckpoint."New Float Amount" := 0;
                    TempBinCheckpoint."Counted Amount Incl. Float" := POSPaymentBinCheckPoint."Calculated Amount Incl. Float";
                    TempBinCheckpoint.Comment := VirtualCountComment;
                    TempBinCheckpoint.Insert();
                end;
            end;
        until (POSPaymentBinCheckPoint.Next() = 0);
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

    local procedure FinalizeZReport(Context: JsonObject)
    var
        BinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        TempBinCheckpoint: Record "NPR POS Payment Bin Checkp." temporary;
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        CheckPointMgr: codeunit "NPR POS Workshift Checkpoint";
        EndOfDayWorker: Codeunit "NPR End Of Day Worker";
        SalesPersonCode: Code[10];
        BalanceEntryToPrint: Integer;
        DimId: Integer;
        ClosingEntryNo: Integer;
        ClosingAndTransfer: JsonArray;
        CountingArray: JsonArray;
        JToken: JsonToken;
        UnexpectedJsonError: Label 'Invalid json returned by Balance View. Expected key %1 not found.';
        JPath: Text;
        POSSession: Codeunit "NPR POS Session";
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
        TransferCountingToBinCheckpointRec(CountingArray, TempBinCheckpoint, _POSWorkShiftCheckpoint."POS Unit No.");
        HandleVirtualCounting(TempBinCheckpoint);

        TempBinCheckpoint.Reset();
        TempBinCheckpoint.ModifyAll(Status, TempBinCheckpoint.Status::READY);

        if (TempBinCheckpoint.FindSet()) then begin
            repeat
                BinCheckpoint.Get(TempBinCheckpoint."Entry No.");
                BinCheckpoint.TransferFields(TempBinCheckpoint, false);
                BinCheckpoint.Modify();
            until (TempBinCheckpoint.Next() = 0);
        end;

        // Warning when not all checkpoints have status READY? 

        DimId := GetValueAsInteger(Context, 'state.backendContext.dimensionId');
        SalesPersonCode := GetValueAsText(Context, 'state.backendContext.salesPersonCode');
        BalanceEntryToPrint := CheckPointMgr.CreateBalancingEntry(_EodWorkShiftMode::ZREPORT, _POSWorkShiftCheckpoint."POS Unit No.", _POSWorkShiftCheckpoint."Entry No.", DimId);
        ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(_POSWorkShiftCheckpoint."POS Unit No.", SalesPersonCode);
        POSManagePOSUnit.ClosePOSUnitNo(_POSWorkShiftCheckpoint."POS Unit No.", ClosingEntryNo);
        Commit();

        POSSession.ChangeViewLogin();
        EndOfDayWorker.PrintEndOfDayReport(_POSWorkShiftCheckpoint."POS Unit No.", BalanceEntryToPrint);
    end;

    local procedure FinalizeXReport()
    var
        BinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        CheckPointMgr: codeunit "NPR POS Workshift Checkpoint";
        BalanceEntryToPrint: Integer;
        POSSession: Codeunit "NPR POS Session";
        EndOfDayWorker: Codeunit "NPR End Of Day Worker";
    begin
        BinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', _POSWorkShiftCheckpoint."Entry No.");
        BinCheckpoint.ModifyAll(Status, BinCheckpoint.Status::READY);
        BalanceEntryToPrint := CheckPointMgr.CreateBalancingEntry(_EodWorkShiftMode::XREPORT, _POSWorkShiftCheckpoint."POS Unit No.", _POSWorkShiftCheckpoint."Entry No.", 0);
        Commit();

        POSSession.ChangeViewLogin();
        EndOfDayWorker.PrintEndOfDayReport(_POSWorkShiftCheckpoint."POS Unit No.", BalanceEntryToPrint);
    end;

}
