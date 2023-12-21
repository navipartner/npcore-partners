codeunit 6059837 "NPR POS Action: Bin Transfer B"
{
    Access = Internal;

    var
        JsonHelper: Codeunit "NPR Json Helper";

    [Obsolete('Part of legacy action codebase. Can be deleted once the legacy action is not used anymore.', 'NPR28.0')]
    procedure TransferContentsToBin(POSSession: Codeunit "NPR POS Session"; FromBinNo: Code[10]; CheckpointEntryNo: Integer)
    var
        PaymentBinCheckpoint: Codeunit "NPR POS Payment Bin Checkpoint";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSSale: Codeunit "NPR POS Sale";
        PaymentBinCheckpointPage: Page "NPR POS Payment Bin Checkpoint";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        PageAction: Action;
        SalePOS: Record "NPR POS Sale";
    begin
        WorkshiftCheckpoint.Get(CheckpointEntryNo);
        WorkshiftCheckpoint.Type := WorkshiftCheckpoint.Type::TRANSFER;
        WorkshiftCheckpoint.Modify();

        PaymentBinCheckpoint.CreatePosEntryBinCheckpoint(GetUnitNo(POSSession), FromBinNo, CheckpointEntryNo, POSPaymentBinCheckpoint.type::TRANSFER);
        Commit();

        // Confirm amounts counted and float/bank/safe transfer
        POSPaymentBinCheckpoint.Reset();
        POSPaymentBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        POSPaymentBinCheckpoint.FilterGroup(2);
        POSPaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", CheckpointEntryNo);
        POSPaymentBinCheckpoint.FilterGroup(0);

        PaymentBinCheckpointPage.SetTableView(POSPaymentBinCheckpoint);
        PaymentBinCheckpointPage.LookupMode(true);
        PaymentBinCheckpointPage.SetTransferMode();
        PageAction := PaymentBinCheckpointPage.RunModal();
        Commit();

        if (PageAction = ACTION::LookupOK) then begin
            POSPaymentBinCheckpoint.Reset();
            POSPaymentBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", CheckpointEntryNo);
            POSPaymentBinCheckpoint.SetRange(Status, POSPaymentBinCheckpoint.Status::READY);
            if (not POSPaymentBinCheckpoint.IsEmpty()) then begin

                POSSession.GetSale(POSSale);
                POSSale.GetCurrentSale(SalePOS);

                PostWorkshiftCheckpoint(CheckpointEntryNo, SalePOS);  //Has a commit

                POSSession.ChangeViewLogin();
            end;
        end;
    end;

    [Obsolete('Part of legacy action codebase. Can be deleted once the legacy action is not used anymore.', 'NPR28.0')]
    procedure PrintBinTransfer(CheckpointEntryNo: Integer)
    var
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        RecRef: RecordRef;
    begin
        POSWorkshiftCheckpoint.SetRange("Entry No.", CheckpointEntryNo);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::TRANSFER);
        if not POSWorkshiftCheckpoint.FindFirst() then
            exit;
        RecRef.GetTable(POSWorkshiftCheckpoint);
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Bin Transfer".AsInteger());
    end;

    local procedure PrintBinTransfer(var WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        BinTransferPost: Codeunit "NPR BinTransferPost";
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
    begin
        if WorkshiftCheckpoint.Type <> WorkshiftCheckpoint.Type::TRANSFER then
            exit;
        RecRef.GetTable(WorkshiftCheckpoint);
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Bin Transfer".AsInteger());

        PmtBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        PmtBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpoint."Entry No.");
        PmtBinCheckpoint.SetRange(Status, PmtBinCheckpoint.Status::READY);
        PmtBinCheckpoint.FilterGroup(-1);
        PmtBinCheckpoint.SetFilter("Bin Transfer Journal Entry No.", '<>%1', 0);
        PmtBinCheckpoint.SetFilter("Bin Transf. Jnl. Entry (Bank)", '<>%1', 0);
        PmtBinCheckpoint.FilterGroup(0);
        if PmtBinCheckpoint.FindSet() then
            repeat
                if PmtBinCheckpoint."Bin Transfer Journal Entry No." <> 0 then
                    BinTransferPost.ReceivePrint(PmtBinCheckpoint."Bin Transfer Journal Entry No.");
                if PmtBinCheckpoint."Bin Transf. Jnl. Entry (Bank)" <> 0 then
                    BinTransferPost.ReceivePrint(PmtBinCheckpoint."Bin Transf. Jnl. Entry (Bank)");
            until PmtBinCheckpoint.Next() = 0;
    end;

    procedure UserSelectBin(POSUnit: Record "NPR POS Unit"): Code[10]
    var
        POSUnitToBinRelation: Record "NPR POS Unit to Bin Relation";
        POSPaymentBin: Record "NPR POS Payment Bin";
    begin
        POSUnitToBinRelation.SetRange("POS Unit No.", POSUnit."No.");
        POSUnitToBinRelation.SetFilter("POS Payment Bin No.", '<>%1', '');
        if POSUnitToBinRelation.FindSet() then
            repeat
                IF POSPaymentBin.GET(POSUnitToBinRelation."POS Payment Bin No.") then
                    POSPaymentBin.Mark(true);
            until POSUnitToBinRelation.Next() = 0;

        POSPaymentBin.MarkedOnly(true);
        if Page.RunModal(Page::"NPR POS Payment Bins", POSPaymentBin) <> Action::LookupOK then
            Error('');
        exit(POSPaymentBin."No.");
    end;

    [Obsolete('Part of legacy action codebase. Can be deleted once the legacy action is not used anymore.', 'NPR28.0')]
    local procedure GetUnitNo(POSSession: Codeunit "NPR POS Session"): Code[10]
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        exit(POSUnit."No.");
    end;

    procedure GetDefaultUnitBin(POSUnit: Record "NPR POS Unit"): Code[10]
    begin
        POSUnit.TestField("Default POS Payment Bin");
        exit(POSUnit."Default POS Payment Bin");
    end;

    procedure GetPosUnitFromBin(FromBinNo: Code[10]; var PosUnit: Record "NPR POS Unit")
    var
        BlankBinLabel: Label 'From Bin can not be blank.';
        NotDefaultBinLabel: Label 'The selected from bin %1 is not the default bin on any POS Unit';
        AmbiguousPosLabel: Label 'Ambiguous POS Unit. The selected from bin %1 is declared default bin on multiple POS Units.';
    begin
        if (FromBinNo = '') then
            Error(BlankBinLabel);

        PosUnit.SetFilter("Default POS Payment Bin", '%1', FromBinNo);
        if (PosUnit.IsEmpty()) then
            Error(NotDefaultBinLabel, FromBinNo);
        if (PosUnit.Count > 1) then
            Error(AmbiguousPosLabel, FromBinNo);

        PosUnit.FindFirst();
        PosUnit.TestField(Status, PosUnit.Status::OPEN);
    end;

    internal procedure GetBinTransferContextData(PosUnitNo: Code[10]; BinNo: Code[10]; TransferDirection: Option "",TransferOut,TransferIn) Response: JsonObject
    var
        EndOfDayProfile: Record "NPR POS End of Day Profile";
        PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSUnit: Record "NPR POS Unit";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        EndOfDayUIHandler: Codeunit "NPR End Of Day UI Handler";
        PaymentBinCheckpointHdlr: Codeunit "NPR POS Payment Bin Checkpoint";
        WorkshiftCheckpointHdlr: Codeunit "NPR POS Workshift Checkpoint";
        TransferDirectionLbl: Label 'OUT,IN', Locked = true;
        TransferDirectionNotSetErr: Label 'Please select a transfer direction (in our out) for the POS button before using it.';
    begin
        If TransferDirection = 0 then
            Error(TransferDirectionNotSetErr);
        POSUnit.Get(PosUnitNo);
        WorkshiftCheckpoint.get(WorkshiftCheckpointHdlr.CreateEndWorkshiftCheckpoint_POSEntry(PosUnit."POS Store Code", PosUnit."No.", PosUnit.Status));
        WorkshiftCheckpoint.Type := WorkshiftCheckpoint.Type::TRANSFER;
        WorkshiftCheckpoint.Modify();
        PaymentBinCheckpointHdlr.CreatePosEntryBinCheckpoint(PosUnit."No.", BinNo, WorkshiftCheckpoint."Entry No.", PmtBinCheckpoint.Type::TRANSFER);

        POSUnit.GetProfile(EndOfDayProfile);
        Response.Add('cashCount', GetCashCount(EndOfDayProfile, POSUnit."No.", WorkshiftCheckpoint."Entry No.", TransferDirection));
        Response.Add('bins', EndOfDayUIHandler.GetAvailableBins(PosUnit."No."));
        Response.Add('checkPointId', WorkshiftCheckpoint."Entry No.");
        Response.Add('direction', SelectStr(TransferDirection, TransferDirectionLbl));
        if TransferDirection = TransferDirection::TransferIn then begin
            Response.Add('allowPrestagedTransfersOnly', EndOfDayProfile."Bin Transfer: Require Journal");
            Response.Add('prestagedTransfers', GetBinTransferJnlLines(EndOfDayProfile, PosUnit."No.", BinNo, WorkshiftCheckpoint."Entry No."));
        end;
    end;

    local procedure GetCashCount(EndOfDayProfile: Record "NPR POS End of Day Profile"; POSUnitNo: Code[10]; CheckpointEntryNo: Integer; TransferDirection: Option "",TransferOut,TransferIn) CashCount: JsonObject
    begin
        CashCount.Add('counting', GetCashCountingTypes(EndOfDayProfile, POSUnitNo, CheckpointEntryNo, TransferDirection));
        CashCount.Add('transfer', GetTransfer(CheckpointEntryNo));
    end;

    local procedure GetCashCountingTypes(EndOfDayProfile: Record "NPR POS End of Day Profile"; POSUnitNo: Code[10]; CheckpointEntryNo: Integer; TransferDirection: Option "",TransferOut,TransferIn) CashCounting: JsonArray
    var
        PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        PaymentMethod: Record "NPR POS Payment Method";
        PaymentMethodDenom: Record "NPR Payment Method Denom";
        EndOfDayUIHandler: Codeunit "NPR End Of Day UI Handler";
        CoinTypes: JsonArray;
        CountingType: JsonObject;
    begin
        PmtBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        PmtBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", CheckpointEntryNo);
        if not PmtBinCheckpoint.FindSet() then
            exit;

        repeat
            if PaymentMethod.Get(PmtBinCheckpoint."Payment Method No.") and
               ((PaymentMethod."Include In Counting" in [PaymentMethod."Include In Counting"::YES, PaymentMethod."Include In Counting"::BLIND]) or
                ((PaymentMethod."Include In Counting" = PaymentMethod."Include In Counting"::VIRTUAL) and (PaymentMethod."Bin for Virtual-Count" = '')))
            then begin
                Clear(CountingType);
                CountingType.Add('id', PmtBinCheckpoint."Entry No.");
                CountingType.Add('paymentTypeNo', PmtBinCheckpoint."Payment Type No.");
                CountingType.Add('description', PmtBinCheckpoint.Description);
                CountingType.Add('floatAmount', PmtBinCheckpoint."Float Amount");
                CountingType.Add('calculatedAmount', PmtBinCheckpoint."Calculated Amount Incl. Float");
                CountingType.Add('requireBankDepositAmtDenominations', EndOfDayProfile."Require Denomin.(Bank Deposit)");
                CountingType.Add('requireMoveToBinAmtDenominations', EndOfDayProfile."Require Denomin. (Move to Bin)");
                if TransferDirection = TransferDirection::TransferIn then begin
                    CountingType.Add('bankDepositRef', EndOfDayUIHandler.GetReferenceNo(Enum::"NPR Reference No. Target"::BT_IN_FromBank, EndOfDayProfile, POSUnitNo, PaymentMethod.Code, CheckpointEntryNo));
                    CountingType.Add('moveToBinRef', EndOfDayUIHandler.GetReferenceNo(Enum::"NPR Reference No. Target"::BT_IN_FromBin, EndOfDayProfile, POSUnitNo, PaymentMethod.Code, CheckpointEntryNo));
                end else begin
                    CountingType.Add('bankDepositRef', EndOfDayUIHandler.GetReferenceNo(Enum::"NPR Reference No. Target"::BT_OUT_BankDeposit, EndOfDayProfile, POSUnitNo, PaymentMethod.Code, CheckpointEntryNo));
                    CountingType.Add('moveToBinRef', EndOfDayUIHandler.GetReferenceNo(Enum::"NPR Reference No. Target"::BT_OUT_MoveToBin, EndOfDayProfile, POSUnitNo, PaymentMethod.Code, CheckpointEntryNo));
                end;

                Clear(CoinTypes);
                PaymentMethodDenom.SetRange("POS Payment Method Code", PmtBinCheckpoint."Payment Method No.");
                PaymentMethodDenom.SetRange(Blocked, false);
                if PaymentMethodDenom.FindSet() then
                    repeat
                        CoinTypes.Add(PmtMethodDenominationAsJObject(PaymentMethodDenom, PmtBinCheckpoint."Entry No.", 0));
                    until PaymentMethodDenom.Next() = 0;
                CountingType.Add('coinTypes', CoinTypes);

                CashCounting.Add(CountingType);
            end;
        until PmtBinCheckpoint.Next() = 0;
    end;

    local procedure GetTransfer(CheckpointEntryNo: Integer) Transfer: JsonArray
    var
        PmtBinCheckPoint: Record "NPR POS Payment Bin Checkp.";
        Line: JsonObject;
    begin
        PmtBinCheckPoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        PmtBinCheckPoint.SetRange("Workshift Checkpoint Entry No.", CheckpointEntryNo);
        if not PmtBinCheckPoint.FindSet() then
            exit;

        repeat
            Clear(Line);
            Line.Add('id', PmtBinCheckPoint."Entry No.");
            Line.Add('paymentTypeNo', PmtBinCheckPoint."Payment Type No.");
            Line.Add('bankDepositAmount', PmtBinCheckPoint."Bank Deposit Amount");
            Line.Add('bankDepositBinCode', PmtBinCheckPoint."Bank Deposit Bin Code");
            Line.Add('bankDepositReference', PmtBinCheckPoint."Bank Deposit Reference");
            Line.Add('bankDepositAmountCoinTypes', AddDenominations(PmtBinCheckpoint, Enum::"NPR Denomination Target"::BankDeposit));
            Line.Add('binAmount', PmtBinCheckPoint."Move to Bin Amount");
            Line.Add('binNo', PmtBinCheckPoint."Move to Bin Code");
            Line.Add('binTransId', PmtBinCheckPoint."Move to Bin Reference");
            Line.Add('binAmountCoinTypes', AddDenominations(PmtBinCheckpoint, Enum::"NPR Denomination Target"::MoveToBin));
            Line.Add('prestagedTransferIdBin', PmtBinCheckPoint."Bin Transfer Journal Entry No.");
            Line.Add('prestagedTransferIdBank', PmtBinCheckPoint."Bin Transf. Jnl. Entry (Bank)");
            Transfer.Add(Line);
        until PmtBinCheckPoint.Next() = 0;
    end;

    local procedure GetBinTransferJnlLines(EndOfDayProfile: Record "NPR POS End of Day Profile"; POSUnitNo: Code[10]; BinNo: Code[10]; CheckpointEntryNo: Integer) JnlLines: JsonArray
    var
        BinTransferJnlLine: Record "NPR BinTransferJournal";
        EndOfDayUIHandler: Codeunit "NPR End Of Day UI Handler";
        JnlLine: JsonObject;
        BalancingBinType: Option Bank,Bin;
        ReferenceNo: Text;
        PmtMethodDescrLbl: Label '[%1] %2', Locked = true;
    begin
        BinTransferJnlLine.SetRange(ReceiveAtPosUnitCode, POSUnitNo);
        BinTransferJnlLine.SetRange(TransferToBinCode, BinNo);
        BinTransferJnlLine.SetRange(Status, BinTransferJnlLine.Status::RELEASED);
        if BinTransferJnlLine.FindSet() then
            repeat
                Evaluate(BalancingBinType, Format(not BalancingBinTypeIsBank(BinTransferJnlLine), 0, 2));
                ReferenceNo := BinTransferJnlLine.ExternalDocumentNo;
                if ReferenceNo = '' then
                    case BalancingBinType of
                        BalancingBinType::Bank:
                            ReferenceNo := EndOfDayUIHandler.GetReferenceNo(Enum::"NPR Reference No. Target"::BT_IN_FromBank, EndOfDayProfile, POSUnitNo, BinTransferJnlLine.PaymentMethod, CheckpointEntryNo);
                        BalancingBinType::Bin:
                            ReferenceNo := EndOfDayUIHandler.GetReferenceNo(Enum::"NPR Reference No. Target"::BT_IN_FromBin, EndOfDayProfile, POSUnitNo, BinTransferJnlLine.PaymentMethod, CheckpointEntryNo);
                    end;

                Clear(JnlLine);
                JnlLine.Add('id', BinTransferJnlLine.EntryNo);
                JnlLine.Add('balancingBinType', BalancingBinType);  //0 = bank, 1 = other bin
                JnlLine.Add('transferFromPOSUnit', BinTransferJnlLine.ReceiveFromPosUnitCode);
                JnlLine.Add('transferFromBin', BinTransferJnlLine.TransferFromBinCode);
                JnlLine.Add('transferToPOSUnit', BinTransferJnlLine.ReceiveAtPosUnitCode);
                JnlLine.Add('transferToBin', BinTransferJnlLine.TransferToBinCode);
                JnlLine.Add('paymentMethod', BinTransferJnlLine.PaymentMethod);
                JnlLine.Add('paymentMethodDescription', StrSubstNo(PmtMethodDescrLbl, BinNo, BinTransferJnlLine.PaymentMethod));
                JnlLine.Add('requireBankDepositAmtDenominations', EndOfDayProfile."Require Denomin.(Bank Deposit)");
                JnlLine.Add('requireMoveToBinAmtDenominations', EndOfDayProfile."Require Denomin. (Move to Bin)");
                JnlLine.Add('amount', BinTransferJnlLine.Amount);
                JnlLine.Add('documentNo', ReferenceNo);
                JnlLine.Add('coinTypes', AddDenominations(BinTransferJnlLine));
                JnlLines.Add(JnlLine);
            until BinTransferJnlLine.Next() = 0;
    end;

    local procedure BalancingBinTypeIsBank(BinTransferJnlLine: Record "NPR BinTransferJournal"): Boolean
    var
        PmtBin: Record "NPR POS Payment Bin";
    begin
        BinTransferJnlLine.TestField(TransferFromBinCode);
        PmtBin.Get(BinTransferJnlLine.TransferFromBinCode);
        exit(PmtBin."Bin Type" = PmtBin."Bin Type"::BANK);
    end;

    local procedure AddDenominations(BinTransferJnlLine: Record "NPR BinTransferJournal") CoinTypes: JsonArray
    var
        PaymentMethodDenom: Record "NPR Payment Method Denom";
        TransferDenomination: Record "NPR BinTransferDenomination";
    begin
        Clear(CoinTypes);
        PaymentMethodDenom.SetRange("POS Payment Method Code", BinTransferJnlLine.PaymentMethod);
        PaymentMethodDenom.SetRange(Blocked, false);
        if PaymentMethodDenom.FindSet() then
            repeat
                if TransferDenomination.Get(
                    BinTransferJnlLine.EntryNo, BinTransferJnlLine.PaymentMethod,
                    PaymentMethodDenom."Denomination Type", PaymentMethodDenom.Denomination, PaymentMethodDenom."Denomination Variant ID")
                then
                    TransferDenomination.Mark(true)
                else
                    TransferDenomination.Quantity := 0;
                CoinTypes.Add(PmtMethodDenominationAsJObject(PaymentMethodDenom, BinTransferJnlLine.EntryNo, TransferDenomination.Quantity));
            until PaymentMethodDenom.Next() = 0;

        TransferDenomination.SetRange(EntryNo, BinTransferJnlLine.EntryNo);
        TransferDenomination.SetFilter(Quantity, '<>%1', 0);
        if TransferDenomination.FindSet() then
            repeat
                if not TransferDenomination.Mark() then begin
                    PaymentMethodDenom."Denomination Type" := TransferDenomination.DenominationType;
                    PaymentMethodDenom.Denomination := TransferDenomination.Denomination;
                    PaymentMethodDenom."Denomination Variant ID" := TransferDenomination.DenominationVariantID;
                    CoinTypes.Add(PmtMethodDenominationAsJObject(PaymentMethodDenom, BinTransferJnlLine.EntryNo, TransferDenomination.Quantity));
                end;
            until TransferDenomination.Next() = 0;
    end;

    local procedure AddDenominations(PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp."; DenominationTarget: Enum "NPR Denomination Target") CoinTypes: JsonArray
    var
        PaymentMethodDenom: Record "NPR Payment Method Denom";
        POSPmtBinCheckpDenom: Record "NPR POS Pmt. Bin Checkp. Denom";
    begin
        POSPmtBinCheckpDenom.SetRange("POS Pmt. Bin Checkp. Entry No.", PmtBinCheckpoint."Entry No.");
        POSPmtBinCheckpDenom.SetRange("Attached-to ID", DenominationTarget);
        if POSPmtBinCheckpDenom.IsEmpty() then
            exit;

        PaymentMethodDenom.SetRange("POS Payment Method Code", PmtBinCheckpoint."Payment Method No.");
        PaymentMethodDenom.SetRange(Blocked, false);
        if PaymentMethodDenom.FindSet() then
            repeat
                if POSPmtBinCheckpDenom.Get(
                    PmtBinCheckpoint."Entry No.", DenominationTarget,
                    PaymentMethodDenom."Denomination Type", PaymentMethodDenom.Denomination, PaymentMethodDenom."Denomination Variant ID")
                then
                    POSPmtBinCheckpDenom.Mark(true)
                else
                    POSPmtBinCheckpDenom.Quantity := 0;
                CoinTypes.Add(PmtMethodDenominationAsJObject(PaymentMethodDenom, PmtBinCheckpoint."Entry No.", POSPmtBinCheckpDenom.Quantity));
            until PaymentMethodDenom.Next() = 0;

        POSPmtBinCheckpDenom.FindSet();
        repeat
            if not POSPmtBinCheckpDenom.Mark() then begin
                PaymentMethodDenom."Denomination Type" := POSPmtBinCheckpDenom."Denomination Type";
                PaymentMethodDenom.Denomination := POSPmtBinCheckpDenom.Denomination;
                PaymentMethodDenom."Denomination Variant ID" := POSPmtBinCheckpDenom."Denomination Variant ID";
                CoinTypes.Add(PmtMethodDenominationAsJObject(PaymentMethodDenom, PmtBinCheckpoint."Entry No.", POSPmtBinCheckpDenom.Quantity));
            end;
        until POSPmtBinCheckpDenom.Next() = 0;
    end;

    local procedure PmtMethodDenominationAsJObject(PaymentMethodDenom: Record "NPR Payment Method Denom"; EntryNo: Integer; Quantity: Integer) CoinType: JsonObject
    var
        CoinTypeDescLbl: Label '%1 %2', Locked = true;
    begin
        Clear(CoinType);
        CoinType.Add('id', EntryNo);
        CoinType.Add('type', PaymentMethodDenom."Denomination Type".AsInteger());
        CoinType.Add('description', StrSubstNo(CoinTypeDescLbl, PaymentMethodDenom.Denomination, PaymentMethodDenom."Denomination Type"));
        CoinType.Add('variation', PaymentMethodDenom."Denomination Variant ID");
        CoinType.Add('value', PaymentMethodDenom.Denomination);
        if Quantity <> 0 then
            CoinType.Add('quantity', Quantity);
    end;

    local procedure TransferDenominations(PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp."; DenominationTarget: Enum "NPR Denomination Target"; ToBinTransferJnlLine: Record "NPR BinTransferJournal")
    var
        POSPmtBinCheckpDenom: Record "NPR POS Pmt. Bin Checkp. Denom";
        TransferDenomination: Record "NPR BinTransferDenomination";
    begin
        TransferDenomination.SetRange(EntryNo, ToBinTransferJnlLine.EntryNo);
        if not TransferDenomination.IsEmpty() then
            TransferDenomination.DeleteAll();

        POSPmtBinCheckpDenom.SetRange("POS Pmt. Bin Checkp. Entry No.", PmtBinCheckpoint."Entry No.");
        POSPmtBinCheckpDenom.SetRange("Attached-to ID", DenominationTarget);
        if not POSPmtBinCheckpDenom.FindSet() then
            exit;
        repeat
            TransferDenomination.Init();
            TransferDenomination.EntryNo := ToBinTransferJnlLine.EntryNo;
            TransferDenomination.POSPaymentMethodCode := ToBinTransferJnlLine.PaymentMethod;
            TransferDenomination.DenominationType := POSPmtBinCheckpDenom."Denomination Type";
            TransferDenomination.DenominationVariantID := POSPmtBinCheckpDenom."Denomination Variant ID";
            TransferDenomination.Denomination := POSPmtBinCheckpDenom.Denomination;
            TransferDenomination.Quantity := POSPmtBinCheckpDenom.Quantity;
            TransferDenomination.Amount := POSPmtBinCheckpDenom.Amount;
            TransferDenomination.Insert();
        until POSPmtBinCheckpDenom.Next() = 0;
    end;

    internal procedure ProcessBinTransfer(BinTransferFrontReturnedData: JsonToken; SalePOS: Record "NPR POS Sale"; PosUnitNo: Code[10]; BinNo: Code[10]; PrintTransfer: Boolean; var CheckpointEntryNo: Integer): Boolean
    var
        BinTransferSetup: Record "NPR Bin Transfer Profile";
        PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        TempPmtBinCheckpoint: Record "NPR POS Payment Bin Checkp." temporary;
        POSUnit: Record "NPR POS Unit";
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        Transfers: JsonToken;
        TransferIn: Boolean;
    begin
        if not JsonHelper.GetJBoolean(BinTransferFrontReturnedData, 'confirmed', false) then  // User clicked cancel, transaction will be aborted
            exit(false);

        CheckpointEntryNo := JsonHelper.GetJInteger(BinTransferFrontReturnedData, 'checkPointId', true);
        WorkShiftCheckpoint.Get(CheckpointEntryNo);
        WorkShiftCheckpoint.TestField("POS Unit No.", PosUnitNo);
        POSUnit.Get(WorkShiftCheckpoint."POS Unit No.");

        Transfers := JsonHelper.GetJsonToken(BinTransferFrontReturnedData, 'cashCount.transfer');
        TransferIn := JsonHelper.GetJText(BinTransferFrontReturnedData, 'direction', true) = 'IN';
        TransferCashCountToBinCheckpoint(Transfers.AsArray(), WorkshiftCheckpoint."Entry No.", TransferIn, TempPmtBinCheckpoint);

        if TempPmtBinCheckpoint.FindSet() then
            repeat
                PmtBinCheckpoint.Get(TempPmtBinCheckpoint."Entry No.");
                PmtBinCheckpoint.TransferFields(TempPmtBinCheckpoint, false);
                PmtBinCheckpoint.Modify();
            until TempPmtBinCheckpoint.Next() = 0;

        PmtBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpoint."Entry No.");
        PmtBinCheckpoint.SetRange(Status, PmtBinCheckpoint.Status::READY);
        if PmtBinCheckpoint.IsEmpty() then
            exit(false);
        UpdateNotfinalizedPmtBinCheckpoints(PmtBinCheckpoint);

        PostWorkshiftCheckpoint(WorkshiftCheckpoint."Entry No.", SalePOS);  //Has a commit

        if not PrintTransfer and TransferIn then
            PrintTransfer := BinTransferSetup.Get() and BinTransferSetup.PrintOnReceive;

        if PrintTransfer then begin
            WorkshiftCheckpoint.Find();
            WorkshiftCheckpoint.SetRecFilter();
            PrintBinTransfer(WorkshiftCheckpoint);
        end;

        exit(true);
    end;

    local procedure UpdateNotfinalizedPmtBinCheckpoints(var PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.")
    var
        PmtBinCheckpoint2: Record "NPR POS Payment Bin Checkp.";
    begin
        PmtBinCheckpoint.SetFilter(Status, '<>%1', PmtBinCheckpoint.Status::READY);
        if PmtBinCheckpoint.FindSet(true) then
            repeat
                PmtBinCheckpoint2 := PmtBinCheckpoint;
                PmtBinCheckPoint2.Validate("Counted Amount Incl. Float", PmtBinCheckpoint2."Calculated Amount Incl. Float");
                UpdateNewFloatAmount(PmtBinCheckpoint2);
                PmtBinCheckpoint2.Status := PmtBinCheckpoint2.Status::READY;
                PmtBinCheckpoint2.Modify();
            until PmtBinCheckpoint.Next() = 0;
    end;

    local procedure TransferCashCountToBinCheckpoint(Transfers: JsonArray; CheckpointEntryNo: Integer; TransferIn: Boolean; var TempPmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.")
    var
        EndOfDayUIHandler: Codeunit "NPR End Of Day UI Handler";
        CountedPayment: JsonToken;
        AmtFactor: Integer;
    begin
        if TransferIn then
            AmtFactor := -1
        else
            AmtFactor := 1;

        foreach CountedPayment in Transfers do begin
            InitTempPmtBinCheckpoint(CountedPayment, CheckpointEntryNo, TempPmtBinCheckpoint);
#pragma warning disable AA0139
            TempPmtBinCheckpoint."Payment Type No." := JsonHelper.GetJText(CountedPayment, 'paymentTypeNo', MaxStrLen(TempPmtBinCheckpoint."Payment Type No."), false, TempPmtBinCheckpoint."Payment Type No.");
            TempPmtBinCheckpoint."Bank Deposit Bin Code" := JsonHelper.GetJText(CountedPayment, 'bankDepositBinCode', MaxStrLen(TempPmtBinCheckpoint."Bank Deposit Bin Code"), false);
            TempPmtBinCheckpoint."Bank Deposit Reference" := JsonHelper.GetJText(CountedPayment, 'bankDepositReference', MaxStrLen(TempPmtBinCheckpoint."Bank Deposit Reference"), false);
            TempPmtBinCheckpoint."Move To Bin Code" := JsonHelper.GetJText(CountedPayment, 'binNo', MaxStrLen(TempPmtBinCheckpoint."Move To Bin Code"), false);
            TempPmtBinCheckpoint."Move To Bin Reference" := JsonHelper.GetJText(CountedPayment, 'binTransId', MaxStrLen(TempPmtBinCheckpoint."Move To Bin Reference"), false);
#pragma warning restore AA0139            
            TempPmtBinCheckpoint."Bank Deposit Amount" := JsonHelper.GetJDecimal(CountedPayment, 'bankDepositAmount', false) * AmtFactor;
            TempPmtBinCheckpoint."Move To Bin Amount" := JsonHelper.GetJDecimal(CountedPayment, 'binAmount', false) * AmtFactor;
            TempPmtBinCheckpoint."Transfer In" := TransferIn;

            UpdateNewFloatAmount(TempPmtBinCheckpoint);
            TempPmtBinCheckpoint.Status := TempPmtBinCheckpoint.Status::READY;
            TempPmtBinCheckpoint.Insert();

            EndOfDayUIHandler.TransferDenominations(CountedPayment, 'bankDepositAmountCoinTypes', Enum::"NPR Denomination Target"::BankDeposit, TempPmtBinCheckpoint);
            EndOfDayUIHandler.TransferDenominations(CountedPayment, 'binAmountCoinTypes', Enum::"NPR Denomination Target"::MoveToBin, TempPmtBinCheckpoint);

            UpdateBinTransferJnlLines(TempPmtBinCheckpoint);
        end;
    end;

    local procedure InitTempPmtBinCheckpoint(CountedPayment: JsonToken; CheckpointEntryNo: Integer; var TempPmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.")
    var
        BinTransferJnlLine: Record "NPR BinTransferJournal";
        PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        PaymentBinCheckpointHdlr: Codeunit "NPR POS Payment Bin Checkpoint";
        PmtBinCheckpointEntryID: Integer;
        PrestagedTransferEntryNo_Bank: Integer;
        PrestagedTransferEntryNo_Bin: Integer;
    begin
        PmtBinCheckpointEntryID := JsonHelper.GetJInteger(CountedPayment, 'id', false);
        PrestagedTransferEntryNo_Bank := JsonHelper.GetJInteger(CountedPayment, 'prestagedTransferIdBank', false);
        PrestagedTransferEntryNo_Bin := JsonHelper.GetJInteger(CountedPayment, 'prestagedTransferIdBin', (PmtBinCheckpointEntryID = 0) and (PrestagedTransferEntryNo_Bank = 0));
        if (PmtBinCheckpointEntryID = 0) or (PrestagedTransferEntryNo_Bank <> 0) or (PrestagedTransferEntryNo_Bin <> 0) then begin
            if PrestagedTransferEntryNo_Bank <> 0 then
                BinTransferJnlLine.Get(PrestagedTransferEntryNo_Bank)
            else
                if PrestagedTransferEntryNo_Bin <> 0 then
                    BinTransferJnlLine.Get(PrestagedTransferEntryNo_Bin);
            if PmtBinCheckpointEntryID = 0 then
                PmtBinCheckpointEntryID :=
                    PaymentBinCheckpointHdlr.AddBinCountingCheckpoint_PE(
                        BinTransferJnlLine.TransferToBinCode, BinTransferJnlLine.ReceiveAtPosUnitCode, BinTransferJnlLine.PaymentMethod,
                        CheckpointEntryNo, PmtBinCheckpoint.Type::TRANSFER, true);
        end;
        PmtBinCheckpoint.Get(PmtBinCheckpointEntryID);

        TempPmtBinCheckpoint.TransferFields(PmtBinCheckpoint, true);
        TempPmtBinCheckPoint.Validate("Counted Amount Incl. Float", TempPmtBinCheckpoint."Calculated Amount Incl. Float");
        TempPmtBinCheckpoint."Bin Transfer Journal Entry No." := PrestagedTransferEntryNo_Bin;
        TempPmtBinCheckpoint."Bin Transf. Jnl. Entry (Bank)" := PrestagedTransferEntryNo_Bank;
    end;

    local procedure UpdateNewFloatAmount(var PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.")
    begin
        PmtBinCheckpoint."New Float Amount" := PmtBinCheckpoint."Counted Amount Incl. Float" - PmtBinCheckpoint."Bank Deposit Amount" - PmtBinCheckpoint."Move to Bin Amount";
        if PmtBinCheckpoint."New Float Amount" < 0 then
            PmtBinCheckpoint."New Float Amount" := 0;
        if (PmtBinCheckpoint."Move to Bin Amount" <> 0) and (PmtBinCheckpoint."Include In Counting" = PmtBinCheckpoint."Include In Counting"::NO) then
            PmtBinCheckpoint."Include In Counting" := PmtBinCheckpoint."Include In Counting"::YES;
    end;

    local procedure UpdateBinTransferJnlLines(PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.")
    begin
        UpdateBinTransferJnlLine(PmtBinCheckpoint."Bin Transf. Jnl. Entry (Bank)", PmtBinCheckpoint);
        UpdateBinTransferJnlLine(PmtBinCheckpoint."Bin Transfer Journal Entry No.", PmtBinCheckpoint);
    end;

    local procedure UpdateBinTransferJnlLine(BinTransferJnlEntryNo: Integer; PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.")
    var
        BinTransferJnlLine: Record "NPR BinTransferJournal";
    begin
        if BinTransferJnlEntryNo = 0 then
            exit;
        BinTransferJnlLine.Get(BinTransferJnlEntryNo);
        BinTransferJnlLine.TestField(Status, BinTransferJnlLine.Status::RELEASED);
        BinTransferJnlLine.TestField(TransferToBinCode, PmtBinCheckpoint."Payment Bin No.");
        BinTransferJnlLine.TestField(PaymentMethod, PmtBinCheckpoint."Payment Method No.");

        if BalancingBinTypeIsBank(BinTransferJnlLine) then begin
            BinTransferJnlLine.TransferFromBinCode := PmtBinCheckpoint."Bank Deposit Bin Code";
            BinTransferJnlLine.Amount := -PmtBinCheckpoint."Bank Deposit Amount";
            BinTransferJnlLine.ExternalDocumentNo := CopyStr(PmtBinCheckpoint."Bank Deposit Reference", 1, MaxStrLen(BinTransferJnlLine.ExternalDocumentNo));
            TransferDenominations(PmtBinCheckpoint, Enum::"NPR Denomination Target"::BankDeposit, BinTransferJnlLine);
        end else begin
            BinTransferJnlLine.TransferFromBinCode := PmtBinCheckpoint."Move to Bin Code";
            BinTransferJnlLine.Amount := -PmtBinCheckpoint."Move to Bin Amount";
            BinTransferJnlLine.ExternalDocumentNo := CopyStr(PmtBinCheckpoint."Move To Bin Reference", 1, MaxStrLen(BinTransferJnlLine.ExternalDocumentNo));
            TransferDenominations(PmtBinCheckpoint, Enum::"NPR Denomination Target"::MoveToBin, BinTransferJnlLine);
        end;
        BinTransferJnlLine.Status := BinTransferJnlLine.Status::RECEIVED;
        BinTransferJnlLine.Modify();
    end;

    local procedure PostWorkshiftCheckpoint(CheckpointEntryNo: Integer; var SalePOSIn: Record "NPR POS Sale")
    var
        POSEntryToPost: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        POSEntryNo: Integer;
        Now: DateTime;
        NotReadyForPostingErr: Label 'Counting has not been completed for workshift checkpoint entry No. %1.';
    begin
        // A Sale POS record is needed when creating POS Entry
        Now := CurrentDateTime();
        Clear(SalePOS);
        SalePOS.SystemId := CreateGuid();
        SalePOS."Register No." := SalePOSIn."Register No.";
        SalePOS."POS Store Code" := SalePOSIn."POS Store Code";
        SalePOS."Sales Ticket No." := CopyStr(DelChr(Format(Now, 0, 9), '=', DelChr(Format(Now, 0, 9), '=', '01234567890')), 1, MaxStrLen(SalePOS."Sales Ticket No."));
        SalePOS.Date := DT2Date(Now);
        SalePOS."Start Time" := DT2Time(Now);
        SalePOS."Salesperson Code" := SalePOSIn."Salesperson Code";
        SalePOS.CreateDimFromDefaultDim(SalePOS.FieldNo("Salesperson Code"));

        POSEntryNo := POSCreateEntry.CreateBalancingEntryAndLines(SalePOS, false, CheckpointEntryNo);
        if POSEntryNo = 0 then
            Error(NotReadyForPostingErr, CheckpointEntryNo);

        POSEntryToPost.Get(POSEntryNo);
        POSEntryToPost.SetRecFilter();

        if (POSEntryToPost."Post Item Entry Status" < POSEntryToPost."Post Item Entry Status"::Posted) then
            POSPostEntries.SetPostItemEntries(false);
        if (POSEntryToPost."Post Entry Status" < POSEntryToPost."Post Entry Status"::Posted) then
            POSPostEntries.SetPostPOSEntries(true);

        POSPostEntries.SetStopOnError(true);
        POSPostEntries.SetPostCompressed(false);
        POSPostEntries.Run(POSEntryToPost);
        Commit();
    end;

    procedure NewBinTransferFeatureFlag(): Text[50]
    begin
        exit('binTransferDragonglassDialog_v2');
    end;
}