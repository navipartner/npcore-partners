codeunit 85108 "NPR NpCs POSAct ProcOrder Test"
{
    Subtype = Test;

    var

        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        Assert: Codeunit "Assert";
        NpCsDocument: Record "NPR NpCs Document";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('OpenModalPageHandler')]
    procedure NpCsProcessOrder()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibrarySales: Codeunit "Library - Sales";
        POSSale: Codeunit "NPR POS Sale";
        ProcessOrderB: Codeunit "NPR NpCs POSAction Proc.OrderB";
        SalesHeader: Record "Sales Header";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateSalesOrder(SalesHeader);
        // [Given] Collect Order
        CreateNpCsDocument(SalesHeader);

        // [Then]
        ProcessOrderB.RunCollectInStoreOrders('', 1);
    end;

    [ModalPageHandler]
    procedure OpenModalPageHandler(var Page: Page "NPR NpCs Coll. Store Orders"; var ActionResponse: Action)
    begin
        Page.GetRecord(NpCsDocument);
        Assert.IsTrue(true, 'Page did not opened.');
    end;

    local procedure CreateNpCsDocument(SalesHeader: Record "Sales Header")
    begin
        NpCsDocument.Init();
        NpCsDocument."Entry No." := 0;
        NpCsDocument.Type := NpCsDocument.Type::"Collect in Store";
        NpCsDocument."Document Type" := SalesHeader."Document Type";
        NpCsDocument.Validate("Document No.", SalesHeader."No.");
        if SalesHeader."External Document No." <> '' then
            NpCsDocument."Reference No." := SalesHeader."External Document No.";
        NpCsDocument."Processing Status" := NpCsDocument."Processing Status"::Pending;
        NpCsDocument.Insert(true);
    end;
}