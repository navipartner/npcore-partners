codeunit 85102 "NPR POS ActScanExchLabel Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ScanExchangeLabel()
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        ExchLabelMgt: Codeunit "NPR Exchange Label Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Item: Record Item;
        SaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        PrintType: Option Single,LineQuantity,All,Selection,Package;
        ValidFromDate: Date;
        ExchLabel: Record "NPR Exchange Label";
        SalesTicketNo: Code[20];
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSActionScanExchLabelB: Codeunit "NPR POS Action:ScanExchLabel B";
        BarCode: Text;
    begin
        PrintType := PrintType::All;
        ValidFromDate := WorkDate();

        InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        NPRLibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        CreateSetup();

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        SalesTicketNo := SaleLinePOS."Sales Ticket No.";

        ExchLabelMgt.PrintLabelsFromPOSWithoutPrompts(PrintType, SaleLinePOS, ValidFromDate);
        ExchLabel.SetRange("Sales Ticket No.", SalesTicketNo);
        ExchLabel.FindFirst();
        BarCode := ExchLabel.Barcode;

        POSActionScanExchLabelB.HandleExchangeLabelBarcode(BarCode, POSSale, SaleLine);

        Assert.IsTrue(SaleLinePOS."No." = ExchLabel."Item No.", 'No. inserted');
        Assert.IsTrue(SaleLinePOS.Quantity = ExchLabel.Quantity, 'Qty inserted');
    end;

    local procedure CreateSetup()
    var
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
        LibraryNoSeries: Codeunit "NPR Library - No. Series";
        VarietySetup: Record "NPR Variety Setup";
    begin

        if not ExchangeLabelSetup.Get() then begin
            ExchangeLabelSetup.Init();
            ExchangeLabelSetup.Insert();
        end;

        ExchangeLabelSetup."EAN Prefix Exhange Label" := '27';
        ExchangeLabelSetup."Exchange Label  No. Series" := LibraryNoSeries.GenerateNoSeries();
        ExchangeLabelSetup.Modify();

        if not VarietySetup.Get() then begin
            VarietySetup.Init();
            VarietySetup.Insert();
        end;

        VarietySetup."EAN-Internal" := 27;
        VarietySetup.Modify();
    end;

    procedure InitializeData(var Initialized: Boolean; var POSUnit: Record "NPR POS Unit"; var POSStore: Record "NPR POS Store"; var POSPaymentMethod: Record "NPR POS Payment Method")
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Record "NPR POS Setup";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
            Initialized := true;
        end;

        Commit();
    end;

    procedure CreatePOSStore(var POSStore: Record "NPR POS Store"; POSProfileCode: Code[20])
    var
        Location: Record Location;
        LibraryWarehouse: Codeunit "Library - Warehouse";
    begin
        POSStore.Init();
        POSStore.Validate(Code, '01');

        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        POSStore.Validate("Location Code", Location.Code);
        POSStore."POS Posting Profile" := POSProfileCode;

        POSStore.Insert(true);

        NPRLibraryPOSMasterData.CreatePOSPostingSetupSet(POSStore.Code, '', '');
    end;

}