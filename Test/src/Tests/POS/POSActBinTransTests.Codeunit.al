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

        FromBinNo := POSActionBinTransferB.GetDefaultUnitBin(POSSession);
        POSActionBinTransferB.GetPosUnitFromBin(FromBinNo, PosUnit);
        CheckpointEntryNo := POSWorkshiftCheckpoint.CreateEndWorkshiftCheckpoint_POSEntry(POSUnit."POS Store Code", POSUnit."No.", POSUnit.Status);

        POSActionBinTransferB.TransferContentsToBin(POSSession, FromBinNo, CheckpointEntryNo);

        POSEntry.SetRange("POS Unit No.", POSUnit."No.");
        POSEntry.FindLast();
        POSEntry.TestField("Post Entry Status", POSEntry."Post Item Entry Status"::Posted);
        POSEntry.TestField(Description, 'Bin Transfer');
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