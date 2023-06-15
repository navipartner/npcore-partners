codeunit 85103 "NPR NpCs POSAct DelOrder Tests"
{
    Subtype = Test;

    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ModalPageHandler,ConfirmYesHandler')]
    procedure NpCsDeliverOrder()
    var
        Customer: Record Customer;
        Item: Record Item;
        NpCsDocument: Record "NPR NpCs Document";
        NpCsDocumentCollect: Record "NPR NpCs Document";
        TempNpCsStore: Record "NPR NpCs Store" temporary;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        LibrarySales: Codeunit "Library - Sales";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NpCsDeliverOrderB: Codeunit "NPR NpCs POSAct. Deliv.Order-B";
        NpCsCreateOrderB: Codeunit "NPR NpCs POSAction Cr. Order B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        CollectWFCode: Code[20];
        FromStoreCode: Code[20];
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        POSSale.GetCurrentSale(SalePOS);

        CreateCollectSetup(FromStoreCode, CollectWFCode);

        LibrarySales.CreateCustomer(Customer);

        NpCsCreateOrderB.SelectToStoreCode(TempNpCsStore, FromStoreCode);
        NpCsCreateOrderB.ExportToDocument(Customer."No.", RetailSalesDocMgt, false);
        NpCsCreateOrderB.CreateCollectOrder(FromStoreCode, TempNpCsStore.Code, CollectWFCode, 0, RetailSalesDocMgt);

        NpCsDocument.SetRange("Reference No.", SalePOS."Sales Ticket No.");
        NpCsDocument.FindFirst();
        NpCsDocumentCollect.Init();
        NpCsDocumentCollect.TransferFields(NpCsDocument);
        NpCsDocumentCollect."Entry No." := 0;
        NpCsDocumentCollect.Type := NpCsDocumentCollect.Type::"Collect in Store";
        NpCsDocumentCollect.Insert(true);

        //[When]
        NpCsDeliverOrderB.FindAndConfirmDoc(NpCsDocumentCollect, NpCsDocument."Reference No.", '', 0, false, false);
        NpCsDeliverOrderB.DeliverOrder('', POSSession, NpCsDocumentCollect);

        //[Then]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.SetRange("Sales Document Type", SaleLinePOS."Sales Document Type"::Order);
        SaleLinePOS.SetRange("Sales Document No.", NpCsDocumentCollect."Document No.");
        if not SaleLinePOS.FindFirst() then
            Assert.AssertRecordNotFound();
    end;

    [ModalPageHandler]
    procedure ModalPageHandler(var Page: Page "NPR NpCs Stores by Distance"; var ActionResponse: Action)
    begin
        ActionResponse := Action::LookupOK;
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    local procedure CreateCollectSetup(var FromStoreCode: Code[20]; var CollectWFCode: Code[20])
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsLibrary: Codeunit "NPR Library Click & Collect";
        ToStoreCode: Code[20];
    begin
        NpCsLibrary.CheckCollectWS();

        NpCsLibrary.CreateSalesOrderWF(NpCsWorkflowModule);
        CollectWFCode := NpCsLibrary.CreateCollectWF(NpCsWorkflowModule);

        FromStoreCode := NpCsLibrary.CreateLocalCollectStore();
        ToStoreCode := NpCsLibrary.CreateLocalCollectStore();

        NpCsLibrary.CreateWorkflowRel(FromStoreCode, CollectWFCode);
        NpCsLibrary.CreateWorkflowRel(ToStoreCode, CollectWFCode);
    end;
}