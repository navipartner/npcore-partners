codeunit 85253 "NPR Library - RS Retail Loc."
{
    Access = Internal;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryPriceCalculation: Codeunit "Library - Price Calculation";
        Assert: Codeunit "Assert";
        _Initialized: Boolean;
        _VATBusPostGrp: Code[20];
        _STDVATProdGrp: Code[20];
        _REDVATProdGrp: Code[20];
        _GenBusPostGrp: Code[20];
        _GenProdPostGrp: Code[20];
        _InvtPostGrp: Code[20];
        _GlobalVATAcc: Code[20];
        _GlobalMarginAcc: Code[20];
        _STDVATRate: Decimal;
        _REDVATRate: Decimal;

    #region Setup
    internal procedure InitializeSetup()
    var
        RSSetup: Record "NPR RS R Localization Setup";
        VATPostingSetupSTD: Record "VAT Posting Setup";
        VATPostingSetupRED: Record "VAT Posting Setup";
        VATPostingSetupZero: Record "VAT Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        VATBusPostGrp: Record "VAT Business Posting Group";
        VATProdPostGrpSTD: Record "VAT Product Posting Group";
        VATProdPostGrpRED: Record "VAT Product Posting Group";
        GenBusPostGrp: Record "Gen. Business Posting Group";
        GenProdPostGrp: Record "Gen. Product Posting Group";
        InvtPostGrp: Record "Inventory Posting Group";
        InventorySetup: Record "Inventory Setup";
    begin
        if _Initialized then
            exit;

        _STDVATRate := 20;
        _REDVATRate := 10;

        LibraryERM.CreateVATBusinessPostingGroup(VATBusPostGrp);
        _VATBusPostGrp := VATBusPostGrp.Code;
        LibraryERM.CreateVATProductPostingGroup(VATProdPostGrpSTD);
        _STDVATProdGrp := VATProdPostGrpSTD.Code;
        LibraryERM.CreateVATProductPostingGroup(VATProdPostGrpRED);
        _REDVATProdGrp := VATProdPostGrpRED.Code;

        LibraryERM.CreateGenBusPostingGroup(GenBusPostGrp);
        _GenBusPostGrp := GenBusPostGrp.Code;
        LibraryERM.CreateGenProdPostingGroup(GenProdPostGrp);
        _GenProdPostGrp := GenProdPostGrp.Code;
        LibraryInventory.CreateInventoryPostingGroup(InvtPostGrp);
        _InvtPostGrp := InvtPostGrp.Code;

        // STD 20% and RED 10% setups used by items
        CreateVATPostingSetup(VATPostingSetupSTD, _VATBusPostGrp, _STDVATProdGrp, _STDVATRate);
        CreateVATPostingSetup(VATPostingSetupRED, _VATBusPostGrp, _REDVATProdGrp, _REDVATRate);
        // A (VATBus, '') setup at 0% so the current (buggy) code posts PDV=0 instead of erroring
        CreateVATPostingSetup(VATPostingSetupZero, _VATBusPostGrp, '', 0);

        SetupGeneralPostingSetup(_GenBusPostGrp, _GenProdPostGrp);
        // Transfers post inventory with a blank Gen. Bus. Posting Group, so a GPS with blank bus group is required too.
        SetupGeneralPostingSetup('', _GenProdPostGrp);

        _GlobalVATAcc := LibraryERM.CreateGLAccountNo();
        _GlobalMarginAcc := LibraryERM.CreateGLAccountNo();

        if not RSSetup.Get() then begin
            RSSetup.Init();
            RSSetup.Insert();
        end;
        RSSetup."Enable RS Retail Localization" := true;
        RSSetup."RS Calc. VAT GL Account" := _GlobalVATAcc;
        RSSetup."RS Calc. Margin GL Account" := _GlobalMarginAcc;
        RSSetup."RS Ret. Localization Country" := RSSetup."RS Ret. Localization Country"::Serbia;
        RSSetup."RS Nivelation Hdr No. Series" := LibraryERM.CreateNoSeriesCode();
        RSSetup."RS Posted Niv. No. Series" := LibraryERM.CreateNoSeriesCode();
        RSSetup.Modify();

        // Match production: inventory cost posts to G/L automatically so retail accounts reflect the full retail value.
        InventorySetup.Get();
        InventorySetup.Validate("Automatic Cost Posting", true);
        InventorySetup.Validate("Automatic Cost Adjustment", InventorySetup."Automatic Cost Adjustment"::Always);
        InventorySetup.Modify();

        _Initialized := true;
    end;

    // Configures an Additional Reporting Currency the way a company that reports in a second currency has it.
    // Gen. Jnl.-Post Line's add.-currency residual handling only engages when one is set, so this is what makes the
    // RS G/L additions meet that path at all - and they must survive it (see the purchase ACY test).
    internal procedure SetAdditionalReportingCurrency()
    var
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
    begin
        LibraryERM.CreateCurrency(Currency);
        Currency.Validate("Amount Rounding Precision", 0.01);
        Currency.Validate("Unit-Amount Rounding Precision", 0.01);
        Currency.Validate("Residual Gains Account", LibraryERM.CreateGLAccountNo());
        Currency.Validate("Residual Losses Account", LibraryERM.CreateGLAccountNo());
        Currency.Validate("Realized Gains Acc.", LibraryERM.CreateGLAccountNo());
        Currency.Validate("Realized Losses Acc.", LibraryERM.CreateGLAccountNo());
        Currency.Modify(true);
        LibraryERM.CreateRandomExchangeRate(Currency.Code);

        // Assigned directly: Validate launches the "Adjust Add. Reporting Currency" batch job (unhandled UI in tests).
        GLSetup.Get();
        GLSetup."Additional Reporting Currency" := Currency.Code;
        GLSetup.Modify();
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATBus: Code[20]; VATProd: Code[20]; Rate: Decimal)
    begin
        if not VATPostingSetup.Get(VATBus, VATProd) then begin
            VATPostingSetup.Init();
            VATPostingSetup.Validate("VAT Bus. Posting Group", VATBus);
            VATPostingSetup.Validate("VAT Prod. Posting Group", VATProd);
            VATPostingSetup.Insert(true);
        end;
        VATPostingSetup.Validate("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        // Distinct VAT Identifier per rate - BC requires a single VAT % per identifier.
        VATPostingSetup."VAT Identifier" := CopyStr('RS' + Format(Rate), 1, MaxStrLen(VATPostingSetup."VAT Identifier"));
        VATPostingSetup.Validate("VAT %", Rate);
        VATPostingSetup.Validate("Sales VAT Account", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Validate("Purchase VAT Account", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Modify(true);
    end;

    local procedure SetupGeneralPostingSetup(GenBus: Code[20]; GenProd: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if not GeneralPostingSetup.Get(GenBus, GenProd) then
            LibraryERM.CreateGeneralPostingSetup(GeneralPostingSetup, GenBus, GenProd);
        GeneralPostingSetup.Validate("Purch. Account", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Validate("Purch. Credit Memo Account", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Validate("Direct Cost Applied Account", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Validate("Overhead Applied Account", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Validate("Purchase Variance Account", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Validate("Inventory Adjmt. Account", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Validate("COGS Account", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Validate("COGS Account (Interim)", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Validate("Sales Account", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Validate("Sales Credit Memo Account", LibraryERM.CreateGLAccountNo());
        // Discount accounts: a POS/sales line discount posts here whenever the company's Sales & Receivables Setup
        // has Discount Posting enabled (varies by demo data), so provide them to keep the tests setup-independent.
        GeneralPostingSetup.Validate("Sales Line Disc. Account", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Validate("Sales Inv. Disc. Account", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Validate("Purch. Line Disc. Account", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", LibraryERM.CreateGLAccountNo());
        GeneralPostingSetup.Modify(true);
    end;
    #endregion

    #region Locations
    internal procedure CreateRetailLocation(var Location: Record Location)
    begin
        LibraryWarehouse.CreateLocation(Location);
        Location."NPR Retail Location" := true;
        Location.Modify();
        CreateInvtPostingSetup(Location.Code, LibraryERM.CreateGLAccountNo(), '', '');
    end;

    internal procedure CreateRetailLocationWithCalcAccounts(var Location: Record Location; var CalcVATAcc: Code[20]; var CalcMarginAcc: Code[20])
    begin
        LibraryWarehouse.CreateLocation(Location);
        Location."NPR Retail Location" := true;
        Location.Modify();
        CalcVATAcc := LibraryERM.CreateGLAccountNo();
        CalcMarginAcc := LibraryERM.CreateGLAccountNo();
        CreateInvtPostingSetup(Location.Code, LibraryERM.CreateGLAccountNo(), CalcVATAcc, CalcMarginAcc);
    end;

    internal procedure CreateWholesaleLocation(var Location: Record Location)
    begin
        LibraryWarehouse.CreateLocation(Location);
        CreateInvtPostingSetup(Location.Code, LibraryERM.CreateGLAccountNo(), '', '');
    end;

    internal procedure CreateInTransitLocation(var Location: Record Location)
    begin
        LibraryWarehouse.CreateInTransitLocation(Location);
        CreateInvtPostingSetup(Location.Code, LibraryERM.CreateGLAccountNo(), '', '');
    end;

    local procedure CreateInvtPostingSetup(LocationCode: Code[10]; InvAccount: Code[20]; CalcVATAcc: Code[20]; CalcMarginAcc: Code[20])
    var
        InvtPostingSetup: Record "Inventory Posting Setup";
    begin
        if not InvtPostingSetup.Get(LocationCode, _InvtPostGrp) then
            LibraryInventory.CreateInventoryPostingSetup(InvtPostingSetup, LocationCode, _InvtPostGrp);
        InvtPostingSetup.Validate("Inventory Account", InvAccount);
        InvtPostingSetup.Validate("Inventory Account (Interim)", LibraryERM.CreateGLAccountNo());
        InvtPostingSetup."NPR RS Calc. VAT Account" := CalcVATAcc;
        InvtPostingSetup."NPR RS Calc. Margin Account" := CalcMarginAcc;
        InvtPostingSetup.Modify(true);
    end;

    // Stamps fresh per-location Calc VAT/Margin accounts onto an existing location's Inventory Posting Setup
    internal procedure SetLocationCalcAccounts(LocationCode: Code[10]; var CalcVATAcc: Code[20]; var CalcMarginAcc: Code[20])
    var
        InvtPostingSetup: Record "Inventory Posting Setup";
    begin
        CalcVATAcc := LibraryERM.CreateGLAccountNo();
        CalcMarginAcc := LibraryERM.CreateGLAccountNo();
        InvtPostingSetup.Get(LocationCode, _InvtPostGrp);
        InvtPostingSetup."NPR RS Calc. VAT Account" := CalcVATAcc;
        InvtPostingSetup."NPR RS Calc. Margin Account" := CalcMarginAcc;
        InvtPostingSetup.Modify();
    end;
    #endregion

    #region Items and price lists
    internal procedure CreateRetailItem(var Item: Record Item; Cost: Decimal; RetailInclVAT: Decimal; Reduced: Boolean; LocationCode: Code[10])
    var
        VATProd: Code[20];
    begin
        if Reduced then
            VATProd := _REDVATProdGrp
        else
            VATProd := _STDVATProdGrp;

        LibraryInventory.CreateItem(Item);
        Item.Validate("Gen. Prod. Posting Group", _GenProdPostGrp);
        Item.Validate("VAT Prod. Posting Group", VATProd);
        Item.Validate("Inventory Posting Group", _InvtPostGrp);
        Item.Validate("Costing Method", Item."Costing Method"::FIFO);
        Item.Validate("Unit Cost", Cost);
        Item.Modify(true);

        EnsureRetailPrice(Item."No.", LocationCode, RetailInclVAT);
    end;

    internal procedure EnsureRetailPrice(ItemNo: Code[20]; LocationCode: Code[10]; RetailInclVAT: Decimal)
    var
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
    begin
        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, Enum::"Price Type"::Sale, Enum::"Price Source Type"::"All Customers", '');
        PriceListHeader.Validate("Price Includes VAT", true);
        PriceListHeader.Validate("VAT Bus. Posting Gr. (Price)", _VATBusPostGrp);
        PriceListHeader."NPR Location Code" := LocationCode;
        PriceListHeader.Modify();

        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader, Enum::"Price Amount Type"::Price, Enum::"Price Asset Type"::Item, ItemNo);
        PriceListLine.Validate("Unit Price", RetailInclVAT);
        // Blank the line's VAT Prod. Posting Group (the realistic case - price lines carry only the
        // reads this blank group and gets 0% VAT instead of the item's group.
        PriceListLine."VAT Prod. Posting Group" := '';
        // Activate header + line directly to avoid the "update status to Active?" confirm (unhandled UI in tests).
        PriceListLine.Status := PriceListLine.Status::Active;
        PriceListLine.Modify();
        PriceListHeader.Status := PriceListHeader.Status::Active;
        PriceListHeader.Modify();
    end;
    #endregion

    #region Purchase posting
    internal procedure PostRetailPurchaseInvoice(ItemNo: Code[20]; LocationCode: Code[10]; Qty: Decimal; DirectUnitCost: Decimal) PostedNo: Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Gen. Bus. Posting Group", _GenBusPostGrp);
        Vendor.Validate("VAT Bus. Posting Group", _VATBusPostGrp);
        Vendor.Modify(true);

        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, ItemNo, Qty);
        PurchaseLine.Validate("Location Code", LocationCode);
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine.Modify(true);

        PostedNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    internal procedure PostRetailPurchase2Lines(Item1: Code[20]; Item2: Code[20]; LocationCode: Code[10]; Qty: Decimal; Cost1: Decimal; Cost2: Decimal) PostedNo: Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Gen. Bus. Posting Group", _GenBusPostGrp);
        Vendor.Validate("VAT Bus. Posting Group", _VATBusPostGrp);
        Vendor.Modify(true);

        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item1, Qty);
        PurchaseLine.Validate("Location Code", LocationCode);
        PurchaseLine.Validate("Direct Unit Cost", Cost1);
        PurchaseLine.Modify(true);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item2, Qty);
        PurchaseLine.Validate("Location Code", LocationCode);
        PurchaseLine.Validate("Direct Unit Cost", Cost2);
        PurchaseLine.Modify(true);

        PostedNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;

    internal procedure PostRetailPurchaseWithItemCharge(ItemNo: Code[20]; LocationCode: Code[10]; Qty: Decimal; DirectUnitCost: Decimal; ChargeAmount: Decimal) PostedNo: Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        ItemLine: Record "Purchase Line";
        ChargeLine: Record "Purchase Line";
        ItemCharge: Record "Item Charge";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Gen. Bus. Posting Group", _GenBusPostGrp);
        Vendor.Validate("VAT Bus. Posting Group", _VATBusPostGrp);
        Vendor.Modify(true);

        // Item charge (zavisni troskovi) must combine with the vendor's posting groups, so give it the same setups as items
        LibraryInventory.CreateItemCharge(ItemCharge);
        ItemCharge.Validate("Gen. Prod. Posting Group", _GenProdPostGrp);
        ItemCharge.Validate("VAT Prod. Posting Group", _STDVATProdGrp);
        ItemCharge.Modify(true);

        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(ItemLine, PurchaseHeader, ItemLine.Type::Item, ItemNo, Qty);
        ItemLine.Validate("Location Code", LocationCode);
        ItemLine.Validate("Direct Unit Cost", DirectUnitCost);
        ItemLine.Modify(true);

        // A single charge line (qty 1) whose full amount is assigned onto the item receipt -> capitalised into item cost
        LibraryPurchase.CreatePurchaseLine(ChargeLine, PurchaseHeader, ChargeLine.Type::"Charge (Item)", ItemCharge."No.", 1);
        ChargeLine.Validate("Location Code", LocationCode);
        ChargeLine.Validate("Direct Unit Cost", ChargeAmount);
        ChargeLine.Modify(true);

        LibraryPurchase.CreateItemChargeAssignment(ItemChargeAssignmentPurch, ChargeLine, ItemCharge,
            "Purchase Applies-to Document Type"::Invoice, PurchaseHeader."No.", ItemLine."Line No.", ItemNo, 1, ChargeAmount);
        ItemChargeAssignmentPurch.Insert(true);

        PostedNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
    end;
    #endregion

    #region Transfer posting
    internal procedure PostRetailTransfer(FromLoc: Code[10]; ToLoc: Code[10]; InTransit: Code[10]; ItemNo: Code[20]; Qty: Decimal; var ShptNo: Code[20]; var RcptNo: Code[20])
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferShptHeader: Record "Transfer Shipment Header";
        TransferRcptHeader: Record "Transfer Receipt Header";
    begin
        LibraryInventory.CreateTransferHeader(TransferHeader, FromLoc, ToLoc, InTransit);
        LibraryInventory.CreateTransferLine(TransferHeader, TransferLine, ItemNo, Qty);
        LibraryInventory.PostTransferHeader(TransferHeader, true, true);

        TransferShptHeader.SetRange("Transfer Order No.", TransferHeader."No.");
        TransferShptHeader.FindLast();
        ShptNo := TransferShptHeader."No.";

        TransferRcptHeader.SetRange("Transfer Order No.", TransferHeader."No.");
        TransferRcptHeader.FindLast();
        RcptNo := TransferRcptHeader."No.";
    end;

    // Ship only (no receipt) so the shipment is still undoable, and return the posted shipment no.
    internal procedure ShipRetailTransferOnly(FromLoc: Code[10]; ToLoc: Code[10]; InTransit: Code[10]; ItemNo: Code[20]; Qty: Decimal) ShptNo: Code[20]
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferShptHeader: Record "Transfer Shipment Header";
    begin
        LibraryInventory.CreateTransferHeader(TransferHeader, FromLoc, ToLoc, InTransit);
        LibraryInventory.CreateTransferLine(TransferHeader, TransferLine, ItemNo, Qty);
        LibraryInventory.PostTransferHeader(TransferHeader, true, false);

        TransferShptHeader.SetRange("Transfer Order No.", TransferHeader."No.");
        TransferShptHeader.FindLast();
        ShptNo := TransferShptHeader."No.";
    end;

    internal procedure UndoRetailTransferShipment(ShptNo: Code[20])
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        UndoTransferShipment: Codeunit "Undo Transfer Shipment";
    begin
        TransferShipmentLine.SetRange("Document No.", ShptNo);
        UndoTransferShipment.SetHideDialog(true);
        UndoTransferShipment.Run(TransferShipmentLine);
    end;
    #endregion

    #region Sales posting
    internal procedure PostRetailSalesInvoice(ItemNo: Code[20]; LocationCode: Code[10]; Qty: Decimal; UnitPriceInclVAT: Decimal) PostedNo: Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Gen. Bus. Posting Group", _GenBusPostGrp);
        Customer.Validate("VAT Bus. Posting Group", _VATBusPostGrp);
        Customer.Modify(true);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, Qty);
        SalesLine.Validate("Location Code", LocationCode);
        SalesLine.Validate("Unit Price", UnitPriceInclVAT);
        SalesLine.Modify(true);

        PostedNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    internal procedure PostRetailSalesCreditMemo(ItemNo: Code[20]; LocationCode: Code[10]; Qty: Decimal; UnitPriceInclVAT: Decimal) PostedNo: Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Gen. Bus. Posting Group", _GenBusPostGrp);
        Customer.Validate("VAT Bus. Posting Group", _VATBusPostGrp);
        Customer.Modify(true);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::"Credit Memo", Customer."No.");
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, Qty);
        SalesLine.Validate("Location Code", LocationCode);
        SalesLine.Validate("Unit Price", UnitPriceInclVAT);
        SalesLine.Modify(true);

        PostedNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;
    #endregion

    #region POS posting
    // Builds a complete POS environment (setup, posting profile, store, unit, cash payment method) whose
    // store location is registered as an RS retail location. The posting profile is aligned to the RS VAT/Gen
    // groups so the standard POS sale posts on the same setups (20%) as the RS razduzenje.
    internal procedure SetupRetailPOS(var POSUnit: Record "NPR POS Unit"; var POSStore: Record "NPR POS Store"; var PaymentMethodCode: Code[10]; var RetailLocationCode: Code[10])
    var
        POSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSetup: Record "NPR POS Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSPaymentMethod: Record "NPR POS Payment Method";
        VATBusPostGrp: Record "VAT Business Posting Group";
        Location: Record Location;
    begin
        POSMasterData.CreatePOSSetup(POSSetup);
        POSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        // Align the profile to the RS VAT/Gen groups so the standard POS sale posts on the same 20% setup as the
        // razduzenje. The profile's "VAT Bus. Posting Group" only accepts groups not restricted on POS, so clear that flag.
        VATBusPostGrp.Get(_VATBusPostGrp);
        VATBusPostGrp."NPR Restricted on POS" := false;
        VATBusPostGrp.Modify();
        // Assign directly (not Validate): the field's POS-restriction TableRelation otherwise silently drops the value.
        POSPostingProfile."VAT Bus. Posting Group" := _VATBusPostGrp;
        POSPostingProfile."Gen. Bus. Posting Group" := _GenBusPostGrp;
        // The RS POS addition matches value entries by POSEntry."Document No.". Clearing the period-register no. series
        // (and not using Per-POS-Period) makes posting stamp the POS entry's own Document No. onto the value entries,
        // so the razduzenje lookup finds the sale's cost. (Same mechanism the standard POS posting tests rely on.)
        POSPostingProfile."Posting Compression" := POSPostingProfile."Posting Compression"::"Per POS Entry";
        Clear(POSPostingProfile."POS Period Register No. Series");
        POSPostingProfile.Modify();

        POSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
        Location.Get(POSStore."Location Code");
        Location."NPR Retail Location" := true;
        Location.Modify();
        CreateInvtPostingSetup(Location.Code, LibraryERM.CreateGLAccountNo(), '', '');
        RetailLocationCode := Location.Code;

        POSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
        POSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
        PaymentMethodCode := POSPaymentMethod.Code;

        // Wipe ALL prior POS entries (posted + unposted): the JQ posting posts every unposted entry (so leftovers
        // with inconsistent setups would break our run), and the receipt no. series does not advance between test
        // methods, so a lingering posted entry would clash as a "Duplicate Receipt Number".
        CleanPOSEntries();
    end;

    local procedure CleanPOSEntries()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
        POSEntryTaxLine.DeleteAll();
        POSEntry.DeleteAll();
    end;

    internal procedure CreateRetailItemForPOS(var Item: Record Item; Cost: Decimal; RetailInclVAT: Decimal; POSUnit: Record "NPR POS Unit"; POSStore: Record "NPR POS Store"; LocationCode: Code[10])
    var
        POSMasterData: Codeunit "NPR Library - POS Master Data";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        CreateRetailItem(Item, Cost, RetailInclVAT, false, LocationCode);
        // Point the price VAT bus group at the POS profile's own group so the sale posts on a resolvable VAT setup,
        // and stamp the card price so the POS charges exactly the retail price (no unintended discount -> no nivelation).
        // Price Includes VAT / Unit Price are assigned directly (not Validated) - Validate would trigger a VAT recalc
        // that resolves through a company-default VAT bus group with no setup, exactly as the standard POS item helper does.
        POSStore.GetProfile(POSPostingProfile);
        Item.Validate("VAT Bus. Posting Gr. (Price)", POSPostingProfile."VAT Bus. Posting Group");
        Item."Price Includes VAT" := true;
        Item."Unit Price" := RetailInclVAT;
        Item.Modify(true);
        POSMasterData.CreatePostingSetupForSaleItem(Item, POSUnit, POSStore);
    end;

    // Runs a full POS sale (start -> item line [optionally discounted] -> cash payment -> end) then posts inventory and G/L
    // through the POS posting job queues, which is when the RS POS addition fires and posts the razduzenje.
    internal procedure SellRetailPOSItemAndPost(POSUnit: Record "NPR POS Unit"; PaymentMethodCode: Code[10]; ItemNo: Code[20]; Qty: Decimal; TotalToPay: Decimal; DiscountPct: Decimal)
    var
        POSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        PostItemEntriesJQ: Codeunit "NPR POS Post Item Entries JQ";
        PostGLEntriesJQ: Codeunit "NPR POS Post GL Entries JQ";
        PostingLogEntryNoBefore: Integer;
    begin
        POSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        if DiscountPct = 0 then
            POSMock.CreateItemLine(POSSession, ItemNo, Qty)
        else
            POSMock.CreateItemLineWithDiscount(POSSession, ItemNo, Qty, DiscountPct);
        POSMock.PayAndTryEndSaleAndStartNew(POSSession, PaymentMethodCode, TotalToPay, '', false);

        Commit();
        ClearPendingBillingQueue();
        PostingLogEntryNoBefore := LastPOSPostingLogEntryNo();
        PostItemEntriesJQ.Run();
        Commit();
        PostGLEntriesJQ.Run();
        // The job queues swallow posting errors (they only count them and raise a Message), so read them back from
        // the posting log - otherwise a failed POS posting surfaces as an unrelated "Unhandled UI: Message" failure.
        CheckPOSPostingLogForErrors(PostingLogEntryNoBefore);
    end;

    local procedure LastPOSPostingLogEntryNo(): Integer
    var
        POSPostingLog: Record "NPR POS Posting Log";
    begin
        if POSPostingLog.FindLast() then
            exit(POSPostingLog."Entry No.");
    end;

    local procedure CheckPOSPostingLogForErrors(AfterEntryNo: Integer)
    var
        POSPostingLog: Record "NPR POS Posting Log";
        POSPostingFailedErr: Label 'POS posting failed: %1', Comment = '%1 = error description from the POS posting log';
    begin
        POSPostingLog.SetFilter("Entry No.", '>%1', AfterEntryNo);
        POSPostingLog.SetRange("With Error", true);
        if POSPostingLog.FindFirst() then
            Error(POSPostingFailedErr, POSPostingLog."Error Description");
    end;

    // The POS item-entry job queue first checks the billing queue and, if it holds entries older than an hour,
    // spins off a background session - which the test runner blocks unless test isolation is disabled. A company
    // that has been used for a while accumulates those entries, so clear them to keep POS posting deterministic.
    local procedure ClearPendingBillingQueue()
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
    begin
        BillingQueueEntry.SetRange(Status, BillingQueueEntry.Status::Pending);
        BillingQueueEntry.DeleteAll();
    end;

    #endregion

    #region Nivelation
    internal procedure PostNivelationPriceChange(ItemNo: Code[20]; LocationCode: Code[10]; NewPriceInclVAT: Decimal) PostedNivNo: Code[20]
    var
        OldPriceListHeader: Record "Price List Header";
        NewPriceListHeader: Record "Price List Header";
        NewPriceListLine: Record "Price List Line";
        PostedNivHdr: Record "NPR RS Posted Nivelation Hdr";
        PostedNivLines: Record "NPR RS Posted Nivelation Lines";
        NivHdr: Record "NPR RS Nivelation Header";
        NivLines: Record "NPR RS Nivelation Lines";
        ChangePriceNiv: Codeunit "NPR RS Change Price Nivelation";
    begin
        // Nivelation posting commits, so prior committing tests can leave data behind that collides on the
        // (rolled-back) no. series. Clear any leftover nivelation documents first.
        NivHdr.DeleteAll();
        NivLines.DeleteAll();
        PostedNivHdr.DeleteAll();
        PostedNivLines.DeleteAll();

        // Close the existing (old) active price list at WorkDate so it becomes the "previous" list for the nivelation.
        OldPriceListHeader.SetRange(Status, OldPriceListHeader.Status::Active);
        OldPriceListHeader.SetRange("NPR Location Code", LocationCode);
        OldPriceListHeader.FindFirst();
        OldPriceListHeader.Validate("Ending Date", WorkDate());
        OldPriceListHeader.Modify();

        // New price list effective the next day, carrying the new price.
        LibraryPriceCalculation.CreatePriceHeader(NewPriceListHeader, Enum::"Price Type"::Sale, Enum::"Price Source Type"::"All Customers", '');
        NewPriceListHeader.Validate("Price Includes VAT", true);
        NewPriceListHeader.Validate("VAT Bus. Posting Gr. (Price)", _VATBusPostGrp);
        NewPriceListHeader."NPR Location Code" := LocationCode;
        NewPriceListHeader.Validate("Starting Date", WorkDate() + 1);
        NewPriceListHeader.Modify();
        LibraryPriceCalculation.CreatePriceListLine(NewPriceListLine, NewPriceListHeader, Enum::"Price Amount Type"::Price, Enum::"Price Asset Type"::Item, ItemNo);
        NewPriceListLine.Validate("Unit Price", NewPriceInclVAT);
        NewPriceListLine."VAT Prod. Posting Group" := '';
        NewPriceListLine.Status := NewPriceListLine.Status::Active;
        NewPriceListLine.Modify();
        NewPriceListHeader.Status := NewPriceListHeader.Status::Active;
        NewPriceListHeader.Modify();

        ChangePriceNiv.CreateAndPostPriceChangeNivelationDocument(NewPriceListHeader);

        PostedNivHdr.SetRange("Referring Document Code", NewPriceListHeader.Code);
        PostedNivHdr.FindFirst();
        exit(PostedNivHdr."No.");
    end;
    #endregion

    #region Costing
    internal procedure RunAdjustCostItemEntries(ItemNo: Code[20])
    var
        LibraryCosting: Codeunit "Library - Costing";
    begin
        LibraryCosting.AdjustCostItemEntries(ItemNo, '');
    end;
    #endregion

    #region Accessors
    internal procedure RetailInvAcc(LocationCode: Code[10]): Code[20]
    var
        InvtPostingSetup: Record "Inventory Posting Setup";
    begin
        InvtPostingSetup.Get(LocationCode, _InvtPostGrp);
        exit(InvtPostingSetup."Inventory Account");
    end;

    internal procedure GlobalVATAcc(): Code[20]
    begin
        exit(_GlobalVATAcc);
    end;

    internal procedure GlobalMarginAcc(): Code[20]
    begin
        exit(_GlobalMarginAcc);
    end;

    #endregion

    #region Verification
    internal procedure GetGLNetChange(GLAccNo: Code[20]; DocumentNo: Code[20]): Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", GLAccNo);
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.CalcSums(Amount);
        exit(GLEntry.Amount);
    end;

    // Full balance of an account across ALL documents. The RS calc accounts are created fresh per test run,
    // so measuring the balance before and after an operation isolates exactly that operation's contribution.
    internal procedure GetGLAccountBalance(GLAccNo: Code[20]): Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", GLAccNo);
        GLEntry.CalcSums(Amount);
        exit(GLEntry.Amount);
    end;

    internal procedure PostedNivelationCount(): Integer
    var
        PostedNivHdr: Record "NPR RS Posted Nivelation Hdr";
    begin
        exit(PostedNivHdr.Count());
    end;

    internal procedure AssertGLAccountBalance(GLAccNo: Code[20]; Expected: Decimal; Msg: Text)
    begin
        Assert.AreNearlyEqual(Expected, GetGLAccountBalance(GLAccNo), 0.01, Msg);
    end;

    // Asserts the document produced NO RS retail calculation ("G/L Calculation ...") entries at all.
    internal procedure AssertNoRSCalcEntries(DocumentNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetFilter(Description, 'G/L Calculation*');
        Assert.IsTrue(GLEntry.IsEmpty(), 'No RS calc (G/L Calculation) entries expected for document ' + DocumentNo);
    end;

    // Net change of ONLY the RS calculation entries ("G/L Calculation ...") on an account for a document.
    // Isolates the RS additions from standard cost posting so assertions are independent of Automatic Cost Posting.
    internal procedure GetRSCalcNetChange(GLAccNo: Code[20]; DocumentNo: Code[20]): Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", GLAccNo);
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetFilter(Description, 'G/L Calculation*');
        GLEntry.CalcSums(Amount);
        exit(GLEntry.Amount);
    end;

    // Net change (all entries) for an account across the two documents of a transfer (shipment + receipt),
    // deduped via a filter so an identical shipment/receipt number is not counted twice.
    internal procedure GetGLNetForTransfer(GLAccNo: Code[20]; ShptNo: Code[20]; RcptNo: Code[20]): Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", GLAccNo);
        GLEntry.SetFilter("Document No.", '%1|%2', ShptNo, RcptNo);
        GLEntry.CalcSums(Amount);
        exit(GLEntry.Amount);
    end;

    internal procedure AssertGLNetForTransfer(ShptNo: Code[20]; RcptNo: Code[20]; GLAccNo: Code[20]; Expected: Decimal; Msg: Text)
    begin
        Assert.AreNearlyEqual(Expected, GetGLNetForTransfer(GLAccNo, ShptNo, RcptNo), 0.01, Msg);
    end;

    internal procedure AssertCalcGL(DocumentNo: Code[20]; InventoryAcc: Code[20]; VATAcc: Code[20]; MarginAcc: Code[20]; ExpInventory: Decimal; ExpVAT: Decimal; ExpMargin: Decimal)
    begin
        // Amount = Debit - Credit. Inbound: inventory debited (+markup), VAT & RUC credited (-).
        Assert.AreNearlyEqual(ExpInventory, GetRSCalcNetChange(InventoryAcc, DocumentNo), 0.01, 'Inventory markup leg (Margin with VAT)');
        Assert.AreNearlyEqual(-ExpVAT, GetRSCalcNetChange(VATAcc, DocumentNo), 0.01, 'ukalkulisani PDV leg');
        Assert.AreNearlyEqual(-ExpMargin, GetRSCalcNetChange(MarginAcc, DocumentNo), 0.01, 'RUC leg');
    end;

    // Para-exact variant of AssertCalcGL. Rounding regressions are 0.01 defects, so they must not be asserted
    // with a 0.01 tolerance - AreNearlyEqual would accept the very drift the test exists to catch.
    internal procedure AssertCalcGLExact(DocumentNo: Code[20]; InventoryAcc: Code[20]; VATAcc: Code[20]; MarginAcc: Code[20]; ExpInventory: Decimal; ExpVAT: Decimal; ExpMargin: Decimal)
    begin
        Assert.AreEqual(ExpInventory, GetRSCalcNetChange(InventoryAcc, DocumentNo), 'Inventory markup leg (Margin with VAT)');
        Assert.AreEqual(-ExpVAT, GetRSCalcNetChange(VATAcc, DocumentNo), 'ukalkulisani PDV leg');
        Assert.AreEqual(-ExpMargin, GetRSCalcNetChange(MarginAcc, DocumentNo), 'RUC leg');
    end;

    internal procedure AssertGLNetChange(DocumentNo: Code[20]; GLAccNo: Code[20]; Expected: Decimal; Msg: Text)
    begin
        Assert.AreNearlyEqual(Expected, GetGLNetChange(GLAccNo, DocumentNo), 0.01, Msg);
    end;

    internal procedure AssertDocGLBalanced(DocumentNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.CalcSums(Amount);
        Assert.AreEqual(0, GLEntry.Amount, 'G/L must be balanced for document ' + DocumentNo);
    end;
    #endregion
}
