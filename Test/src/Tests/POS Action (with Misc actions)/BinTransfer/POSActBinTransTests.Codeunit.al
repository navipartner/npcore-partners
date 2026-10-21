codeunit 85054 "NPR POS Act. Bin Trans. Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Quantity: Decimal;
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]

    [HandlerFunctions('PageHandler_POSPaymentBinCheckpoint_LookupOK,ConfirmYesHandler')]
    procedure TransferContentsToBin()
    var
        POSEntry: Record "NPR POS Entry";
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSWorkshiftCheckpoint: Codeunit "NPR POS Workshift Checkpoint";
        FromBinNo: Code[10];
        CheckpointEntryNo: Integer;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        CreateSales(1);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        FromBinNo := POSActionBinTransferB.GetDefaultUnitBin(POSUnit);
        POSActionBinTransferB.GetPosUnitFromBin(FromBinNo, PosUnit);
        CheckpointEntryNo := POSWorkshiftCheckpoint.CreateEndWorkshiftCheckpoint_POSEntry(POSUnit."POS Store Code", POSUnit."No.", POSUnit.Status);

        POSActionBinTransferB.TransferContentsToBin(POSSession, FromBinNo, CheckpointEntryNo);

        POSEntry.SetRange("POS Unit No.", POSUnit."No.");
        POSEntry.FindLast();
        POSEntry.TestField("Post Entry Status", POSEntry."Post Item Entry Status"::Posted);
        POSEntry.TestField(Description, 'Bin Transfer');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TransferInToEmptyDrawer_ReplenishesFloat()
    var
        BankBin: Record "NPR POS Payment Bin";
        EmptyPOSUnit: Record "NPR POS Unit";
        PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        UnusedPmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        UnusedPOSPaymentMethod: Record "NPR POS Payment Method";
        SalePOS: Record "NPR POS Sale";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
        POSSale: Codeunit "NPR POS Sale";
        ContextData: JsonObject;
        DrawerBinNo: Code[10];
        CheckpointEntryNo: Integer;
        ProcessedCheckpointEntryNo: Integer;
        TransferDirection: Option "",TransferOut,TransferIn;
    begin
        // [Given] A POS unit whose cash drawer is empty, and a bank bin to take the opening float from
        InitializeEmptyDrawer(EmptyPOSUnit, DrawerBinNo, BankBin);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, EmptyPOSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] A second counted cash method the store never uses, so it has no posting setup at all
        LibraryPOSMasterData.CreatePOSPaymentMethod(UnusedPOSPaymentMethod, '', UnusedPOSPaymentMethod."Processing Type"::CASH);
        UnusedPOSPaymentMethod."Include In Counting" := UnusedPOSPaymentMethod."Include In Counting"::YES;
        UnusedPOSPaymentMethod.Modify();

        // [When] The transfer in dialog opens on the empty drawer
        ContextData := POSActionBinTransferB.GetBinTransferContextData(EmptyPOSUnit."No.", DrawerBinNo, TransferDirection::TransferIn);
        CheckpointEntryNo := GetJsonInteger(ContextData, 'checkPointId');

        // [Then] The counted cash payment method has a line to receive the float into, and it starts empty
        PmtBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", CheckpointEntryNo);
        PmtBinCheckpoint.SetRange("Payment Method No.", POSPaymentMethod.Code);
        Assert.IsTrue(PmtBinCheckpoint.FindFirst(), 'Transfer in to an empty cash drawer must offer a line for the counted cash payment method.');
        Assert.AreEqual(0, PmtBinCheckpoint."Calculated Amount Incl. Float", 'The test drawer must be empty, otherwise the line exists on master too.');

        // [Then] Receiving 10 from the bank posts and leaves 10 in the drawer
        Assert.IsTrue(
            POSActionBinTransferB.ProcessBinTransfer(
                BuildTransferInFromBank(CheckpointEntryNo, PmtBinCheckpoint."Entry No.", BankBin."No.", 10),
                SalePOS, EmptyPOSUnit."No.", DrawerBinNo, false, ProcessedCheckpointEntryNo),
            'The transfer in to an empty cash drawer must post.');
        PmtBinCheckpoint.Find();
        Assert.AreEqual(10, PmtBinCheckpoint."New Float Amount", 'The drawer must hold the amount received from the bank.');

        // [Then] The untouched counted method posted as a zero line without needing posting setup
        UnusedPmtBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", CheckpointEntryNo);
        UnusedPmtBinCheckpoint.SetRange("Payment Method No.", UnusedPOSPaymentMethod.Code);
        Assert.IsTrue(UnusedPmtBinCheckpoint.FindFirst(), 'Every counted payment method must get a line on transfer in, even one the user does not touch.');
        Assert.AreEqual(UnusedPmtBinCheckpoint.Status::TRANSFERED, UnusedPmtBinCheckpoint.Status, 'The untouched zero line must post along with the transfer.');
        Assert.AreEqual(0, UnusedPmtBinCheckpoint."Bank Deposit Amount", 'The untouched line must not receive any bank amount.');
        Assert.AreEqual(0, UnusedPmtBinCheckpoint."Move to Bin Amount", 'The untouched line must not receive any bin amount.');
        Assert.AreEqual(0, UnusedPmtBinCheckpoint."New Float Amount", 'The untouched line must stay at zero.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TransferOutOfEmptyDrawer_OffersNoLine()
    var
        BankBin: Record "NPR POS Payment Bin";
        EmptyPOSUnit: Record "NPR POS Unit";
        PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
        ContextData: JsonObject;
        DrawerBinNo: Code[10];
        TransferDirection: Option "",TransferOut,TransferIn;
    begin
        // [Given] A POS unit whose cash drawer is empty
        InitializeEmptyDrawer(EmptyPOSUnit, DrawerBinNo, BankBin);

        // [When] The transfer out dialog opens on the empty drawer
        ContextData := POSActionBinTransferB.GetBinTransferContextData(EmptyPOSUnit."No.", DrawerBinNo, TransferDirection::TransferOut);

        // [Then] There is still nothing to transfer out
        PmtBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", GetJsonInteger(ContextData, 'checkPointId'));
        PmtBinCheckpoint.SetRange("Payment Method No.", POSPaymentMethod.Code);
        Assert.IsTrue(PmtBinCheckpoint.IsEmpty(), 'Transfer out of an empty cash drawer must not offer a line for the cash payment method.');
    end;

    local procedure InitializeEmptyDrawer(var EmptyPOSUnit: Record "NPR POS Unit"; var DrawerBinNo: Code[10]; var BankBin: Record "NPR POS Payment Bin")
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionBinTransferB: Codeunit "NPR POS Action: Bin Transfer B";
    begin
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);

        POSPaymentMethod.Get(POSPaymentMethod.Code);
        POSPaymentMethod."Include In Counting" := POSPaymentMethod."Include In Counting"::YES;
        POSPaymentMethod."Bin for Virtual-Count" := '';
        POSPaymentMethod.Modify();

        LibraryPOSMasterData.CreatePOSUnit(EmptyPOSUnit, POSStore.Code, POSStore."POS Posting Profile");
        DrawerBinNo := POSActionBinTransferB.GetDefaultUnitBin(EmptyPOSUnit);

        LibraryPOSMasterData.CreatePOSBin(BankBin);
        BankBin."Bin Type" := BankBin."Bin Type"::BANK;
        BankBin.Modify();
        LibraryPOSMasterData.CreatePOSPostingSetupSet(POSStore.Code, POSPaymentMethod.Code, BankBin."No.");
    end;

    local procedure BuildTransferInFromBank(CheckpointEntryNo: Integer; PmtBinCheckpointEntryNo: Integer; BankBinNo: Code[10]; Amount: Decimal) ReturnedData: JsonToken
    var
        CashCount: JsonObject;
        Line: JsonObject;
        Root: JsonObject;
        Transfer: JsonArray;
    begin
        Line.Add('id', PmtBinCheckpointEntryNo);
        Line.Add('paymentTypeNo', '');
        Line.Add('bankDepositBinCode', BankBinNo);
        Line.Add('bankDepositReference', '');
        Line.Add('bankDepositAmount', Amount);
        Line.Add('binNo', '');
        Line.Add('binTransId', '');
        Line.Add('binAmount', 0);
        Line.Add('prestagedTransferIdBank', 0);
        Line.Add('prestagedTransferIdBin', 0);
        Transfer.Add(Line);

        CashCount.Add('transfer', Transfer);

        Root.Add('confirmed', true);
        Root.Add('checkPointId', CheckpointEntryNo);
        Root.Add('direction', 'IN');
        Root.Add('cashCount', CashCount);

        ReturnedData := Root.AsToken();
    end;

    local procedure GetJsonInteger(JsonObj: JsonObject; PropertyName: Text): Integer
    var
        JToken: JsonToken;
    begin
        JsonObj.Get(PropertyName, JToken);
        exit(JToken.AsValue().AsInteger());
    end;

    local procedure CreateSales(NoOfSales: Integer)
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        Item1: Record Item;
        Item2: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        i: Integer;
    begin
        if NoOfSales < 1 then
            exit;

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, POSUnit, POSStore);
        Item1."Unit Price" := 10;
        Item1.Modify();

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item2, POSUnit, POSStore);
        Item2."Unit Price" := 20;
        Item2.Modify();

        for i := 1 to NoOfSales do begin
            NPRLibraryPOSMock.CreateItemLine(POSSession, Item1."No.", 1);
            NPRLibraryPOSMock.CreateItemLine(POSSession, Item2."No.", 1);
            NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, 30, '', false);
        end;
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure ClickOnOKMsg(Msg: Text[1024])
    var
        Text005: Label 'Adjust Quantity %1 performed';
    begin
        Assert.IsTrue(Msg = StrSubstNo(Text005, Quantity), Msg);
    end;

    [ModalPageHandler]
    procedure PageHandler_POSPaymentBinCheckpoint_LookupOK(var BinToTransfer: Page "NPR POS Payment Bin Checkpoint"; var ActionResponse: Action)
    begin
        BinToTransfer.DoOnOpenPageProcessing();
        BinToTransfer.DoOnClosePageProcessing();
        ActionResponse := Action::LookupOK;
    end;
}