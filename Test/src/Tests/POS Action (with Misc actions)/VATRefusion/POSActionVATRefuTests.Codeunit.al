codeunit 85125 "NPR POSAction: VAT Refu. Tests"
{
    Subtype = Test;

    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSSession: Codeunit "NPR POS Session";
        Assert: Codeunit "Assert";
        VATRefusionB: Codeunit "NPR POSAction: VAT Refusion-B";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateMinMaxAmt_PaymentMethod()
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        // [Given] POS & Payment setup
        CreatePOSPaymentMethod(POSPaymentMethod, 'TEST', 100, 10000);

        // [Then] Amount lower then Min should give error
        asserterror VATRefusionB.ValidateMinMaxAmount(POSPaymentMethod, 10);

        // [Then] Amount between Min and Max should not give error
        VATRefusionB.ValidateMinMaxAmount(POSPaymentMethod, 1000);

        // [Then] Amount larger then Max should give error
        asserterror VATRefusionB.ValidateMinMaxAmount(POSPaymentMethod, 100000);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DoRefusion()
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS2: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        VATAmount: Decimal;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        CreatePOSPaymentMethod(POSPaymentMethod, 'TEST', 100, 10000);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [Given] Calc VAT Amount for the line
        VATAmount := VATRefusionB.CalcVATFromSale(SalePOS);

        // [When] We do Refusion
        VATRefusionB.DoRefusion(POSPaymentMethod.Code, VATAmount);

        // [Then] There should be a Line for a VAT refusion
        SaleLinePOS2.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOS2.SetRange("Sale Type", SaleLinePOS."Sale Type");
        SaleLinePOS2.SetRange("Line No.", (SaleLinePOS."Line No." + 10000));
        SaleLinePOS2.SetRange("No.", 'TEST');
        SaleLinePOS2.SetRange("Amount Including VAT", VATAmount);
        Assert.IsTrue(SaleLinePOS2.FindFirst(), 'VAT Refusion')
    end;

    local procedure CreatePOSPaymentMethod(var POSPaymentMethod: Record "NPR POS Payment Method"; PaymentMethodCode: Code[10]; MinAmt: Decimal; MaxAmt: Decimal)
    begin
        if not POSPaymentMethod.Get(PaymentMethodCode) then begin
            POSPaymentMethod.Init();
            POSPaymentMethod.Code := PaymentMethodCode;
            POSPaymentMethod.Insert();
        end;
        POSPaymentMethod.Description := PaymentMethodCode;
        POSPaymentMethod."Minimum Amount" := MinAmt;
        POSPaymentMethod."Maximum Amount" := MaxAmt;
        POSPaymentMethod."Return Payment Method Code" := PaymentMethodCode;
        POSPaymentMethod."Include In Counting" := POSPaymentMethod."Include In Counting"::VIRTUAL;
        POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;
        POSPaymentMethod."Bin for Virtual-Count" := 'AUTO-BIN';
        POSPaymentMethod."Rounding Gains Account" := '9140';
        POSPaymentMethod."Rounding Losses Account" := '9140';
        POSPaymentMethod.Modify();
    end;
}