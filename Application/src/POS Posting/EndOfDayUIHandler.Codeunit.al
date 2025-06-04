codeunit 6014568 "NPR End Of Day UI Handler"
{
    Access = Internal;

    var
        _POSWorkShiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        _POSUnit: Record "NPR POS Unit";
        _EodWorkShiftMode: Option XREPORT,ZREPORT,CLOSEWORKSHIFT;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    begin
        case Method of
            'BalancingGetState':
                BalancingGetState(Context, FrontEnd);
            'BalancingSetState':
                BalancingSetState(Context);
            else
                exit;
        end;
        Handled := true;
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
        OverviewSales.Add('directSalesCount', _POSWorkShiftCheckpoint."Direct Sales Count");
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
        OverviewCreditSales.Add('creditNetSalesAmountLcy', _POSWorkShiftCheckpoint."Credit Net Sales Amount (LCY)");
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

    local procedure GetCashCountingTypes(EndOfDayProfile: Record "NPR POS End of Day Profile"; POSUnitNo: Code[10]) CashCounting: JsonArray
    var
        PaymentMethod: Record "NPR POS Payment Method";
        CountingType: JsonObject;
        CoinTypes: JsonArray;
        CoinType: JsonObject;
        POSPaymentBinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        PaymentMethodDenom: Record "NPR Payment Method Denom";
        PaymentMethodProcessingTypeIsCash: Boolean;
        CoinTypeDescLbl: Label '%1 %2', Locked = true;
    begin
        POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
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
                            if (EndOfDayProfile."Force Blind Counting") then
                                CountingType.Add('includeInCounting', 'blind') else
                                CountingType.Add('includeInCounting', 'yes');
                        PaymentMethod."Include In Counting"::BLIND:
                            CountingType.Add('includeInCounting', 'blind');
                        PaymentMethod."Include In Counting"::VIRTUAL:
                            begin
                                CountingType.Add('includeInCounting', 'auto');
                                CountingType.Replace('countedAmount', POSPaymentBinCheckPoint."Calculated Amount Incl. Float");
                            end;
                    end;
                    CountingType.Add('disableDifferenceField', EndOfDayProfile.DisableDifferenceField);

                    PaymentMethodProcessingTypeIsCash := (PaymentMethod."Processing Type" = PaymentMethod."Processing Type"::CASH);
                    CountingType.Add('requireCountedAmtDenominations', (EndOfDayProfile."Require Denomin.(Counted Amt.)" and PaymentMethodProcessingTypeIsCash));
                    CountingType.Add('requireBankDepositAmtDenominations', (EndOfDayProfile."Require Denomin.(Bank Deposit)" and PaymentMethodProcessingTypeIsCash));
                    CountingType.Add('requireMoveToBinAmtDenominations', (EndOfDayProfile."Require Denomin. (Move to Bin)" and PaymentMethodProcessingTypeIsCash));
                    CountingType.Add('bankDepositRef', GetReferenceNo(Enum::"NPR Reference No. Target"::EOD_BankDeposit, EndOfDayProfile, POSUnitNo, PaymentMethod.Code, _POSWorkShiftCheckpoint."Entry No."));
                    CountingType.Add('moveToBinRef', GetReferenceNo(Enum::"NPR Reference No. Target"::EOD_MoveToBin, EndOfDayProfile, POSUnitNo, PaymentMethod.Code, _POSWorkShiftCheckpoint."Entry No."));

                    Clear(CoinTypes);
                    PaymentMethodDenom.SetFilter("POS Payment Method Code", '=%1', POSPaymentBinCheckPoint."Payment Method No.");
                    PaymentMethodDenom.SetRange(Blocked, false);
                    if (PaymentMethodDenom.FindSet()) then begin
                        repeat
                            CoinType.ReadFrom('{}');
                            CoinType.Add('id', POSPaymentBinCheckPoint."Entry No.");
                            CoinType.Add('type', PaymentMethodDenom."Denomination Type".AsInteger());
                            CoinType.Add('description', StrSubstNo(CoinTypeDescLbl, PaymentMethodDenom.Denomination, PaymentMethodDenom."Denomination Type"));
                            CoinType.Add('variation', PaymentMethodDenom."Denomination Variant ID");
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

    internal procedure GetReferenceNo(RefNoTarget: Enum "NPR Reference No. Target"; EndOfDayProfile: Record "NPR POS End of Day Profile"; POSUnitNo: Code[10]; POSPmtMethodCode: Code[10]; CheckpointEntryNo: Integer): Text
    var
        RefNoAssignment: Interface "NPR Reference No. Assignment";
        RefNoAssignmentHelper: Codeunit "NPR Ref.No. Assignment Helper";
        AssignmentMethod: Enum "NPR Ref.No. Assignment Method";
        Parameters: Dictionary of [Text, Text];
    begin
        case RefNoTarget of
            RefNoTarget::EOD_BankDeposit:
                AssignmentMethod := EndofDayProfile."Bank Deposit Ref. Asgmt.";
            RefNoTarget::EOD_MoveToBin:
                AssignmentMethod := EndofDayProfile."Move to Bin Ref. Asgmt.";
            RefNoTarget::BT_OUT_BankDeposit:
                AssignmentMethod := EndofDayProfile."BT OUT: Bank Dep. Ref. Asgmt.";
            RefNoTarget::BT_OUT_MoveToBin:
                AssignmentMethod := EndofDayProfile."BT OUT: Move to Bin Ref.Asgmt.";
            RefNoTarget::BT_IN_FromBank:
                AssignmentMethod := EndofDayProfile."BT IN: Tr.from Bank Ref.Asgmt.";
            RefNoTarget::BT_IN_FromBin:
                AssignmentMethod := EndofDayProfile."BT IN: Move fr. Bin Ref.Asgmt.";
        end;
        Parameters.Add(RefNoAssignmentHelper.PosUnitNoParam(), POSUnitNo);
        Parameters.Add(RefNoAssignmentHelper.PosPmtMethodCodeParam(), POSPmtMethodCode);
        Parameters.Add(RefNoAssignmentHelper.CheckpointEntryNoParam(), Format(CheckpointEntryNo, 0, 9));
        RefNoAssignmentHelper.OnGenerateParameterDictionary(RefNoTarget, EndOfDayProfile, AssignmentMethod, Parameters);
        RefNoAssignment := AssignmentMethod;
        exit(RefNoAssignment.GetReferenceNo(EndOfDayProfile, RefNoTarget, Parameters));
    end;

    local procedure GetClosingAndTransfer() ClosingAndTransfer: JsonArray
    var
        Line: JsonObject;
        POSPaymentBinCheckPoint: Record "NPR POS Payment Bin Checkp.";
    begin
        POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
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

    local procedure GetCashCount(EndOfDayProfile: Record "NPR POS End of Day Profile"; POSUnitNo: Code[10]) CashCount: JsonObject
    begin
        CashCount.Add('counting', GetCashCountingTypes(EndOfDayProfile, POSUnitNo));
        CashCount.Add('closingAndTransfer', GetClosingAndTransfer());
    end;

    local procedure GetBins(BinType: Option; PosUnitNo: Code[10]; IncludedCashDrawerBins: Boolean) BinList: JsonArray
    var
        Bin: JsonObject;
        Bins: Record "NPR POS Payment Bin";
    begin
        if (BinType = 1) then
            Bins.SetFilter("Bin Type", '=%1', Bins."Bin Type"::BANK);
        if (BinType = 2) then
            if IncludedCashDrawerBins then
                Bins.SetFilter("Bin Type", '=%1|=%2', Bins."Bin Type"::CASH_DRAWER, Bins."Bin Type"::SAFE)
            else
                Bins.SetFilter("Bin Type", '=%1', Bins."Bin Type"::SAFE);

        if (Bins.FindSet()) then begin
            repeat
                if ((Bins."Bin Type" in [Bins."Bin Type"::BANK, Bins."Bin Type"::SAFE]) and (Bins."Attached to POS Unit No." in ['', PosUnitNo]))
                   or
                   ((Bins."Bin Type" = Bins."Bin Type"::CASH_DRAWER) and (Bins."Attached to POS Unit No." <> PosUnitNo))  //only applicable for transfer outs
                then begin
                    Bin.ReadFrom('{}');
                    Bin.Add('binCode', Bins."No.");
                    Bin.Add('description', Bins.Description);
                    BinList.Add(Bin);
                end;
            until (Bins.Next() = 0);
        end;
    end;

    procedure GetAvailableBins(PosUnitNo: Code[10]; IncludedCashDrawerBins: Boolean) Bins: JsonObject
    begin
        Bins.ReadFrom('{}');
        Bins.Add('bankBins', GetBins(1, PosUnitNo, false));
        Bins.Add('otherBins', GetBins(2, PosUnitNo, IncludedCashDrawerBins));
    end;

    local procedure BalancingGetState(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EndOfDayProfile: Record "NPR POS End of Day Profile";
        Response: JsonObject;
        ResponseLbl: Label '%1 - %2', Locked = true;
        CheckpointEntryNo: Integer;
    begin
        CheckpointEntryNo := GetValueAsInteger(Context, 'checkPointId');

        _POSWorkShiftCheckpoint.get(CheckpointEntryNo);
        _POSUnit.Get(_POSWorkShiftCheckpoint."POS Unit No.");
        _POSUnit.GetProfile(EndOfDayProfile);

        Response.Add('caption', StrSubstNo(ResponseLbl, _POSWorkShiftCheckpoint.TableCaption(), _POSWorkShiftCheckpoint."Entry No."));
        Response.Add('statistics', GetStatistics());
        Response.Add('cashCount', GetCashCount(EndOfDayProfile, _POSWorkShiftCheckpoint."POS Unit No."));
        Response.Add('bins', GetAvailableBins(_POSWorkShiftCheckpoint."POS Unit No.", false));
        Response.Add('isStatisticsEnabled', (EndOfDayProfile."Z-Report UI" = EndOfDayProfile."Z-Report UI"::SUMMARY_BALANCING));
        Response.Add('hideTurnover', EndOfDayProfile."Hide Turnover Section");
        Response.Add('backendContext', GetEndOfDayContext(Context));
        Response.Add('reportType', _POSWorkShiftCheckpoint.Type);

        FrontEnd.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    local procedure BalancingSetState(Context: JsonObject)
    var
        POSSession: Codeunit "NPR POS Session";
        CheckpointEntryNo: Integer;
    begin
        CheckpointEntryNo := GetValueAsInteger(Context, 'state.backendContext.checkPointId');
        _POSWorkShiftCheckpoint.Get(CheckpointEntryNo);
        _POSUnit.Get(_POSWorkShiftCheckpoint."POS Unit No.");

        if (not GetValueAsBoolean(Context, 'confirmed')) then begin
            // User clicked cancel, balancing will be aborted. Return to invoking workflow
            RestorePOSUnitStatus(_POSWorkShiftCheckpoint);
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
            TempBinCheckpoint."Move To Bin Code" := CopyStr(GetValueAsText(CountedPayment.AsObject(), 'moveToBinNo'), 1, MaxStrLen(TempBinCheckpoint."Move To Bin Code"));
            TempBinCheckpoint."Move To Bin Reference" := CopyStr(GetValueAsText(CountedPayment.AsObject(), 'moveToBinTransId'), 1, MaxStrLen(TempBinCheckpoint."Move To Bin Reference"));
            TempBinCheckpoint.Insert();

            TransferDenominations(CountedPayment, 'bankDepositAmountCoinTypes', Enum::"NPR Denomination Target"::BankDeposit, TempBinCheckpoint);
            TransferDenominations(CountedPayment, 'moveToBinAmountCoinTypes', Enum::"NPR Denomination Target"::MoveToBin, TempBinCheckpoint);
        end;
    end;

    local procedure TransferCountingToBinCheckpointRec(Counting: JsonArray; var TempBinCheckpoint: Record "NPR POS Payment Bin Checkp." temporary)
    var
        CountedPayment: JsonToken;
        ManualCountComment: Label 'Counted by %1', MaxLength = 25;
    begin
        foreach CountedPayment in Counting do begin
            TempBinCheckpoint.Get(GetValueAsInteger(CountedPayment.AsObject(), 'id'));
            TempBinCheckpoint."Counted Amount Incl. Float" := GetValueAsDecimal(CountedPayment.AsObject(), 'countedAmount');
            TempBinCheckpoint.Comment := CopyStr(GetValueAsText(CountedPayment.AsObject(), 'countedAmountComment'), 1, MaxStrLen(TempBinCheckpoint.Comment));
            if (TempBinCheckpoint.Comment = '') then
                TempBinCheckpoint.Comment := StrSubstNo(ManualCountComment, CopyStr(UserId, 1, 25));
            TempBinCheckpoint.Modify();

            TransferDenominations(CountedPayment, 'coinTypes', Enum::"NPR Denomination Target"::Counted, TempBinCheckpoint);
        end;
    end;

    procedure TransferDenominations(CountedPayment: JsonToken; JsonPath: Text; DenominationTarget: Enum "NPR Denomination Target"; PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.")
    var
        POSPmtBinCheckpDenom: Record "NPR POS Pmt. Bin Checkp. Denom";
        Denomination: JsonToken;
        Denominations: JsonToken;
        Qty: Decimal;
    begin
        POSPmtBinCheckpDenom.SetRange("POS Pmt. Bin Checkp. Entry No.", PmtBinCheckpoint."Entry No.");
        POSPmtBinCheckpDenom.SetRange("Attached-to ID", DenominationTarget);
        if not POSPmtBinCheckpDenom.IsEmpty() then
            POSPmtBinCheckpDenom.DeleteAll();

        if not (CountedPayment.SelectToken(JsonPath, Denominations) and Denominations.IsArray()) then
            exit;

        foreach Denomination in Denominations.AsArray() do begin
            Qty := GetValueAsInteger(Denomination.AsObject(), 'quantity');
            if Qty <> 0 then begin
                POSPmtBinCheckpDenom.Init();
                POSPmtBinCheckpDenom."POS Pmt. Bin Checkp. Entry No." := PmtBinCheckpoint."Entry No.";
                POSPmtBinCheckpDenom."Attached-to ID" := DenominationTarget;
                POSPmtBinCheckpDenom."Denomination Type" := Enum::"NPR Denomination Type".FromInteger(GetValueAsInteger(Denomination.AsObject(), 'type'));
                POSPmtBinCheckpDenom.Denomination := GetValueAsDecimal(Denomination.AsObject(), 'value');
                POSPmtBinCheckpDenom."Denomination Variant ID" := GetValueAsCode20(Denomination.AsObject(), 'variation');
                if not POSPmtBinCheckpDenom.Find() then
                    POSPmtBinCheckpDenom.Insert();
                POSPmtBinCheckpDenom."Currency Code" := PmtBinCheckpoint."Currency Code";
                POSPmtBinCheckpDenom.Validate(Quantity, Qty);
                POSPmtBinCheckpDenom.Modify();
            end;
        end;
    end;

    local procedure HandleVirtualCounting(var TempBinCheckpoint: Record "NPR POS Payment Bin Checkp." temporary)
    var
        PaymentMethod: Record "NPR POS Payment Method";
        POSPaymentBinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        VirtualCountComment: Label 'Virtual Count', MaxLength = 50;
    begin
        POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
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

#pragma warning disable AA0139
    local procedure GetValueAsCode20(JObject: JsonObject; KeyName: Text): Code[20]
    begin
        exit(UpperCase(CopyStr(GetValueAsText(JObject, KeyName), 1, 20)));
    end;
#pragma warning restore AA0139

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
        SalesPersonCode: Code[20];
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

        if (_POSUnit.Status <> _POSUnit.Status::EOD) then
            exit;

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
        SalesPersonCode := GetValueAsCode20(Context, 'state.backendContext.salesPersonCode');

        BalanceEntryToPrint := CheckPointMgr.CreateBalancingEntry(_EodWorkShiftMode::ZREPORT, _POSWorkShiftCheckpoint."POS Unit No.", _POSWorkShiftCheckpoint."Entry No.", DimId);
        ClosingEntryNo := POSCreateEntry.InsertUnitCloseEndEntry(_POSWorkShiftCheckpoint."POS Unit No.", SalesPersonCode);
        POSManagePOSUnit.ClosePOSUnitNo(_POSWorkShiftCheckpoint."POS Unit No.", ClosingEntryNo);
        Commit();

        SendEndWorkshiftSMS(_POSWorkShiftCheckpoint."POS Unit No.", BalanceEntryToPrint <> 0, BalanceEntryToPrint);
        OnAfterZReport(_POSWorkShiftCheckpoint."POS Unit No.", BalanceEntryToPrint <> 0, BalanceEntryToPrint);

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

    local procedure RestorePOSUnitStatus(POSWorkShiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
    begin
        if POSWorkShiftCheckpoint."POS Unit Status Before Checkp." = POSWorkShiftCheckpoint."POS Unit Status Before Checkp."::CLOSED then
            POSManagePOSUnit.ClosePOSUnitNo(POSWorkShiftCheckpoint."POS Unit No.", 0)
        else
            POSManagePOSUnit.ReOpenLastPeriodRegister(POSWorkShiftCheckpoint."POS Unit No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterZReport(UnitNo: Code[10]; Successful: Boolean; PosEntryNo: Integer)
    begin
        // Unit No.:      The POS Unit being balanced
        // Successful:    EOD posted successfully
        // Pos Entry No:  can be zero
    end;

    internal procedure SendEndWorkshiftSMS(UnitNo: Code[10]; Successful: Boolean; PosEntryNo: Integer)
    var
        RecRef: RecordRef;
        SMSTemplateHeader: Record "NPR SMS Template Header";
        POSWorkshifCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSUnit: Record "NPR POS Unit";
        POSEndOfdayProfile: Record "NPR POS End of Day Profile";
        SMSBodyText: Text;
        Sender: Text;
        SendTo: Text;
        SMSImplementation: Codeunit "NPR SMS Implementation";
        SendToList: list of [Text];
    begin
        if not Successful then
            exit;

        if not POSUnit.Get(UnitNo) then
            exit;

        if not POSEndOfdayProfile.Get(POSUnit."POS End of Day Profile") then
            exit;

        if (not SMSTemplateHeader.Get(POSEndOfdayProfile."SMS Profile")) then
            exit;

        POSWorkshifCheckpoint.Reset();
        POSWorkshifCheckpoint.SetRange("POS Entry No.", PosEntryNo);
        if POSWorkshifCheckpoint.FindFirst() then
            RecRef.GetTable(POSWorkshifCheckpoint);

        SMSBodyText := SMSImplementation.MakeMessage(SMSTemplateHeader, RecRef);

        Sender := SMSTemplateHeader."Alt. Sender";

        SMSImplementation.PopulateSendList(SendToList, SMSTemplateHeader."Recipient Type", SMSTemplateHeader."Recipient Group", SendTo);
        SMSImplementation.QueueMessages(SendToList, Sender, SMSBodyText, CurrentDateTime + 1000 * 60); //Delay 1 minute;
    end;
}
