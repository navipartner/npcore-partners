codeunit 85380 "NPR POS Bin Transf. Webh.Tests"
{
    Subtype = Test;

    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit "Assert";
        Initialized: Boolean;

    /// <summary>
    /// A transfer to another POS unit's cash drawer posts a checkpoint at the sending unit and a second
    /// one at the receiving unit. Only the sending leg reports, so the transfer must produce a single
    /// outbound event - the receiving leg must stay silent rather than report the same cash inbound.
    /// </summary>
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnitToUnitTransfer_FiresOutOnce()
    var
        DestinationBin: Record "NPR POS Payment Bin";
        InTransitBin: Record "NPR POS Payment Bin";
        WebhookSub: Codeunit "NPR POS Bin Transf. WebhookSub";
        SourceBinNo: Code[10];
    begin
        // [GIVEN] A POS unit holding cash, and another unit's cash drawer to transfer into
        Initialize(SourceBinNo);
        CreateBin(DestinationBin, DestinationBin."Bin Type"::CASH_DRAWER, CreateSecondPOSUnitNo());
        CreateBin(InTransitBin, InTransitBin."Bin Type"::CASH_DRAWER, '');
        SetInTransitBin(InTransitBin."No.");

        // [WHEN] The sending unit transfers cash out to that drawer
        BindSubscription(WebhookSub);
        WebhookSub.Reset();
        RunBinTransfer(SourceBinNo, DirectionOut(), '', 0, DestinationBin."No.", TransferAmount());
        UnbindSubscription(WebhookSub);

        // [THEN] The transfer reports itself exactly once as outbound, from the sending unit
        Assert.AreEqual(1, WebhookSub.TransferredOutCount(), 'A unit to unit transfer must raise pos_bin_transferred_out exactly once.');
        Assert.AreEqual(0, WebhookSub.TransferredInCount(), 'The receiving leg must not raise pos_bin_transferred_in: the sending unit already reported that cash.');
        Assert.AreEqual(POSUnit."No.", WebhookSub.LastPosUnit(), 'The event must report the unit the cash left.');
    end;

    /// <summary>
    /// A bank deposit has no receiving POS unit, so it posts one checkpoint and must report once.
    /// </summary>
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BankDeposit_FiresOutOnce()
    var
        BankBin: Record "NPR POS Payment Bin";
        WebhookSub: Codeunit "NPR POS Bin Transf. WebhookSub";
        SourceBinNo: Code[10];
    begin
        // [GIVEN] A POS unit holding cash, and a bank bin to deposit into
        Initialize(SourceBinNo);
        CreateBin(BankBin, BankBin."Bin Type"::BANK, '');

        // [WHEN] The unit deposits cash to the bank
        BindSubscription(WebhookSub);
        WebhookSub.Reset();
        RunBinTransfer(SourceBinNo, DirectionOut(), BankBin."No.", TransferAmount(), '', 0);
        UnbindSubscription(WebhookSub);

        // [THEN] The deposit reports itself exactly once as outbound
        Assert.AreEqual(1, WebhookSub.TransferredOutCount(), 'A bank deposit must raise pos_bin_transferred_out exactly once.');
        Assert.AreEqual(0, WebhookSub.TransferredInCount(), 'A bank deposit moves cash out of the bin, so it must not raise pos_bin_transferred_in.');
    end;

    /// <summary>
    /// A safe is not a cash drawer, so it never becomes a direct transfer and never gets a receiving leg.
    /// </summary>
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SafeDrop_FiresOutOnce()
    var
        SafeBin: Record "NPR POS Payment Bin";
        WebhookSub: Codeunit "NPR POS Bin Transf. WebhookSub";
        SourceBinNo: Code[10];
    begin
        // [GIVEN] A POS unit holding cash, and a safe to drop into
        Initialize(SourceBinNo);
        CreateBin(SafeBin, SafeBin."Bin Type"::SAFE, '');

        // [WHEN] The unit drops cash to the safe
        BindSubscription(WebhookSub);
        WebhookSub.Reset();
        RunBinTransfer(SourceBinNo, DirectionOut(), '', 0, SafeBin."No.", TransferAmount());
        UnbindSubscription(WebhookSub);

        // [THEN] The drop reports itself exactly once as outbound
        Assert.AreEqual(1, WebhookSub.TransferredOutCount(), 'A safe drop must raise pos_bin_transferred_out exactly once.');
        Assert.AreEqual(0, WebhookSub.TransferredInCount(), 'A safe drop moves cash out of the bin, so it must not raise pos_bin_transferred_in.');
    end;

    /// <summary>
    /// Cash delivered from the bank has no outbound leg anywhere in BC, so the inbound leg is the only
    /// posting that can report it. This is the case a direction based gate silently drops, and the only
    /// one that raises the inbound event.
    /// </summary>
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CashReceivedFromBank_FiresInOnce()
    var
        BankBin: Record "NPR POS Payment Bin";
        WebhookSub: Codeunit "NPR POS Bin Transf. WebhookSub";
        SourceBinNo: Code[10];
    begin
        // [GIVEN] A POS unit, and a bank bin delivering cash to it
        Initialize(SourceBinNo);
        CreateBin(BankBin, BankBin."Bin Type"::BANK, '');

        // [WHEN] The unit receives cash from the bank
        BindSubscription(WebhookSub);
        WebhookSub.Reset();
        RunBinTransfer(SourceBinNo, DirectionIn(), BankBin."No.", TransferAmount(), '', 0);
        UnbindSubscription(WebhookSub);

        // [THEN] The receipt reports itself exactly once as inbound
        Assert.AreEqual(1, WebhookSub.TransferredInCount(), 'Cash received from the bank must raise pos_bin_transferred_in exactly once.');
        Assert.AreEqual(0, WebhookSub.TransferredOutCount(), 'Cash received from the bank moves cash into the bin, so it must not raise pos_bin_transferred_out.');
    end;

    local procedure Initialize(var SourceBinNo: Code[10])
    var
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        SetBinTransferDocumentNoSeries();

        // The counting screen skips payment methods that are virtual counted, and this test needs the
        // method to produce a countable bin checkpoint.
        POSPaymentMethod.Get(POSPaymentMethod.Code);
        POSPaymentMethod."Include In Counting" := POSPaymentMethod."Include In Counting"::YES;
        POSPaymentMethod."Bin for Virtual-Count" := '';
        POSPaymentMethod.Modify();

        CreateSale();
        SourceBinNo := POSActionBinTransferB.GetDefaultUnitBin(POSUnit);
    end;

    /// <summary>
    /// Drives one transfer end to end: builds the checkpoint the way the POS front end does when the
    /// dialog opens, then feeds back the payload it would return once the operator confirms.
    /// </summary>
    local procedure RunBinTransfer(SourceBinNo: Code[10]; TransferDirection: Option "",TransferOut,TransferIn; BankDepositBinNo: Code[10]; BankDepositAmount: Decimal; MoveToBinNo: Code[10]; MoveToBinAmount: Decimal)
    var
        PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        SalePOS: Record "NPR POS Sale";
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        ContextData: JsonObject;
        ReturnedData: JsonToken;
        CheckpointEntryNo: Integer;
        ProcessedCheckpointEntryNo: Integer;
    begin
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // Opening the dialog is what creates the transfer checkpoint and its payment bin checkpoints.
        ContextData := POSActionBinTransferB.GetBinTransferContextData(POSUnit."No.", SourceBinNo, TransferDirection);
        CheckpointEntryNo := GetJsonInteger(ContextData, 'checkPointId');

        PmtBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", CheckpointEntryNo);
        PmtBinCheckpoint.FindFirst();

        ReturnedData :=
            BuildReturnedData(
                CheckpointEntryNo, PmtBinCheckpoint."Entry No.", DirectionText(TransferDirection),
                BankDepositBinNo, BankDepositAmount, MoveToBinNo, MoveToBinAmount);

        POSActionBinTransferB.ProcessBinTransfer(ReturnedData, SalePOS, POSUnit."No.", SourceBinNo, false, ProcessedCheckpointEntryNo);
    end;

    local procedure BuildReturnedData(CheckpointEntryNo: Integer; PmtBinCheckpointEntryNo: Integer; Direction: Text; BankDepositBinNo: Code[10]; BankDepositAmount: Decimal; MoveToBinNo: Code[10]; MoveToBinAmount: Decimal) ReturnedData: JsonToken
    var
        CashCount: JsonObject;
        Line: JsonObject;
        Root: JsonObject;
        Transfer: JsonArray;
    begin
        Line.Add('id', PmtBinCheckpointEntryNo);
        Line.Add('paymentTypeNo', '');
        Line.Add('bankDepositBinCode', BankDepositBinNo);
        Line.Add('bankDepositReference', '');
        Line.Add('bankDepositAmount', BankDepositAmount);
        Line.Add('binNo', MoveToBinNo);
        Line.Add('binTransId', '');
        Line.Add('binAmount', MoveToBinAmount);
        Line.Add('prestagedTransferIdBank', 0);
        Line.Add('prestagedTransferIdBin', 0);
        Transfer.Add(Line);

        CashCount.Add('transfer', Transfer);

        Root.Add('confirmed', true);
        Root.Add('checkPointId', CheckpointEntryNo);
        Root.Add('direction', Direction);
        Root.Add('cashCount', CashCount);

        ReturnedData := Root.AsToken();
    end;

    local procedure CreateBin(var POSPaymentBin: Record "NPR POS Payment Bin"; BinType: Option; AttachedToPOSUnitNo: Code[10])
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreatePOSBin(POSPaymentBin);
        POSPaymentBin."Bin Type" := BinType;
        POSPaymentBin."Attached to POS Unit No." := AttachedToPOSUnitNo;
        POSPaymentBin.Modify();

        // The balancing line the transfer posts resolves posting setup per store, payment method and bin,
        // so a freshly created bin needs its own setup or POS Post Entries fails before the webhook runs.
        LibraryPOSMasterData.CreatePOSPostingSetupSet(POSStore.Code, POSPaymentMethod.Code, POSPaymentBin."No.");
    end;

    local procedure CreateSecondPOSUnitNo(): Code[10]
    var
        ReceivingPOSUnit: Record "NPR POS Unit";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreatePOSUnit(ReceivingPOSUnit, POSStore.Code, POSStore."POS Posting Profile");
        exit(ReceivingPOSUnit."No.");
    end;

    /// <summary>
    /// A direct unit to unit transfer creates a bin transfer journal line and takes its document number
    /// from this profile, without checking that a series is configured, so the profile must exist and
    /// carry one. The profile is a singleton keyed on a blank code, which is why Get takes no arguments.
    /// </summary>
    local procedure SetBinTransferDocumentNoSeries()
    var
        BinTransferProfile: Record "NPR Bin Transfer Profile";
        LibraryNoSeries: Codeunit "NPR Library - No. Series";
    begin
        if not BinTransferProfile.Get() then begin
            BinTransferProfile.Init();
            BinTransferProfile.Insert();
        end;
        if BinTransferProfile.DocumentNoSeries = '' then begin
            BinTransferProfile.DocumentNoSeries := LibraryNoSeries.GenerateNoSeries();
            BinTransferProfile.Modify();
        end;
    end;

    /// <summary>
    /// A unit to unit transfer needs an End of Day profile, because the direct transfer check reads the
    /// in-transit bin from it. The mocked POS unit has no profile assigned, and GetProfile clears the
    /// record instead of failing in that case, so the profile has to be created and assigned first -
    /// otherwise the Modify below runs on a blank record and fails on Code=''.
    /// </summary>
    local procedure SetInTransitBin(InTransitBinNo: Code[10])
    var
        EndOfDayProfile: Record "NPR POS End of Day Profile";
        ProfileCode: Code[20];
    begin
        if not POSUnit.GetProfile(EndOfDayProfile) then begin
            ProfileCode := 'BINTRANSF-TEST';
            if not EndOfDayProfile.Get(ProfileCode) then begin
                EndOfDayProfile.Code := ProfileCode;
                EndOfDayProfile.Insert();
            end;
            POSUnit."POS End of Day Profile" := EndOfDayProfile.Code;
            POSUnit.Modify();
        end;

        EndOfDayProfile."In-Transit Bin Code" := InTransitBinNo;
        EndOfDayProfile.Modify();
    end;

    local procedure CreateSale()
    var
        Item: Record Item;
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
    begin
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 100;
        Item.Modify();

        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, 100, '', false);
    end;

    local procedure GetJsonInteger(JsonObj: JsonObject; PropertyName: Text): Integer
    var
        JToken: JsonToken;
    begin
        JsonObj.Get(PropertyName, JToken);
        exit(JToken.AsValue().AsInteger());
    end;

    local procedure DirectionText(TransferDirection: Option "",TransferOut,TransferIn): Text
    begin
        if TransferDirection = TransferDirection::TransferIn then
            exit('IN');
        exit('OUT');
    end;

    local procedure DirectionOut(): Integer
    begin
        exit(1);
    end;

    local procedure DirectionIn(): Integer
    begin
        exit(2);
    end;

    local procedure TransferAmount(): Decimal
    begin
        exit(10);
    end;
}