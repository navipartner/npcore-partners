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
        POSPaymentMethod: Record "NPR POS Payment Method";
        LibrarySales: Codeunit "Library - Sales";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NpCsDeliverOrderB: Codeunit "NPR POSAction Deliv. CnC Ord.B";
        NpCsCreateOrderB: Codeunit "NPR POSAction Create CnC Ord B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        NpCsLibrary: Codeunit "NPR Library Click & Collect";
        CollectWFCode: Code[20];
        FromStoreCode: Code[20];
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 10;
        Item.Modify();
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 2);
        POSSale.GetCurrentSale(SalePOS);

        CreateCollectSetup(FromStoreCode, CollectWFCode);

        LibrarySales.CreateCustomer(Customer);

        NpCsCreateOrderB.SelectToStoreCode(TempNpCsStore, FromStoreCode);
        NpCsLibrary.CreateWorkflowRel(TempNpCsStore.Code, CollectWFCode);

        NpCsCreateOrderB.ExportToDocument(Customer."No.", RetailSalesDocMgt, false);
        NpCsCreateOrderB.CreateCollectOrder(FromStoreCode, TempNpCsStore.Code, CollectWFCode, 0, RetailSalesDocMgt, false);

        NpCsDocument.SetRange("Reference No.", SalePOS."Sales Ticket No.");
        NpCsDocument.FindFirst();
        NpCsDocumentCollect.Init();
        NpCsDocumentCollect.TransferFields(NpCsDocument);
        NpCsDocumentCollect."Entry No." := 0;
        NpCsDocumentCollect.Type := NpCsDocumentCollect.Type::"Collect in Store";
        NpCsDocumentCollect."Bill via" := NpCsDocumentCollect."Bill via"::"Sales Document";
        NpCsDocumentCollect.Insert(true);

        //[When] Delivering a Collect Order with Bill Via=Sales Document
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NpCsDeliverOrderB.FindAndConfirmDoc(NpCsDocumentCollect, NpCsDocument."Reference No.", '', 0, false, false);
        NpCsDeliverOrderB.DeliverOrder('', POSSession, NpCsDocumentCollect);

        //[Then] Customer must be added to sale
        POSSale.GetCurrentSale(SalePOS);
        Assert.IsTrue(SalePOS."Customer No." = Customer."No.", 'Customer is added to sale');

        //[Then] Lines are added to POS and linked with Collect document
        TestPOSLinesAndReference(SalePOS, NpCsDocumentCollect."Entry No.", 2);  // 1 Comment and 1 "Customer Deposit"

        //[Then] POS Line is linked to Sales Order
        TestLinkedToSalesOrder(SalePOS, NpCsDocumentCollect."Document No.", true);


        //[When] A Collect Line on POS is deleted
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.DeleteLine();

        //[Then] all lines and references must be deleted
        TestPOSLinesAndReference(SalePOS, NpCsDocumentCollect."Entry No.", 0);  // No lines


        //[When] Delivering a Collect Order with Bill Via=POS
        NpCsDocumentCollect."Bill via" := NpCsDocumentCollect."Bill via"::POS;
        NpCsDocumentCollect.Modify();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NpCsDeliverOrderB.FindAndConfirmDoc(NpCsDocumentCollect, NpCsDocument."Reference No.", '', 0, false, false);
        NpCsDeliverOrderB.DeliverOrder('', POSSession, NpCsDocumentCollect);

        //[Then] Customer must be added to sale
        POSSale.GetCurrentSale(SalePOS);
        Assert.IsTrue(SalePOS."Customer No." = Customer."No.", 'Customer is added to sale');

        //[Then] Lines are added to POS and linked with Collect document
        TestPOSLinesAndReference(SalePOS, NpCsDocumentCollect."Entry No.", 3);  // 1 Comment and 1 for each Sales Line (2)

        //[Then] POS Line is not linked to Sales Order
        TestLinkedToSalesOrder(SalePOS, NpCsDocumentCollect."Document No.", false);


        //[When] A Collect Line on POS is deleted
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.DeleteLine();

        //[Then] all lines and references must be deleted
        TestPOSLinesAndReference(SalePOS, NpCsDocumentCollect."Entry No.", 0);  // No lines

        //[When] Delivering a Collect Order with Bill Via=POS and Prepayment
        NpCsDocumentCollect."Bill via" := NpCsDocumentCollect."Bill via"::POS;
        NpCsDocumentCollect."Prepaid Amount" := 1;
        NpCsDocumentCollect.Modify();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NpCsDeliverOrderB.FindAndConfirmDoc(NpCsDocumentCollect, NpCsDocument."Reference No.", '', 0, false, false);
        NpCsDeliverOrderB.DeliverOrder('', POSSession, NpCsDocumentCollect);

        //[Then] Collect order should be changed to Bill-Via = Sales Document
        NpCsDocumentCollect.Get(NpCsDocumentCollect."Entry No.");
        Assert.AreEqual(NpCsDocumentCollect."Bill via"::"Sales Document", NpCsDocumentCollect."Bill via", 'Bill via changed to "Sales Document"');


        //[When] Deliver sale is ended 
        NpCsDocumentCollect."Bill via" := NpCsDocumentCollect."Bill via"::POS;
        NpCsDocumentCollect."Prepaid Amount" := 0;
        NpCsDocumentCollect."Delivery Status" := NpCsDocumentCollect."Delivery Status"::Ready;
        NpCsDocumentCollect."Delivery Document Type" := NpCsDocumentCollect."Delivery Document Type"::" ";
        NpCsDocumentCollect.Modify();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NpCsDeliverOrderB.FindAndConfirmDoc(NpCsDocumentCollect, NpCsDocument."Reference No.", '', 0, false, false);
        NpCsDeliverOrderB.DeliverOrder('', POSSession, NpCsDocumentCollect);
        POSSale.GetCurrentSale(SalePOS);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
        Assert.IsTrue(LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, 30, ''), 'Sale is ended');

        //[Then] Delivery fields must be updated
        NpCsDocumentCollect.Get(NpCsDocumentCollect."Entry No.");
        Assert.AreEqual(NpCsDocumentCollect."Delivery Status"::Delivered, NpCsDocumentCollect."Delivery Status", 'Delivery Status is set to Delivered');
        Assert.AreEqual(SalePOS."Sales Ticket No.", NpCsDocumentCollect."Delivery Document No.", 'Delivery Document is set');
        Assert.AreEqual(NpCsDocumentCollect."Delivery Document Type"::"POS Entry", NpCsDocumentCollect."Delivery Document Type", 'Delivery Document Type is set');

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

    local procedure TestPOSLinesAndReference(SalePOS: Record "NPR POS Sale"; CollectDocumentEntry: Integer; ExpectedNoOfLines: Integer)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref.";

    begin
        NpCsSaleLinePOSReference.SetRange("Register No.", SalePOS."Register No.");
        NpCsSaleLinePOSReference.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        NpCsSaleLinePOSReference.SetRange("Sale Date", SalePOS.Date);
        NpCsSaleLinePOSReference.SetRange("Collect Document Entry No.", CollectDocumentEntry);
        Assert.AreEqual(ExpectedNoOfLines, NpCsSaleLinePOSReference.Count, 'NpCs Reference line count match expected number');

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        Assert.AreEqual(ExpectedNoOfLines, SaleLinePOS.Count, 'POS Sale Line count match expected number');
        if ExpectedNoOfLines > 0 then begin
            NpCsSaleLinePOSReference.FindSet();
            repeat
                Assert.IsTrue(SaleLinePOS.Get(NpCsSaleLinePOSReference."Register No.", NpCsSaleLinePOSReference."Sales Ticket No.", NpCsSaleLinePOSReference."Sale Date", NpCsSaleLinePOSReference."Sale Type", NpCsSaleLinePOSReference."Sale Line No."), 'Reference Line is linked to existing POS Sale Line');
            until NpCsSaleLinePOSReference.Next() = 0;
        end;
    end;

    local procedure TestLinkedToSalesOrder(SalePOS: Record "NPR POS Sale"; DocumentNo: Code[20]; LinkedMustBeFound: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sales Document Type", SaleLinePOS."Sales Document Type"::Order);
        SaleLinePOS.SetRange("Sales Document No.", DocumentNo);
        Assert.AreEqual(LinkedMustBeFound, not SaleLinePOS.IsEmpty, 'A POS Sale Line is linked to the Sales order');
    end;
}