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
        _GlobalSurplusAcc: Code[20];
        _GlobalShortageAcc: Code[20];
        _InvtAdjmtAcc: Code[20];
        _STDVATRate: Decimal;
        _REDVATRate: Decimal;
        _CountDocumentNoCounter: Integer;
        _CountDocumentNoPrefix: Code[12];

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
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
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
        _GlobalSurplusAcc := LibraryERM.CreateGLAccountNo();
        _GlobalShortageAcc := LibraryERM.CreateGLAccountNo();

        if not RSSetup.Get() then begin
            RSSetup.Init();
            RSSetup.Insert();
        end;
        RSSetup."Enable RS Retail Localization" := true;
        RSSetup."RS Calc. VAT GL Account" := _GlobalVATAcc;
        RSSetup."RS Calc. Margin GL Account" := _GlobalMarginAcc;
        RSSetup."RS Surplus GL Account" := _GlobalSurplusAcc;
        RSSetup."RS Shortage GL Account" := _GlobalShortageAcc;
        RSSetup."RS Ret. Localization Country" := RSSetup."RS Ret. Localization Country"::Serbia;
        RSSetup."RS Nivelation Hdr No. Series" := LibraryERM.CreateNoSeriesCode();
        RSSetup."RS Posted Niv. No. Series" := LibraryERM.CreateNoSeriesCode();
        RSSetup.Modify();

        // Match production: inventory cost posts to G/L automatically so retail accounts reflect the full retail value.
        InventorySetup.Get();
        InventorySetup.Validate("Automatic Cost Posting", true);
        InventorySetup.Validate("Automatic Cost Adjustment", InventorySetup."Automatic Cost Adjustment"::Always);
        InventorySetup.Modify();

        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Allow Editing Active Price", true);
        SalesReceivablesSetup.Modify();

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
        if _InvtAdjmtAcc = '' then
            _InvtAdjmtAcc := LibraryERM.CreateGLAccountNo();
        GeneralPostingSetup.Validate("Inventory Adjmt. Account", _InvtAdjmtAcc);
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

    #region Item counting (physical inventory) posting
    /// <summary>
    /// Posts a counted quantity difference at a location the way item counting does: an item journal
    /// Positive/Negative Adjmt. line carrying the phys. inventory flag and source code, pushed through
    /// Item Jnl.-Post Batch. This is the path taken by the NPR Retail Calc. Inv. report feeding the
    /// NPR Retail Item Journal, and by the BC standard Phys. Inventory Journal.
    /// CountedQty is the counted on-hand; CalculatedQty is what the system believed was on hand.
    /// </summary>
    internal procedure PostRetailCountAdjustment(ItemNo: Code[20]; LocationCode: Code[10]; CalculatedQty: Decimal; CountedQty: Decimal) DocumentNo: Code[20]
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        LibraryInventory.CreateItemJournalTemplateByType(ItemJournalTemplate, ItemJournalTemplate.Type::"Phys. Inventory");
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        DocumentNo := NextCountDocumentNo();
        CreateCountBatchLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name, DocumentNo, ItemNo, LocationCode, CalculatedQty, CountedQty);

        ItemJnlPostBatch.Run(ItemJournalLine);
    end;

    /// <summary>
    /// Posts a count batch holding a line per item under ONE document no., the way a real count of a
    /// store does. Multi-line batches are their own case: every line shares the document no., so any
    /// posting logic that locates its work by document no. alone can pick up the wrong line's entries.
    /// </summary>
    internal procedure PostRetailCountAdjustmentTwoItems(Item1: Code[20]; Item2: Code[20]; LocationCode: Code[10]; CalculatedQty: Decimal; CountedQty1: Decimal; CountedQty2: Decimal) DocumentNo: Code[20]
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        LibraryInventory.CreateItemJournalTemplateByType(ItemJournalTemplate, ItemJournalTemplate.Type::"Phys. Inventory");
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        DocumentNo := NextCountDocumentNo();
        CreateCountBatchLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name, DocumentNo, Item1, LocationCode, CalculatedQty, CountedQty1);
        CreateCountBatchLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name, DocumentNo, Item2, LocationCode, CalculatedQty, CountedQty2);

        ItemJournalLine.SetRange("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine.FindFirst();
        ItemJnlPostBatch.Run(ItemJournalLine);
    end;

    /// <summary>
    /// Creates one line of a count batch through LibraryInventory, so line numbering and any field a
    /// future BC version makes mandatory on Item Journal Line stay owned by the maintained library rather
    /// than by this fixture. Only the count-specific fields are layered on top afterwards.
    /// Every line of one count carries the same document no. - that is the point of this fixture.
    /// </summary>
    local procedure CreateCountBatchLine(var ItemJournalLine: Record "Item Journal Line"; TemplateName: Code[10]; BatchName: Code[10]; DocumentNo: Code[20]; ItemNo: Code[20]; LocationCode: Code[10]; CalculatedQty: Decimal; CountedQty: Decimal)
    var
        SourceCodeSetup: Record "Source Code Setup";
        Difference: Decimal;
    begin
        Difference := CountedDifference(CalculatedQty, CountedQty);

        LibraryInventory.CreateItemJournalLine(ItemJournalLine, TemplateName, BatchName, CountEntryType(Difference), ItemNo, Abs(Difference));

        ItemJournalLine.Validate("Posting Date", WorkDate());
        ItemJournalLine.Validate("Document No.", DocumentNo);
        ItemJournalLine.Validate("Location Code", LocationCode);

        // Mirror NPR Retail Calc. Inv.: the phys. inventory flag and source code are what make this a
        // count rather than an ad-hoc adjustment, and the localization must react to it either way.
        SourceCodeSetup.Get();
        ItemJournalLine.Validate("Source Code", SourceCodeSetup."Phys. Inventory Journal");
        ItemJournalLine."Phys. Inventory" := true;
        ItemJournalLine."Qty. (Calculated)" := CalculatedQty;
        ItemJournalLine."Qty. (Phys. Inventory)" := CountedQty;
        ItemJournalLine.Modify(true);
    end;

    /// <summary>
    /// As PostRetailCountAdjustment, but posted straight through Item Jnl.-Post Line without a journal
    /// batch - the path the POS "Adjust Inventory" action takes. Kept separate because a subscriber on
    /// Item Jnl.-Post Batch never fires here, so the two paths need independent coverage.
    /// </summary>
    internal procedure PostRetailCountAdjustmentDirect(ItemNo: Code[20]; LocationCode: Code[10]; CalculatedQty: Decimal; CountedQty: Decimal) DocumentNo: Code[20]
    var
        TempItemJournalLine: Record "Item Journal Line" temporary;
        POSActionAdjustInvB: Codeunit "NPR POS Action: Adjust Inv. B";
    begin
        InitCountAdjustmentLine(TempItemJournalLine, ItemNo, LocationCode, CalculatedQty, CountedQty);
        TempItemJournalLine.Insert();

        DocumentNo := TempItemJournalLine."Document No.";
        // Posts through the POS action's own procedure rather than Item Jnl.-Post Line, so the test
        // covers the production path including whatever that action does after posting. Driving the
        // full action would need a live POS sale context, which this assertion does not need.
        POSActionAdjustInvB.PostItemJnlLine(TempItemJournalLine);
    end;

    /// <summary>
    /// As PostRetailCountAdjustmentDirect, but carrying the reason the way the POS action carries it:
    /// POSActionAdjustInvB.CreateItemJnlLine validates "Return Reason Code" and never touches
    /// "Reason Code", so a POS write-off reaches the value entry with the Reason Code field blank. That
    /// asymmetry is the whole point of the fixture - a helper that set "Reason Code" here would be
    /// testing the journal path a second time under a POS-sounding name.
    /// </summary>
    internal procedure PostRetailCountAdjustmentDirectWithReturnReason(ItemNo: Code[20]; LocationCode: Code[10]; CalculatedQty: Decimal; CountedQty: Decimal; ReturnReasonCode: Code[10]) DocumentNo: Code[20]
    var
        TempItemJournalLine: Record "Item Journal Line" temporary;
        POSActionAdjustInvB: Codeunit "NPR POS Action: Adjust Inv. B";
    begin
        InitCountAdjustmentLine(TempItemJournalLine, ItemNo, LocationCode, CalculatedQty, CountedQty);
        TempItemJournalLine.Validate("Return Reason Code", ReturnReasonCode);
        TempItemJournalLine.Insert();

        Assert.AreEqual('', TempItemJournalLine."Reason Code", 'The POS fixture must leave Reason Code blank, as the POS action does - otherwise it is not exercising the Return Reason path.');

        DocumentNo := TempItemJournalLine."Document No.";
        POSActionAdjustInvB.PostItemJnlLine(TempItemJournalLine);
    end;

    /// <summary>
    /// The counted difference, asserted non-zero - a count adjustment test with no difference would post
    /// nothing and assert nothing.
    /// </summary>
    local procedure CountedDifference(CalculatedQty: Decimal; CountedQty: Decimal) Difference: Decimal
    begin
        Difference := CountedQty - CalculatedQty;
        Assert.AreNotEqual(0, Difference, 'A count adjustment test needs a non-zero counted difference');
    end;

    /// <summary>
    /// Business Central carries the sign of a count adjustment in the entry type, not in Quantity, so the
    /// quantity posted is always the absolute difference.
    /// </summary>
    local procedure CountEntryType(Difference: Decimal): Enum "Item Ledger Entry Type"
    begin
        if Difference > 0 then
            exit("Item Ledger Entry Type"::"Positive Adjmt.");
        exit("Item Ledger Entry Type"::"Negative Adjmt.");
    end;

    /// <summary>
    /// Fills a TEMPORARY count-adjustment line for the POS path, which posts through Item Jnl.-Post Line
    /// with no journal template or batch. LibraryInventory.CreateItemJournalLine cannot serve this case -
    /// it writes a real line into a real batch - so this one line is built by hand on purpose.
    /// </summary>
    local procedure InitCountAdjustmentLine(var ItemJournalLine: Record "Item Journal Line"; ItemNo: Code[20]; LocationCode: Code[10]; CalculatedQty: Decimal; CountedQty: Decimal)
    var
        Difference: Decimal;
    begin
        Difference := CountedDifference(CalculatedQty, CountedQty);

        ItemJournalLine.Init();
        ItemJournalLine.Validate("Posting Date", WorkDate());
        ItemJournalLine.Validate("Entry Type", CountEntryType(Difference));
        ItemJournalLine.Validate("Document No.", NextCountDocumentNo());
        ItemJournalLine.Validate("Item No.", ItemNo);
        ItemJournalLine.Validate("Location Code", LocationCode);
        ItemJournalLine.Validate(Quantity, Abs(Difference));
    end;

    /// <summary>
    /// A document no. unique per call, so each count in a test is independently assertable by document.
    /// </summary>
    local procedure NextCountDocumentNo(): Code[20]
    begin
        // Seeded from a GUID, not just a counter. The counter is plain codeunit state and each test
        // declares its own library instance, so a counter alone restarts at 0 every test - and the
        // runners use TestIsolation = Codeunit, so nothing is rolled back between tests in a codeunit.
        // Every test would then post under the same document no., and any assertion filtering on
        // document alone would silently span the whole codeunit's postings.
        if _CountDocumentNoPrefix = '' then
            _CountDocumentNoPrefix := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 12);
        _CountDocumentNoCounter += 1;
        exit(CopyStr(_CountDocumentNoPrefix + Format(_CountDocumentNoCounter), 1, 20));
    end;
    #endregion

    #region Costing
    internal procedure RunAdjustCostItemEntries(ItemNo: Code[20])
    var
        LibraryCosting: Codeunit "Library - Costing";
    begin
        LibraryCosting.AdjustCostItemEntries(ItemNo, '');
    end;

    /// <summary>
    /// Posts a purchase order as receipt only, so the item ledger entry carries an expected cost that
    /// a later invoice at a different cost will have to adjust. Returns the order no. so the caller
    /// can invoice it with InvoiceReceivedPurchaseAtCost.
    /// </summary>
    internal procedure ReceivePurchaseOrderOnly(ItemNo: Code[20]; LocationCode: Code[10]; Qty: Decimal; DirectUnitCost: Decimal) OrderNo: Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Gen. Bus. Posting Group", _GenBusPostGrp);
        Vendor.Validate("VAT Bus. Posting Group", _VATBusPostGrp);
        Vendor.Modify(true);

        // Library - Purchase.CreatePurchHeader already assigns a Vendor Invoice No. for every document
        // type except Credit Memo / Return Order, so the Order created here arrives with one and the
        // invoice step in InvoiceReceivedPurchaseAtCost has what it needs.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, ItemNo, Qty);
        PurchaseLine.Validate("Location Code", LocationCode);
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine.Modify(true);

        OrderNo := PurchaseHeader."No.";
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
    end;

    /// <summary>
    /// Invoices a previously received purchase order at a different unit cost, which is what forces
    /// standard cost adjustment to have real work to propagate onwards to any transfer of the goods.
    /// </summary>
    internal procedure InvoiceReceivedPurchaseAtCost(OrderNo: Code[20]; NewDirectUnitCost: Decimal)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, OrderNo);
        // Posting the receipt leaves the order Released, and Direct Unit Cost cannot be validated on a
        // released document, so reopen before changing the cost.
        LibraryPurchase.ReopenPurchaseDocument(PurchaseHeader);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.FindFirst();
        PurchaseLine.Validate("Direct Unit Cost", NewDirectUnitCost);
        PurchaseLine.Modify(true);

        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
    end;

    /// <summary>
    /// Counts value entries carrying the standard "Adjustment" flag for the item ledger entries of a
    /// posted transfer shipment, across every location the shipment touches. A shipment spans both the
    /// from-location and the in-transit leg, so a non-zero count only tells you that SOME leg was
    /// adjusted - for a transfer touching a retail location the non-retail leg alone can produce it.
    /// Use this only for wholly non-retail transfers; anything per-leg needs
    /// CountAdjustmentValueEntriesAtLocation.
    /// </summary>
    internal procedure CountAdjustmentValueEntriesForTransfer(ShptNo: Code[20]) AdjustmentEntryCount: Integer
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        ItemLedgerEntry.SetLoadFields("Entry No.");
        ItemLedgerEntry.SetRange("Document No.", ShptNo);
        if not ItemLedgerEntry.FindSet() then
            exit(0);
        repeat
            ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
            ValueEntry.SetRange(Adjustment, true);
            AdjustmentEntryCount += ValueEntry.Count();
        until ItemLedgerEntry.Next() = 0;
    end;

    /// <summary>
    /// As CountAdjustmentValueEntriesForTransfer, but restricted to the item ledger entries sitting at
    /// one location. A transfer spans three legs (from, in-transit, to) and only the leg at a retail
    /// location is expected to be suppressed, so assertions have to name the location they mean.
    /// </summary>
    internal procedure CountAdjustmentValueEntriesAtLocation(DocumentNo: Code[20]; LocationCode: Code[10]) AdjustmentEntryCount: Integer
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        ItemLedgerEntry.SetLoadFields("Entry No.");
        ItemLedgerEntry.SetRange("Document No.", DocumentNo);
        ItemLedgerEntry.SetRange("Location Code", LocationCode);
        // A zero from this helper must mean "the leg was not adjusted", never "the filter matched no
        // item ledger entry at all". Callers assert AreEqual(0, ...) to prove suppression, so a
        // mistyped document no. or location code would otherwise turn into a silent pass.
        Assert.IsFalse(ItemLedgerEntry.IsEmpty(), StrSubstNo('No item ledger entries for document %1 at location %2, so a suppression assertion on this helper would be vacuous.', DocumentNo, LocationCode));
        ItemLedgerEntry.FindSet();
        repeat
            ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
            ValueEntry.SetRange(Adjustment, true);
            AdjustmentEntryCount += ValueEntry.Count();
        until ItemLedgerEntry.Next() = 0;
    end;

    /// <summary>
    /// Turns automatic cost adjustment off (or back on). InitializeSetup leaves it on Always, which is
    /// usually what you want: a cost change posted AFTER the entries it affects - a receipt invoiced
    /// later at a different cost, say - still leaves real work for an explicit Adjust Cost run, which
    /// is how most tests here observe adjustment. Turn it off only when the adjustment must not have
    /// happened already at posting time, so the test can take a G/L snapshot before it runs.
    /// </summary>
    internal procedure SetAutomaticCostAdjustment(Enabled: Boolean)
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        if Enabled then
            InventorySetup.Validate("Automatic Cost Adjustment", InventorySetup."Automatic Cost Adjustment"::Always)
        else
            InventorySetup.Validate("Automatic Cost Adjustment", InventorySetup."Automatic Cost Adjustment"::Never);
        InventorySetup.Modify(true);
    end;

    /// <summary>
    /// Counts the COGS-correction mapping rows a document registered for an item. A counted-in quantity
    /// needs one so a later sale of those units can produce its COGS correction; without it the sale
    /// falls through to the unmapped path and posts no COGS legs. Scoped by document on purpose - a
    /// purchase registers one of its own, so an item-wide count would pass without the count's row.
    /// </summary>
    internal procedure CountCOGSCorrectionMappings(ItemNo: Code[20]; DocumentNo: Code[20]): Integer
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        RSRetValueEntryMapp.SetRange("Item No.", ItemNo);
        RSRetValueEntryMapp.SetRange("Document No.", DocumentNo);
        RSRetValueEntryMapp.SetRange("COGS Correction", true);
        exit(RSRetValueEntryMapp.Count());
    end;

    /// <summary>
    /// Counts the G/L entries of a document that fall inside no G/L Register range. Entries outside every
    /// register are invisible in General Ledger Registers, unreachable from register Navigate, and skipped
    /// by Reverse Register - so statutory entries must never be among them.
    /// </summary>
    internal procedure CountGLEntriesOutsideAnyRegister(DocumentNo: Code[20]) OrphanCount: Integer
    var
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        if not GLEntry.FindSet() then
            exit;
        repeat
            GLRegister.Reset();
            GLRegister.SetFilter("From Entry No.", '<=%1', GLEntry."Entry No.");
            GLRegister.SetFilter("To Entry No.", '>=%1', GLEntry."Entry No.");
            if GLRegister.IsEmpty() then
                OrphanCount += 1;
        until GLEntry.Next() = 0;
    end;

    /// <summary>
    /// Creates a reason code. When WithAccounts is set it also gets its own surplus and shortage
    /// accounts, which is how a write-off reason such as breakage is directed away from the default
    /// shortage account. Returns the code plus both accounts so a test can assert on them.
    /// </summary>
    internal procedure CreateCountReasonCode(WithAccounts: Boolean; var SurplusAcc: Code[20]; var ShortageAcc: Code[20]) ReasonCode: Code[10]
    var
        ReasonCodeRec: Record "Reason Code";
        RSReasonCodeAccMapp: Record "NPR RS Reason Code Acc. Mapp.";
    begin
        // The parent is created first, and through the library that owns it, so the mapping's TableRelation
        // holds and the fixture keeps working if "Reason Code" ever gains a mandatory field.
        LibraryERM.CreateReasonCode(ReasonCodeRec);
        ReasonCodeRec.Validate(Description, 'RS count reason');
        ReasonCodeRec.Modify(true);

        Clear(SurplusAcc);
        Clear(ShortageAcc);
        if WithAccounts then begin
            SurplusAcc := LibraryERM.CreateGLAccountNo();
            ShortageAcc := LibraryERM.CreateGLAccountNo();
            RSReasonCodeAccMapp.Init();
            RSReasonCodeAccMapp.Validate("Reason Type", RSReasonCodeAccMapp."Reason Type"::"Reason Code");
            RSReasonCodeAccMapp.Validate("Reason Code", ReasonCodeRec.Code);
            RSReasonCodeAccMapp.Validate("Surplus Account", SurplusAcc);
            RSReasonCodeAccMapp.Validate("Shortage Account", ShortageAcc);
            RSReasonCodeAccMapp.Insert(true);
        end;
        exit(ReasonCodeRec.Code);
    end;

    /// <summary>
    /// The POS counterpart of CreateCountReasonCode. The POS "Adjust Inventory" action asks the cashier
    /// for a Return Reason, not a Reason Code - two different tables - so a POS write-off reason has to be
    /// mapped on its own line, under the Return Reason type.
    /// </summary>
    internal procedure CreateCountReturnReason(WithAccounts: Boolean; var SurplusAcc: Code[20]; var ShortageAcc: Code[20]) ReturnReasonCode: Code[10]
    var
        ReturnReason: Record "Return Reason";
        RSReasonCodeAccMapp: Record "NPR RS Reason Code Acc. Mapp.";
    begin
        // Created through the library that owns the table, for the same reason CreateCountReasonCode does.
        LibraryERM.CreateReturnReasonCode(ReturnReason);
        ReturnReason.Validate(Description, 'RS POS count reason');
        ReturnReason.Modify(true);

        Clear(SurplusAcc);
        Clear(ShortageAcc);
        if WithAccounts then begin
            SurplusAcc := LibraryERM.CreateGLAccountNo();
            ShortageAcc := LibraryERM.CreateGLAccountNo();
            RSReasonCodeAccMapp.Init();
            RSReasonCodeAccMapp.Validate("Reason Type", RSReasonCodeAccMapp."Reason Type"::"Return Reason");
            RSReasonCodeAccMapp.Validate("Reason Code", ReturnReason.Code);
            RSReasonCodeAccMapp.Validate("Surplus Account", SurplusAcc);
            RSReasonCodeAccMapp.Validate("Shortage Account", ShortageAcc);
            RSReasonCodeAccMapp.Insert(true);
        end;
        exit(ReturnReason.Code);
    end;

    /// <summary>
    /// Creates a Reason Code and a Return Reason that share one code value, each mapped to its own
    /// shortage account. Nothing stops the two tables from holding the same code - they are independent -
    /// so this is the fixture that proves a lookup reaches the right list rather than merely finding
    /// something. The shared code is forced by hand because the ERM library assigns its own.
    /// </summary>
    internal procedure CreateCollidingCountReasons(var SharedCode: Code[10]; var JournalShortageAcc: Code[20]; var POSShortageAcc: Code[20])
    var
        ReasonCodeRec: Record "Reason Code";
        ReturnReason: Record "Return Reason";
        RSReasonCodeAccMapp: Record "NPR RS Reason Code Acc. Mapp.";
    begin
        LibraryERM.CreateReasonCode(ReasonCodeRec);
        SharedCode := ReasonCodeRec.Code;

        ReturnReason.Init();
        ReturnReason.Validate(Code, SharedCode);
        ReturnReason.Validate(Description, 'RS colliding POS reason');
        ReturnReason.Insert(true);

        JournalShortageAcc := LibraryERM.CreateGLAccountNo();
        POSShortageAcc := LibraryERM.CreateGLAccountNo();

        RSReasonCodeAccMapp.Init();
        RSReasonCodeAccMapp.Validate("Reason Type", RSReasonCodeAccMapp."Reason Type"::"Reason Code");
        RSReasonCodeAccMapp.Validate("Reason Code", SharedCode);
        RSReasonCodeAccMapp.Validate("Shortage Account", JournalShortageAcc);
        RSReasonCodeAccMapp.Insert(true);

        RSReasonCodeAccMapp.Init();
        RSReasonCodeAccMapp.Validate("Reason Type", RSReasonCodeAccMapp."Reason Type"::"Return Reason");
        RSReasonCodeAccMapp.Validate("Reason Code", SharedCode);
        RSReasonCodeAccMapp.Validate("Shortage Account", POSShortageAcc);
        RSReasonCodeAccMapp.Insert(true);
    end;

    /// <summary>
    /// Renames a Reason Code, which is what an accountant tidying up a code list does. Business Central
    /// is documented to carry a rename into every table that relates to the renamed one, so this is here
    /// to prove the account mapping actually follows rather than being left behind under the old code.
    /// </summary>
    internal procedure RenameReasonCode(OldCode: Code[10]; NewCode: Code[10])
    var
        ReasonCodeRec: Record "Reason Code";
    begin
        ReasonCodeRec.Get(OldCode);
        ReasonCodeRec.Rename(NewCode);
    end;

    /// <summary>
    /// An ordinary posting account carrying an account category on purpose, and deliberately one that
    /// none of the six RS fields asks for, so the test proves the guards ignore the category rather than
    /// merely happening to agree with it.
    /// The category has to be set here rather than left blank: "G/L Account Category Mgt." stamps its own
    /// category onto a category-less account and modifies the account to save it, and the server rejects
    /// that write inside the TryFunction the fields are probed through.
    /// </summary>
    internal procedure CreatePlainPostingGLAccount() AccountNo: Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.Validate("Account Category", GLAccount."Account Category"::Liabilities);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    internal procedure GLAccountCategoryOf(AccountNo: Code[20]): Text
    var
        GLAccount: Record "G/L Account";
    begin
        if not GLAccount.Get(AccountNo) then
            exit('<missing>');
        exit(Format(GLAccount."Account Category") + '/' + Format(GLAccount."Account Subcategory Entry No."));
    end;

    internal procedure CreateBlockedGLAccount() AccountNo: Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate(Blocked, true);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    /// <summary>
    /// A Heading account - one of the four non-postable account types that a plain
    /// TableRelation = "G/L Account" happily offers. Nothing can ever post to it.
    /// </summary>
    internal procedure CreateHeadingGLAccount() AccountNo: Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Account Type", GLAccount."Account Type"::Heading);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    /// <summary>
    /// Names every RS account field that ACCEPTED the given account, so a test asserting "none of them"
    /// gets told which field is missing its guard rather than just that something is wrong. Covers all
    /// six: the four on the Inventory Posting Setup extension and the two on the reason code mapping.
    /// </summary>
    internal procedure RSAccountFieldsAccepting(LocationCode: Code[10]; ItemNo: Code[20]; ReasonCode: Code[10]; AccountNo: Code[20]) Accepted: Text
    begin
        exit(RSAccountFieldsWhere(LocationCode, ItemNo, ReasonCode, AccountNo, true));
    end;

    /// <summary>
    /// The mirror of RSAccountFieldsAccepting: names every RS account field that REJECTED the account.
    /// Used to prove the guards stay out of the way of an ordinary posting account.
    /// </summary>
    internal procedure RSAccountFieldsRejecting(LocationCode: Code[10]; ItemNo: Code[20]; ReasonCode: Code[10]; AccountNo: Code[20]) Rejected: Text
    begin
        exit(RSAccountFieldsWhere(LocationCode, ItemNo, ReasonCode, AccountNo, false));
    end;

    local procedure RSAccountFieldsWhere(LocationCode: Code[10]; ItemNo: Code[20]; ReasonCode: Code[10]; AccountNo: Code[20]; WantAccepted: Boolean) Names: Text
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        RSReasonCodeAccMapp: Record "NPR RS Reason Code Acc. Mapp.";
        Item: Record Item;
        SetupRef: RecordRef;
        MappingRef: RecordRef;
    begin
        Item.Get(ItemNo);
        InventoryPostingSetup.Get(LocationCode, Item."Inventory Posting Group");
        SetupRef.GetTable(InventoryPostingSetup);

        CollectField(Names, SetupRef, InventoryPostingSetup.FieldNo("NPR RS Calc. VAT Account"), AccountNo, WantAccepted);
        CollectField(Names, SetupRef, InventoryPostingSetup.FieldNo("NPR RS Calc. Margin Account"), AccountNo, WantAccepted);
        CollectField(Names, SetupRef, InventoryPostingSetup.FieldNo("NPR RS Surplus Account"), AccountNo, WantAccepted);
        CollectField(Names, SetupRef, InventoryPostingSetup.FieldNo("NPR RS Shortage Account"), AccountNo, WantAccepted);

        RSReasonCodeAccMapp.Get(RSReasonCodeAccMapp."Reason Type"::"Reason Code", ReasonCode);
        MappingRef.GetTable(RSReasonCodeAccMapp);

        CollectField(Names, MappingRef, RSReasonCodeAccMapp.FieldNo("Surplus Account"), AccountNo, WantAccepted);
        CollectField(Names, MappingRef, RSReasonCodeAccMapp.FieldNo("Shortage Account"), AccountNo, WantAccepted);
    end;

    local procedure CollectField(var Names: Text; RecRef: RecordRef; FieldNo: Integer; AccountNo: Code[20]; WantAccepted: Boolean)
    var
        FldRef: FieldRef;
    begin
        if TryValidateAccountField(RecRef, FieldNo, AccountNo) <> WantAccepted then
            exit;

        FldRef := RecRef.Field(FieldNo);
        if Names <> '' then
            Names += ', ';
        Names += RecRef.Caption() + '.' + FldRef.Caption();
    end;

    [TryFunction]
    local procedure TryValidateAccountField(RecRef: RecordRef; FieldNo: Integer; AccountNo: Code[20])
    var
        FldRef: FieldRef;
    begin
        FldRef := RecRef.Field(FieldNo);
        FldRef.Validate(AccountNo);
    end;

    /// <summary>
    /// Switches Automatic Cost Posting off so a count leaves its value entries unposted to the G/L, which
    /// is what makes the deferred "Post Inventory Cost to G/L" path reachable from a test. Each test holds
    /// its own library instance, so InitializeSetup turns it back on for the next one.
    /// </summary>
    internal procedure SetAutomaticCostPosting(Enabled: Boolean)
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        InventorySetup.Validate("Automatic Cost Posting", Enabled);
        InventorySetup.Modify(true);
    end;

    /// <summary>
    /// Drives the per-posting-group leg of "Inventory Posting To G/L" for one item, the way the standard
    /// "Post Inventory Cost to G/L" report does at its default Posting Method: the buffer is filled entry
    /// by entry and then flushed once with a blank Value Entry, which is what leaves the posting code with
    /// no item to resolve accounts from.
    /// </summary>
    internal procedure PostInventoryCostPerPostingGroup(ItemNo: Code[20]; DocumentNo: Code[20])
    var
        ValueEntry: Record "Value Entry";
        InvtPostingToGL: Codeunit "Inventory Posting To G/L";
    begin
        InvtPostingToGL.Initialize(true);
        InvtPostingToGL.SetRunOnlyCheck(false, false, false);

        ValueEntry.SetRange("Item No.", ItemNo);
        if ValueEntry.FindSet() then
            repeat
                InvtPostingToGL.BufferInvtPosting(ValueEntry);
            until ValueEntry.Next() = 0;

        InvtPostingToGL.PostInvtPostBufPerPostGrp(DocumentNo, '');
    end;

    /// <summary>
    /// As PostRetailCountAdjustment, but the journal batch carries a reason code - the shape the
    /// counting report produces, which copies the batch reason onto every line it generates.
    /// </summary>
    internal procedure PostRetailCountAdjustmentWithReason(ItemNo: Code[20]; LocationCode: Code[10]; CalculatedQty: Decimal; CountedQty: Decimal; ReasonCode: Code[10]) DocumentNo: Code[20]
    var
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        SourceCodeSetup: Record "Source Code Setup";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
    begin
        LibraryInventory.CreateItemJournalTemplateByType(ItemJournalTemplate, ItemJournalTemplate.Type::"Phys. Inventory");
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        InitCountAdjustmentLine(ItemJournalLine, ItemNo, LocationCode, CalculatedQty, CountedQty);
        ItemJournalLine.Validate("Journal Template Name", ItemJournalTemplate.Name);
        ItemJournalLine.Validate("Journal Batch Name", ItemJournalBatch.Name);
        ItemJournalLine."Line No." := 10000;

        SourceCodeSetup.Get();
        ItemJournalLine.Validate("Source Code", SourceCodeSetup."Phys. Inventory Journal");
        ItemJournalLine."Phys. Inventory" := true;
        ItemJournalLine."Qty. (Calculated)" := CalculatedQty;
        ItemJournalLine."Qty. (Phys. Inventory)" := CountedQty;
        ItemJournalLine.Validate("Reason Code", ReasonCode);
        ItemJournalLine.Insert(true);

        DocumentNo := ItemJournalLine."Document No.";
        ItemJnlPostBatch.Run(ItemJournalLine);
    end;

    internal procedure GetItemUnitCost(ItemNo: Code[20]): Decimal
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        exit(Item."Unit Cost");
    end;
    #endregion

    #region RS retail calculation entry type
    internal procedure CountRSCalcValueEntries(DocumentNo: Code[20]; Marked: Boolean): Integer
    var
        ValueEntry: Record "Value Entry";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        ValueEntry.SetRange("Document No.", DocumentNo);
        RSRLocalizationMgt.SetSynthesisedEntryTypeFilter(ValueEntry, Marked);
        exit(ValueEntry.Count());
    end;

    /// <summary>
    /// As CountRSCalcValueEntries, but scoped to an item rather than a document. Needed for posting
    /// paths that do not hand back a document no. - a POS sale posts through the job queue - and safe
    /// because each test creates its own item, so every entry for it belongs to the scenario.
    /// </summary>
    internal procedure CountRSCalcValueEntriesForItem(ItemNo: Code[20]; Marked: Boolean): Integer
    var
        ValueEntry: Record "Value Entry";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        ValueEntry.SetRange("Item No.", ItemNo);
        RSRLocalizationMgt.SetSynthesisedEntryTypeFilter(ValueEntry, Marked);
        exit(ValueEntry.Count());
    end;

    /// <summary>
    /// Sums Cost Amount (Actual) over the value entries of a document that do NOT carry one of the
    /// RS retail calculation entry types, i.e. the genuine cost that standard costing may see.
    /// </summary>
    internal procedure GetUnmarkedCostAmount(DocumentNo: Code[20]): Decimal
    var
        ValueEntry: Record "Value Entry";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        ValueEntry.SetRange("Document No.", DocumentNo);
        RSRLocalizationMgt.SetSynthesisedEntryTypeFilter(ValueEntry, false);
        ValueEntry.CalcSums("Cost Amount (Actual)");
        exit(ValueEntry."Cost Amount (Actual)");
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

    internal procedure GlobalSurplusAcc(): Code[20]
    begin
        exit(_GlobalSurplusAcc);
    end;

    internal procedure GlobalShortageAcc(): Code[20]
    begin
        exit(_GlobalShortageAcc);
    end;

    internal procedure InvtAdjmtAcc(): Code[20]
    begin
        exit(_InvtAdjmtAcc);
    end;

    /// <summary>
    /// Points one location + inventory posting group at its own surplus and shortage accounts, so a
    /// test can prove the per-location override is preferred over the global setup accounts.
    /// </summary>
    internal procedure SetLocationCountAccounts(LocationCode: Code[10]; ItemNo: Code[20]; var SurplusAcc: Code[20]; var ShortageAcc: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        InventoryPostingSetup.Get(LocationCode, Item."Inventory Posting Group");
        SurplusAcc := LibraryERM.CreateGLAccountNo();
        ShortageAcc := LibraryERM.CreateGLAccountNo();
        InventoryPostingSetup."NPR RS Surplus Account" := SurplusAcc;
        InventoryPostingSetup."NPR RS Shortage Account" := ShortageAcc;
        InventoryPostingSetup.Modify();
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
