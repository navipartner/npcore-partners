codeunit 85117 "NPR POS Act.Set VATBPGrp Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";

    [Test]
    [HandlerFunctions('SelectVATBPGrpPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetVATBPGrp()
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        POSActSetVATBPGrpB: Codeunit "NPR POSAction: Set VAT BPGrp B";
        Item: Record Item;
        LibraryERM: Codeunit "Library - ERM";
        POSSesion: Codeunit "NPR POS Session";
    begin
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        POSActSetVATBPGrpB.SetVATBusPostingGroup(POSSale);

        POSSesion.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        Assert.AreEqual(SalePOS."VAT Bus. Posting Group", VATBusinessPostingGroup.Code, 'VAT Bus Posting Group inserted');
    end;

    [ModalPageHandler]
    procedure SelectVATBPGrpPageHandler(var VATBusPostGrp: TestPage "VAT Business Posting Groups")
    begin
        VATBusPostGrp.GoToRecord(VATBusinessPostingGroup);
        VATBusPostGrp.OK().Invoke();
    end;
}