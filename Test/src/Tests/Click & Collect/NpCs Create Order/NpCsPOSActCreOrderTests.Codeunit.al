codeunit 85084 "NPR NpCs POSAct CreOrder Tests"
{
    Subtype = Test;

    var
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        Assert: Codeunit "Assert";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ModalPageHandler')]

    procedure NpCsCreateOrder()
    var
        NpCsLibrary: Codeunit "NPR Library Click & Collect";
        NpCsCreateOrderB: Codeunit "NPR POSAction Create CnC Ord B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        TempNpCsStore: Record "NPR NpCs Store" temporary;
        POSSale: Codeunit "NPR POS Sale";
        Item: Record Item;
        FromStoreCode: Code[20];
        ToStoreCode: Code[20];
        LibrarySales: Codeunit "Library - Sales";
        Customer: Record Customer;
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        CollectWFCode: Code[20];
        NpCsDocument: Record "NPR NpCs Document";
        SalePOS: Record "NPR POS Sale";
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        POSSale.GetCurrentSale(SalePOS);

        NpCsLibrary.CheckCollectWS(); //webservice

        NpCsLibrary.CreateSalesOrderWF(NpCsWorkflowModule);
        CollectWFCode := NpCsLibrary.CreateCollectWF(NpCsWorkflowModule); //workflow

        FromStoreCode := NpCsLibrary.CreateLocalCollectStore();
        ToStoreCode := NpCsLibrary.CreateLocalCollectStore();

        NpCsLibrary.CreateWorkflowRel(FromStoreCode, CollectWFCode);
        LibrarySales.CreateCustomer(Customer);

        NpCsCreateOrderB.SelectToStoreCode(TempNpCsStore, FromStoreCode);
        NpCsLibrary.CreateWorkflowRel(TempNpCsStore.Code, CollectWFCode);

        NpCsCreateOrderB.ExportToDocument(Customer."No.", RetailSalesDocMgt, false);
        NpCsCreateOrderB.CreateCollectOrder(FromStoreCode, TempNpCsStore.Code, CollectWFCode, 0, RetailSalesDocMgt, false);

        NpCsDocument.SetRange("Reference No.", SalePOS."Sales Ticket No.");

        Assert.IsTrue(NpCsDocument.FindFirst(), 'Collect Order is created');

    end;

    [ModalPageHandler]
    procedure ModalPageHandler(var Page: Page "NPR NpCs Stores by Distance"; var ActionResponse: Action)
    begin
        ActionResponse := Action::LookupOK;
    end;
}