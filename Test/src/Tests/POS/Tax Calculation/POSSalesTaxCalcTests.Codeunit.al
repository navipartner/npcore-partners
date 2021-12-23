codeunit 85027 "NPR POS Sales Tax Calc. Tests"
{
    // // [Feature] POS Active Sale Tax Calculation
    Subtype = Test;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        Initialized := false;
    end;

    var
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSStore: Record "NPR POS Store";
        POSSetup: Record "NPR POS Setup";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        TaxGroup: Record "Tax Group";
        POSSession: Codeunit "NPR POS Session";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryTaxCalc: Codeunit "NPR POS Lib. - Tax Calc.";
        Initialized: Boolean;


    [Test]
    procedure TaxCalcBackwardDirectSaleError()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] POS Active Calculation is not created due to error
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, true);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [WHEN] Add Item to active sale  
        // [THEN] Expect error      
        asserterror LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure TaxCalcBackwardDebitSaleError()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] POS Active Calculation is not created due to error
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        // [GIVEN] Customer
        CreateCustomer(Customer, true, TaxArea.Code, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [WHEN] Add Item to active sale  
        // [THEN] Expect error 
        asserterror LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure TaxCalcDirectSaleUnknownTaxAreaError()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] POS Active Calculation is not created due to error
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        //Unknown tax area
        AssignTaxDetailToPOSPostingProfile('', true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [WHEN] Add Item to active sale  
        // [THEN] Expect error      
        asserterror LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure TaxCalcDebitSaleUnknownTaxAreaError()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] POS Active Calculation is not created due to error
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        // [GIVEN] Customer unknown tax area
        CreateCustomer(Customer, false, '', true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [WHEN] Add Item to active sale  
        // [THEN] Expect error 
        asserterror LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure TaxCalcDirectSaleUnknownTaxAreaLineError()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] POS Active Calculation is not created due to error
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //Unknown tax area line
        TaxAreaLine.SetRange("Tax Area", TaxArea.Code);
        TaxAreaLine.DeleteAll();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [WHEN] Add Item to active sale  
        // [THEN] Expect error      
        asserterror LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure TaxCalcDebitSaleUnknownTaxAreaLineError()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] POS Active Calculation is not created due to error
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //Unknown tax area line
        TaxAreaLine.SetRange("Tax Area", TaxArea.Code);
        TaxAreaLine.DeleteAll();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, TaxArea.Code, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [WHEN] Add Item to active sale  
        // [THEN] Expect error 
        asserterror LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure TaxCalcDirectSaleUnknownTaxDetailsError()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] POS Active Calculation is not created due to error
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);

        //Unknown Tax Detail(s) - both sales and excise
        TaxDetail.DeleteAll();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [WHEN] Add Item to active sale  
        // [THEN] Expect error      
        asserterror LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure TaxCalcDebitSaleUnknownTaxDetailsError()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] POS Active Calculation is not created due to error
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);

        //Unknown Tax Detail(s) - both sales and excise
        TaxDetail.DeleteAll();

        // [GIVEN] Customer
        CreateCustomer(Customer, false, TaxArea.Code, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [WHEN] Add Item to active sale  
        // [THEN] Expect error 
        asserterror LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;


    [Test]
    procedure SkipTaxCalcForZeroAmountDirectSale()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [Scenario] POS active sale tax calculation is not created for zero unit price
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 0;
        Item.Modify();

        // [WHEN] Add Item to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Veirfy tax calculation is not created
        VerifyPOSTaxAmountCalculationNotCreated();

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure SkipTaxCalcForZeroAmountDebitSale()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [Scenario] POS active sale tax calculation is not created for zero unit price
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        // [GIVEN] Customer
        CreateCustomer(Customer, false, TaxArea.Code, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := 0;
        Item.Modify();

        // [WHEN] Add Item to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Veirfy tax calculation is not created
        VerifyPOSTaxAmountCalculationNotCreated();

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountDirectSaleForTaxUnliable()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line";
        TempPOSActiveTaxAmountLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
    begin
        // [Scenario] POS active sale tax calculation is created for tax unliable with single tax amount line caclulation
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        //Tax unliable
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, false);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;

        //Store random decimal values in temporary record
        SetRandomValues(TempPOSActiveTaxAmountLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifyMultieTaxLineCalculationUnliable(POSActiveTaxAmountLine, POSActiveTaxAmount);
        POSActiveTaxAmountLine.FindFirst();
        Assert.IsFalse(POSActiveTaxAmountLine."Tax Liable", 'Tax Liable');

        VerifyTaxLineCalc(TempPOSActiveTaxAmountLine, POSActiveTaxAmountLine);
        VerifyTaxLineCalcWithoutDiscount(POSActiveTaxAmountLine);
        VerifyTaxCalcLineCopied2Header(POSActiveTaxAmountLine, POSActiveTaxAmount);
        VerifyTaxCalcHeaderCopied2Source(POSActiveTaxAmount, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountDebitSaleForTaxUnliable()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line";
        TempPOSActiveTaxAmountLine: Record "NPR POS Sale Tax Line" temporary;
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
    begin
        // [Scenario] POS active sale tax calculation is created for tax unliable with single tax amount line caclulation
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        // [GIVEN] Customer tax unliable
        CreateCustomer(Customer, false, TaxArea.Code, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;

        //Store random decimal values in temporary record
        SetRandomValues(TempPOSActiveTaxAmountLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifyMultieTaxLineCalculationUnliable(POSActiveTaxAmountLine, POSActiveTaxAmount);
        POSActiveTaxAmountLine.FindFirst();
        Assert.IsFalse(POSActiveTaxAmountLine."Tax Liable", 'Tax Liable');
        VerifyTaxLineCalc(TempPOSActiveTaxAmountLine, POSActiveTaxAmountLine);
        VerifyTaxLineCalcWithoutDiscount(POSActiveTaxAmountLine);
        VerifyTaxCalcLineCopied2Header(POSActiveTaxAmountLine, POSActiveTaxAmount);
        VerifyTaxCalcHeaderCopied2Source(POSActiveTaxAmount, SaleLinePOS);

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountForSalesTaxTypeUnknownMaximumDirectSale()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line";
        TempPOSActiveTaxAmountLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
    begin
        // [Scenario] POS active sale tax calculation is created when maximum amount is unknown on tax detail
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;

        //Store random decimal values in temporary record
        SetRandomValues(TempPOSActiveTaxAmountLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifyMultieTaxLineCalculation(POSActiveTaxAmountLine, POSActiveTaxAmount);

        VerifyTaxLineCalc(TempPOSActiveTaxAmountLine, POSActiveTaxAmountLine);
        VerifyTaxLineCalcWithoutDiscount(POSActiveTaxAmountLine);
        VerifyTaxCalcLineCopied2Header(POSActiveTaxAmountLine, POSActiveTaxAmount);
        VerifyTaxCalcHeaderCopied2Source(POSActiveTaxAmount, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountForSalesTaxTypeUnknownMaximumDebitSale()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line";
        TempPOSActiveTaxAmountLine: Record "NPR POS Sale Tax Line" temporary;
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
    begin
        // [Scenario] POS active sale tax calculation is created when maximum amount is unknown on tax detail
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer
        CreateCustomer(Customer, false, TaxArea.Code, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;

        //Store random decimal values in temporary record
        SetRandomValues(TempPOSActiveTaxAmountLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifyMultieTaxLineCalculation(POSActiveTaxAmountLine, POSActiveTaxAmount);

        VerifyTaxLineCalc(TempPOSActiveTaxAmountLine, POSActiveTaxAmountLine);
        VerifyTaxLineCalcWithoutDiscount(POSActiveTaxAmountLine);
        VerifyTaxCalcLineCopied2Header(POSActiveTaxAmountLine, POSActiveTaxAmount);
        VerifyTaxCalcHeaderCopied2Source(POSActiveTaxAmount, SaleLinePOS);

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountForSalesTaxTypeUnitPriceLowerThenMaxAmtDirectSale()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line";
        TempPOSActiveTaxAmountLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
    begin
        // [Scenario] POS active sale tax calculation is created when unit price is below or tax detail maximum amount is unknown 
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;

        //Store random decimal values in temporary record
        SetRandomValues(TempPOSActiveTaxAmountLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifyMultieTaxLineCalculation(POSActiveTaxAmountLine, POSActiveTaxAmount);

        VerifyTaxLineCalc(TempPOSActiveTaxAmountLine, POSActiveTaxAmountLine);
        VerifyTaxLineCalcWithoutDiscount(POSActiveTaxAmountLine);
        VerifyTaxCalcLineCopied2Header(POSActiveTaxAmountLine, POSActiveTaxAmount);
        VerifyTaxCalcHeaderCopied2Source(POSActiveTaxAmount, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountForSalesTaxTypeWhereUnitPriceLowerThenMaxAmtDebitSale()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line";
        TempPOSActiveTaxAmountLine: Record "NPR POS Sale Tax Line" temporary;
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
    begin
        // [Scenario] POS active sale tax calculation is created when unit price is below or tax detail maximum amount is unknown 
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer
        CreateCustomer(Customer, false, TaxArea.Code, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := 0;

        //Store random decimal values in temporary record
        SetRandomValues(TempPOSActiveTaxAmountLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifyMultieTaxLineCalculation(POSActiveTaxAmountLine, POSActiveTaxAmount);

        VerifyTaxLineCalc(TempPOSActiveTaxAmountLine, POSActiveTaxAmountLine);
        VerifyTaxLineCalcWithoutDiscount(POSActiveTaxAmountLine);
        VerifyTaxCalcLineCopied2Header(POSActiveTaxAmountLine, POSActiveTaxAmount);
        VerifyTaxCalcHeaderCopied2Source(POSActiveTaxAmount, SaleLinePOS);

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountForSalesTaxTypeUnknownMaximumDirectSaleWithLineDisc()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line";
        TempPOSActiveTaxAmountLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
    begin
        // [Scenario] POS active sale tax calculation is created when maximum amount is unknown on tax detail
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);

        //Store random decimal values in temporary record
        SetRandomValues(TempPOSActiveTaxAmountLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale  
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", 1, LineDiscPct);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifyMultieTaxLineCalculation(POSActiveTaxAmountLine, POSActiveTaxAmount);

        VerifyTaxLineCalc(TempPOSActiveTaxAmountLine, POSActiveTaxAmountLine);
        VerifyTaxLineCalcWithLineDiscount(POSActiveTaxAmountLine, SaleLinePOS);
        VerifyTaxCalcLineCopied2Header(POSActiveTaxAmountLine, POSActiveTaxAmount);
        VerifyTaxCalcHeaderCopied2Source(POSActiveTaxAmount, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountForSalesTaxTypeUnknownMaximumDebitSaleWithLineDisc()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line";
        TempPOSActiveTaxAmountLine: Record "NPR POS Sale Tax Line" temporary;
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
    begin
        // [Scenario] POS active sale tax calculation is created when maximum amount is unknown on tax detail
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer
        CreateCustomer(Customer, false, TaxArea.Code, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);

        //Store random decimal values in temporary record
        SetRandomValues(TempPOSActiveTaxAmountLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale  
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", 1, LineDiscPct);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifyMultieTaxLineCalculation(POSActiveTaxAmountLine, POSActiveTaxAmount);

        VerifyTaxLineCalc(TempPOSActiveTaxAmountLine, POSActiveTaxAmountLine);
        VerifyTaxLineCalcWithLineDiscount(POSActiveTaxAmountLine, SaleLinePOS);
        VerifyTaxCalcLineCopied2Header(POSActiveTaxAmountLine, POSActiveTaxAmount);
        VerifyTaxCalcHeaderCopied2Source(POSActiveTaxAmount, SaleLinePOS);

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountForSalesTaxTypeUnitPriceLowerThenMaxAmtDirectSaleWithLineDisc()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line";
        TempPOSActiveTaxAmountLine: Record "NPR POS Sale Tax Line" temporary;
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
    begin
        // [Scenario] POS active sale tax calculation is created when unit price is below or tax detail maximum amount is unknown 
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);

        //Store random decimal values in temporary record
        SetRandomValues(TempPOSActiveTaxAmountLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale  
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", 1, LineDiscPct);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifyMultieTaxLineCalculation(POSActiveTaxAmountLine, POSActiveTaxAmount);

        VerifyTaxLineCalc(TempPOSActiveTaxAmountLine, POSActiveTaxAmountLine);
        VerifyTaxLineCalcWithLineDiscount(POSActiveTaxAmountLine, SaleLinePOS);
        VerifyTaxCalcLineCopied2Header(POSActiveTaxAmountLine, POSActiveTaxAmount);
        VerifyTaxCalcHeaderCopied2Source(POSActiveTaxAmount, SaleLinePOS);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountForSalesTaxTypeWhereUnitPriceHigherThenMaxAmtDebitSaleWithLineDisc()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line";
        TempPOSActiveTaxAmountLine: Record "NPR POS Sale Tax Line" temporary;
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: Decimal;
        LineDisc: Decimal;
        LineDiscPct: Decimal;
    begin
        // [Scenario] POS active sale tax calculation is created when unit price is below or tax detail maximum amount is unknown 
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer
        CreateCustomer(Customer, false, TaxArea.Code, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        //Quantity to sell without discount
        Qty := 1;
        LineDisc := 0;
        LineDiscPct := LibraryRandom.RandDecInRange(1, 100, 5);

        //Store random decimal values in temporary record
        SetRandomValues(TempPOSActiveTaxAmountLine, Item, Qty, 0, LineDisc, LineDiscPct);

        // [WHEN] Add Item to active sale  
        LibraryPOSMock.CreateItemLineWithDiscount(POSSession, Item."No.", 1, LineDiscPct);

        // [THEN] Verify Tax Calculation
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId), 'POS Active Tax Calculation not created');

        VerifyMultieTaxLineCalculation(POSActiveTaxAmountLine, POSActiveTaxAmount);

        VerifyTaxLineCalc(TempPOSActiveTaxAmountLine, POSActiveTaxAmountLine);
        VerifyTaxLineCalcWithLineDiscount(POSActiveTaxAmountLine, SaleLinePOS);
        VerifyTaxCalcLineCopied2Header(POSActiveTaxAmountLine, POSActiveTaxAmount);
        VerifyTaxCalcHeaderCopied2Source(POSActiveTaxAmount, SaleLinePOS);

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountForSalesTaxTypeUnknownMaximumDirectSalePosted()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: array[2] of Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        TaxJurisdiction: Record "Tax Jurisdiction";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: array[2] of Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        SalePOS: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Qty: array[2] of Decimal;
        LineDisc: array[2] of Decimal;
        LineDiscPct: array[2] of Decimal;
        AmountToPay: array[2] of Decimal;
        SaleEnded: Boolean;
    begin
        // [Scenario] POS active sale tax calculation is created when maximum amount is unknown on tax detail
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        TaxJurisdiction.DeleteAll();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        LibraryTaxCalc.UpdateTaxJurisdictionSalesAccounts();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item[1], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item[1]."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item[1].Modify();

        //Quantity to sell without discount
        Qty[1] := 1;
        LineDisc[1] := 0;
        LineDiscPct[1] := 0;

        // [GIVEN] Item with unit price        
        CreateItem(Item[2], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item[2]."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item[2].Modify();

        //Quantity to sell without discount
        Qty[2] := 1;
        LineDisc[2] := 0;
        LineDiscPct[2] := 0;

        // [GIVEN] Add Items to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item[1]."No.", 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item[2]."No.", 1);

        // [GIVEN] Get amount to pay for active sale
        POSSale.GetCurrentSale(SalePOS);

        //First Direct Sale
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.SetRange("No.", Item[1]."No.");
        SaleLinePOS.FindFirst();
        AmountToPay[1] := GetAmountToPay(SaleLinePOS);

        POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId);
        VerifyMultieTaxLineCalculation(POSActiveTaxAmountLine[1], POSActiveTaxAmount);

        //Second Direct Sale
        SaleLinePOS.SetRange("No.", Item[2]."No.");
        SaleLinePOS.FindFirst();
        AmountToPay[2] := GetAmountToPay(SaleLinePOS);

        POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId);
        VerifyMultieTaxLineCalculation(POSActiveTaxAmountLine[2], POSActiveTaxAmount);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay[1] + AmountToPay[2], '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Tax Calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifyMultieTaxLineCalculation(POSPostedTaxAmountLine, POSEntry, TaxArea.Code, TaxGroup.Code, true, TaxDetail."Effective Date");
        VerifyPostedTaxCalcCopied2POSEntries(POSPostedTaxAmountLine, POSEntry);
        VerifyPostedTaxCalcCopied2VATEntries(POSPostedTaxAmountLine, POSEntry);
        VerifyVATforGLEntry(POSEntry, TaxArea);

        POSStore.GetProfile(POSPostingProfile);
        VerifySalesforGLEntry(POSEntry, Item, POSPostingProfile."Gen. Bus. Posting Group");

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountForSalesTaxTypeUnknownMaximumDebitSalePosted()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: array[2] of Record Item;
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: array[2] of Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        TaxJurisdiction: Record "Tax Jurisdiction";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: array[2] of Decimal;
        LineDisc: array[2] of Decimal;
        LineDiscPct: array[2] of Decimal;
        AmountToPay: array[2] of Decimal;
        SaleEnded: Boolean;
    begin
        // [Scenario] POS active sale tax calculation is created when maximum amount is unknown on tax detail
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        TaxJurisdiction.DeleteAll();
        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer
        CreateCustomer(Customer, false, TaxArea.Code, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Update Tax account (sales)
        LibraryTaxCalc.UpdateTaxJurisdictionSalesAccounts();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price        
        CreateItem(Item[1], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item[1]."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item[1].Modify();

        //Quantity to sell without discount
        Qty[1] := 1;
        LineDisc[1] := 0;
        LineDiscPct[1] := 0;

        // [GIVEN] Item with unit price        
        CreateItem(Item[2], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item[2]."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item[2].Modify();

        //Quantity to sell without discount
        Qty[2] := 1;
        LineDisc[2] := 0;
        LineDiscPct[2] := 0;

        // [GIVEN] Add Items to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item[1]."No.", 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item[2]."No.", 1);

        // [GIVEN] Get amount to pay for active sale
        POSSale.GetCurrentSale(SalePOS);

        //First Debit Sale
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.SetRange("No.", Item[1]."No.");
        SaleLinePOS.FindFirst();
        AmountToPay[1] := GetAmountToPay(SaleLinePOS);

        POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId);
        VerifyMultieTaxLineCalculation(POSActiveTaxAmountLine[1], POSActiveTaxAmount);

        //Second Debit Sale
        SaleLinePOS.SetRange("No.", Item[2]."No.");
        SaleLinePOS.FindFirst();
        AmountToPay[2] := GetAmountToPay(SaleLinePOS);

        POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId);
        VerifyMultieTaxLineCalculation(POSActiveTaxAmountLine[2], POSActiveTaxAmount);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay[1] + AmountToPay[2], '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Tax Calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifyMultieTaxLineCalculation(POSPostedTaxAmountLine, POSEntry, TaxArea.Code, TaxGroup.Code, true, TaxDetail."Effective Date");
        VerifyPostedTaxCalcCopied2POSEntries(POSPostedTaxAmountLine, POSEntry);
        VerifyPostedTaxCalcCopied2VATEntries(POSPostedTaxAmountLine, POSEntry);
        VerifyVATforGLEntry(POSEntry, TaxArea);
        VerifySalesforGLEntry(POSEntry, Item, Customer."Gen. Bus. Posting Group");

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountDirectSaleForTaxUnliablePosted()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: array[2] of Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: array[2] of Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        SalePOS: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        TaxJurisdiction: Record "Tax Jurisdiction";
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Qty: array[2] of Decimal;
        LineDisc: array[2] of Decimal;
        LineDiscPct: array[2] of Decimal;
        AmountToPay: array[2] of Decimal;
        SaleEnded: Boolean;
    begin
        // [Scenario] POS active sale tax calculation is created and posted for tax unliable with single tax amount line caclulation
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        TaxJurisdiction.DeleteAll();
        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        //Tax unliable
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, false);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        LibraryTaxCalc.UpdateTaxJurisdictionSalesAccounts();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item[1], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item[1]."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item[1].Modify();

        //Quantity to sell without discount
        Qty[1] := 1;
        LineDisc[1] := 0;
        LineDiscPct[1] := 0;

        // [GIVEN] Item with unit price        
        CreateItem(Item[2], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item[2]."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item[2].Modify();

        //Quantity to sell without discount
        Qty[2] := 1;
        LineDisc[2] := 0;
        LineDiscPct[2] := 0;

        // [GIVEN] Add Items to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item[1]."No.", 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item[2]."No.", 1);

        // [GIVEN] Get amount to pay for active sale
        POSSale.GetCurrentSale(SalePOS);

        //First Direct Sale
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.SetRange("No.", Item[1]."No.");
        SaleLinePOS.FindFirst();
        AmountToPay[1] := GetAmountToPay(SaleLinePOS);

        POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId);
        VerifyMultieTaxLineCalculationUnliable(POSActiveTaxAmountLine[1], POSActiveTaxAmount);

        //Second Direct Sale
        SaleLinePOS.SetRange("No.", Item[2]."No.");
        SaleLinePOS.FindFirst();
        AmountToPay[2] := GetAmountToPay(SaleLinePOS);

        POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId);
        VerifyMultieTaxLineCalculationUnliable(POSActiveTaxAmountLine[2], POSActiveTaxAmount);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay[1] + AmountToPay[2], '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Tax Calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifyMultieTaxLineCalculation(POSPostedTaxAmountLine, POSEntry, TaxArea.Code, TaxGroup.Code, false, TaxDetail."Effective Date");
        VerifyPostedTaxCalcCopied2POSEntries(POSPostedTaxAmountLine, POSEntry);
        VerifyPostedTaxCalcNotCopied2VATEntries(POSEntry);
        VerifyVATforGLEntryUnliable(POSEntry, TaxArea);

        POSStore.GetProfile(POSPostingProfile);
        VerifySalesforGLEntry(POSEntry, Item, POSPostingProfile."Gen. Bus. Posting Group");

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountDebitSaleForTaxUnliablePosted()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: array[2] of Record Item;
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: array[2] of Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        TaxJurisdiction: Record "Tax Jurisdiction";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: array[2] of Decimal;
        LineDisc: array[2] of Decimal;
        LineDiscPct: array[2] of Decimal;
        AmountToPay: array[2] of Decimal;
        SaleEnded: Boolean;
    begin
        // [Scenario] POS active sale tax calculation is created and posted for tax unliable with single tax amount line caclulation
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        TaxJurisdiction.DeleteAll();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        //If it's set, reset maximum amount on Tax Details
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 0);

        // [GIVEN] Customer tax unliable
        CreateCustomer(Customer, false, TaxArea.Code, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        LibraryTaxCalc.UpdateTaxJurisdictionSalesAccounts();

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price        
        CreateItem(Item[1], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item[1]."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item[1].Modify();

        //Quantity to sell without discount
        Qty[1] := 1;
        LineDisc[1] := 0;
        LineDiscPct[1] := 0;

        // [GIVEN] Item with unit price        
        CreateItem(Item[2], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item[2]."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item[2].Modify();

        //Quantity to sell without discount
        Qty[2] := 1;
        LineDisc[2] := 0;
        LineDiscPct[2] := 0;

        // [GIVEN] Add Items to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item[1]."No.", 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item[2]."No.", 1);

        // [GIVEN] Get amount to pay for active sale
        POSSale.GetCurrentSale(SalePOS);

        //First Debit Sale
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.SetRange("No.", Item[1]."No.");
        SaleLinePOS.FindFirst();
        AmountToPay[1] := GetAmountToPay(SaleLinePOS);

        POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId);
        VerifyMultieTaxLineCalculationUnliable(POSActiveTaxAmountLine[1], POSActiveTaxAmount);

        //Second Debit Sale
        SaleLinePOS.SetRange("No.", Item[2]."No.");
        SaleLinePOS.FindFirst();
        AmountToPay[2] := GetAmountToPay(SaleLinePOS);

        POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId);
        VerifyMultieTaxLineCalculationUnliable(POSActiveTaxAmountLine[2], POSActiveTaxAmount);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay[1] + AmountToPay[2], '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Tax Calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifyMultieTaxLineCalculation(POSPostedTaxAmountLine, POSEntry, TaxArea.Code, TaxGroup.Code, false, TaxDetail."Effective Date");
        VerifyPostedTaxCalcCopied2POSEntries(POSPostedTaxAmountLine, POSEntry);
        VerifyPostedTaxCalcNotCopied2VATEntries(POSEntry);
        VerifyVATforGLEntryUnliable(POSEntry, TaxArea);
        VerifySalesforGLEntry(POSEntry, Item, Customer."Gen. Bus. Posting Group");

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountForSalesTaxTypeUnitPriceHigherThenMaxAmtDirectSalePosted()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        POSViewProfile: Record "NPR POS View Profile";
        Item: array[2] of Record Item;
        TaxArea: Record "Tax Area";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: array[2] of Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        SalePOS: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        TaxJurisdiction: Record "Tax Jurisdiction";
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Qty: array[2] of Decimal;
        LineDisc: array[2] of Decimal;
        LineDiscPct: array[2] of Decimal;
        AmountToPay: array[2] of Decimal;
        SaleEnded: Boolean;
    begin
        // [Scenario] POS active sale tax calculation is created and posted when unit price is above tax detail maximum amount 
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        TaxJurisdiction.DeleteAll();

        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignTaxDetailToPOSPostingProfile(TaxArea.Code, true);

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        // [GIVEN] Update Tax account (sales)
        LibraryTaxCalc.UpdateTaxJurisdictionSalesAccounts();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        CreateItem(Item[1], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item[1]."Unit Price" := LibraryRandom.RandDecInRange(2, 100, 5);
        Item[1].Modify();

        //Quantity to sell without discount
        Qty[1] := 1;
        LineDisc[1] := 0;
        LineDiscPct[1] := 0;

        // [GIVEN] Item with unit price        
        CreateItem(Item[2], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item[2]."Unit Price" := LibraryRandom.RandDecInRange(2, 100, 5);
        Item[2].Modify();

        //Quantity to sell without discount
        Qty[2] := 1;
        LineDisc[2] := 0;
        LineDiscPct[2] := 0;

        //If it's set, reset maximum amount on Tax Details to less then unit price
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 1);

        // [GIVEN] Add Items to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item[1]."No.", 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item[2]."No.", 1);

        // [GIVEN] Get amount to pay for active sale
        POSSale.GetCurrentSale(SalePOS);

        //First Direct Sale
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.SetRange("No.", Item[1]."No.");
        SaleLinePOS.FindFirst();
        AmountToPay[1] := GetAmountToPay(SaleLinePOS);

        POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId);

        //Second Direct Sale
        SaleLinePOS.SetRange("No.", Item[2]."No.");
        SaleLinePOS.FindFirst();
        AmountToPay[2] := GetAmountToPay(SaleLinePOS);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay[1] + AmountToPay[2], '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Tax Calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifyMultieTaxLineCalculation(POSPostedTaxAmountLine, POSEntry, TaxArea.Code, TaxGroup.Code, true, TaxDetail."Effective Date");
        VerifyPostedTaxCalcCopied2POSEntries(POSPostedTaxAmountLine, POSEntry);
        VerifyPostedTaxCalcCopied2VATEntries(POSPostedTaxAmountLine, POSEntry);
        VerifyVATforGLEntry(POSEntry, TaxArea);
        POSStore.GetProfile(POSPostingProfile);
        VerifySalesforGLEntry(POSEntry, Item, POSPostingProfile."Gen. Bus. Posting Group");

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalcTaxAmountForSalesTaxTypeWhereUnitPriceHigherThenMaxAmtDebitSalePosted()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: array[2] of Record Item;
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: array[2] of Record "NPR POS Sale Tax Line";
        POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        TaxJurisdiction: Record "Tax Jurisdiction";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
        Qty: array[2] of Decimal;
        LineDisc: array[2] of Decimal;
        LineDiscPct: array[2] of Decimal;
        AmountToPay: array[2] of Decimal;
        SaleEnded: Boolean;
    begin
        // [Scenario] POS active sale tax calculation is created and posted when unit price is above tax detail maximum amount 
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        TaxJurisdiction.DeleteAll();
        // [GIVEN] Tax Detail on state, county and city level for US localization (Tax Country US)
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5), LibraryRandom.RandDec(10, 5));

        // [GIVEN] Customer
        CreateCustomer(Customer, false, TaxArea.Code, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Sales Tax");
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Update rounding amount account
        UpdatePOSSalesRoundingAcc();

        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Default POS Posting Setup" := POSPostingProfile."Default POS Posting Setup"::Customer;
        POSPostingProfile.Modify();

        // [GIVEN] Update Tax account (sales)
        LibraryTaxCalc.UpdateTaxJurisdictionSalesAccounts();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [GIVEN] Item with unit price        
        CreateItem(Item[1], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item[1]."Unit Price" := LibraryRandom.RandDecInRange(2, 100, 5);
        Item[1].Modify();

        //Quantity to sell without discount
        Qty[1] := 1;
        LineDisc[1] := 0;
        LineDiscPct[1] := 0;

        // [GIVEN] Item with unit price        
        CreateItem(Item[2], VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", TaxGroup.Code, false);
        Item[2]."Unit Price" := LibraryRandom.RandDecInRange(2, 100, 5);
        Item[2].Modify();

        //Quantity to sell without discount
        Qty[2] := 1;
        LineDisc[2] := 0;
        LineDiscPct[2] := 0;

        //If it's set, reset maximum amount on Tax Details to less then unit price
        TaxDetail.SetRange("Tax Jurisdiction Code");
        TaxDetail.ModifyAll("Maximum Amount/Qty.", 1);

        // [GIVEN] Add Items to active sale  
        LibraryPOSMock.CreateItemLine(POSSession, Item[1]."No.", 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item[2]."No.", 1);

        // [GIVEN] Get amount to pay for active sale
        POSSale.GetCurrentSale(SalePOS);

        //First Debit Sale
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.SetRange("No.", Item[1]."No.");
        SaleLinePOS.FindFirst();
        AmountToPay[1] := GetAmountToPay(SaleLinePOS);

        POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId);

        //Second Debit Sale
        SaleLinePOS.SetRange("No.", Item[2]."No.");
        SaleLinePOS.FindFirst();
        AmountToPay[2] := GetAmountToPay(SaleLinePOS);

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay[1] + AmountToPay[2], '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Tax Calculation
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        VerifyMultieTaxLineCalculation(POSPostedTaxAmountLine, POSEntry, TaxArea.Code, TaxGroup.Code, true, TaxDetail."Effective Date");
        VerifyPostedTaxCalcCopied2POSEntries(POSPostedTaxAmountLine, POSEntry);
        VerifyPostedTaxCalcCopied2VATEntries(POSPostedTaxAmountLine, POSEntry);
        VerifyVATforGLEntry(POSEntry, TaxArea);
        VerifySalesforGLEntry(POSEntry, Item, Customer."Gen. Bus. Posting Group");

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.Destructor();
            Clear(POSSession);
        end;

        if not Initialized then begin
            LibraryTaxCalc.BindSalesTaxCalcTest();
            LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            LibraryPOSMasterData.CreatePOSSetup(POSSetup);
            LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);

            LibraryTaxCalc.CreateTaxSetup();
            LibraryTaxCalc.CreateTaxGroup(TaxGroup);

            CreateEmptyTaxPostingSetup();

            Initialized := true;
        end;
        DeletePOSPostedEntries();
        Commit();
    end;

    local procedure DeletePOSPostedEntries()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        //Just in case if performance test is created and run on test company for POS test unit
        //then POS posting is terminated because POS entries are stored in database with sales tickect no.
        //defined in the Library POS Master Data 
        POSEntry.DeleteAll();
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; TaxCaclType: Enum "NPR POS Tax Calc. Type")
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        LibraryTaxCalc2: codeunit "NPR POS Lib. - Tax Calc.";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryTaxCalc2.CreateSalesTaxPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code, TaxCaclType);
    end;

    local procedure AssignVATBusPostGroupToPOSPostingProfile(VATBusPostingGroupCode: Code[20])
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignVATBusPostGroupToPOSPostingProfile(POSStore, VATBusPostingGroupCode);
    end;

    local procedure AssignTaxDetailToPOSPostingProfile(TaxAreaCode: Code[20]; TaxLiable: Boolean)
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignTaxDetailToPOSPostingProfile(POSStore, TaxAreaCode, TaxLiable);
    end;

    local procedure CreatePOSViewProfile(var POSViewProfile: Record "NPR POS View Profile"; PricesIncludingTax: Boolean)
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        if PricesIncludingTax then
            POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT
        else
            POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::"Sales Tax";
        POSViewProfile.Modify();
    end;

    local procedure AssignPOSViewProfileToPOSUnit(POSViewProfileCode: Code[20])
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(POSUnit, POSViewProfileCode);
    end;

    local procedure CreateItem(var Item: Record Item; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; TaxGroupCode: Code[20]; PricesIncludesVAT: Boolean)
    var
        LibraryTaxCalc2: codeunit "NPR POS Lib. - Tax Calc.";
    begin
        LibraryTaxCalc2.CreateItem(Item, VATProdPostingGroupCode, VATBusPostingGroupCode);
        Item."Price Includes VAT" := PricesIncludesVAT;
        Item."Tax Group Code" := TaxGroupCode;
        Item.Modify();
        CreateGeneralPostingSetupForItem(Item);
    end;

    local procedure CreateGeneralPostingSetupForItem(Item: Record Item)
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        POSStore.GetProfile(POSPostingProfile);
        LibraryPOSMasterData.CreateGeneralPostingSetupForSaleItem(
                                        POSPostingProfile."Gen. Bus. Posting Group",
                                        Item."Gen. Prod. Posting Group",
                                        POSStore."Location Code",
                                        Item."Inventory Posting Group");
    end;

    local procedure CreateCustomer(var Customer: Record Customer; PricesIncludingTax: Boolean; TaxAreCode: Code[20]; TaxLiable: Boolean)
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomerWithAddress(Customer);
        Customer."Prices Including VAT" := PricesIncludingTax;
        Customer.validate("Tax Area Code", TaxAreCode);
        Customer."Tax Liable" := TaxLiable;
        Customer.Modify();
    end;

    local procedure VerifyPOSTaxAmountCalculationNotCreated()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line";
        POSActiveTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        SaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsFalse(POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId), 'POS Active Tax Calculation created');
        POSActiveTaxCalc.FilterLines(POSActiveTaxAmount, POSActiveTaxAmountLine);
        Assert.IsTrue(POSActiveTaxAmountLine.IsEmpty(), 'POS Active Tax Amount Lines created');
    end;

    local procedure VerifyMultieTaxLineCalculation(var POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line"; POSActiveTaxAmount: Record "NPR POS Sale Tax")
    var
        POSActiveTaxAmountLine2: Record "NPR POS Sale Tax Line";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
    begin
        POSActiveTaxCalc.FilterLines(POSActiveTaxAmount, POSActiveTaxAmountLine);
        Assert.IsFalse(POSActiveTaxAmountLine.IsEmpty(), 'POS Active Tax Amount Lines not created');
        Assert.AreNotEqual(1, POSActiveTaxAmountLine.Count(), 'One tax amount line is created');
        POSActiveTaxAmountLine2.COpy(POSActiveTaxAmountLine);
        POSActiveTaxAmountLine2.FindSet();
        repeat
            Assert.IsFalse(POSActiveTaxAmountLine2."Tax Area Code" = '', 'Tax Area Code empty');
            Assert.IsFalse(POSActiveTaxAmountLine2."Tax Group Code" = '', 'Tax Group Code empty');
            Assert.IsTrue(POSActiveTaxAmountLine2."Tax Liable", 'Tax unliable');
        until POSActiveTaxAmountLine2.Next() = 0;
    end;

    local procedure VerifyMultieTaxLineCalculationUnliable(var POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line"; POSActiveTaxAmount: Record "NPR POS Sale Tax")
    var
        POSActiveTaxAmountLine2: Record "NPR POS Sale Tax Line";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
    begin
        POSActiveTaxCalc.FilterLines(POSActiveTaxAmount, POSActiveTaxAmountLine);
        Assert.IsFalse(POSActiveTaxAmountLine.IsEmpty(), 'POS Active Tax Amount Lines not created');
        Assert.AreNotEqual(1, POSActiveTaxAmountLine.Count(), 'One tax amount line is created');
        POSActiveTaxAmountLine2.COpy(POSActiveTaxAmountLine);
        POSActiveTaxAmountLine2.FindSet();
        repeat
            Assert.IsFalse(POSActiveTaxAmountLine2."Tax Area Code" = '', 'Tax Area Code empty');
            Assert.IsFalse(POSActiveTaxAmountLine2."Tax Group Code" = '', 'Tax Group Code empty');
            Assert.IsTrue(not POSActiveTaxAmountLine2."Tax Liable", 'Tax liable');
        until POSActiveTaxAmountLine2.Next() = 0;
    end;

    local procedure VerifyMultieTaxLineCalculation(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSEntry: Record "NPR POS Entry"; TaxAreaCode: code[20]; TaxGroupCode: Code[20]; TaxLiable: Boolean; EffectiveDate: Date)
    var
        POSPostedTaxCalc: codeunit "NPR POS Entry Tax Calc.";
    begin
        POSPostedTaxCalc.FilterLines(POSEntry."Entry No.", POSEntryTaxLine);
        POSEntryTaxLine.SetRange("Tax Area Code", TaxAreaCode);
        POSEntryTaxLine.SetRange("Tax Group Code", TaxGroupCode);
        POSEntryTaxLine.SetRange("Entry Date", EffectiveDate);
        POSEntryTaxLine.SetRange("Tax Liable", TaxLiable);
        Assert.IsFalse(POSEntryTaxLine.IsEmpty(), 'POS Tax Amount not posted');
        Assert.IsTrue(3 = POSEntryTaxLine.Count(), 'More or less then three POS entry tax lines are created');
    end;

    local procedure SetRandomValues(var TempPOSActiveTaxAmountLine: Record "NPR POS Sale Tax Line"; Item: Record Item; Qty: Decimal; TaxPct: Decimal; LineDisc: Decimal; LineDiscPct: Decimal)
    var
        POSActiveTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        Currency: Record Currency;
    begin
        POSActiveTaxCalc.GetCurrency(Currency, TempPOSActiveTaxAmountLine."Currency Code");

        TempPOSActiveTaxAmountLine."Unit Price Excl. Tax" := Item."Unit Price";
        TempPOSActiveTaxAmountLine.Quantity := Qty;
        TempPOSActiveTaxAmountLine."Tax %" := TaxPct;

        case true of
            LineDiscPct <> 0:
                begin
                    TempPOSActiveTaxAmountLine."Discount %" := LineDiscPct;
                    TempPOSActiveTaxAmountLine."Discount Amount" := Round(TempPOSActiveTaxAmountLine."Unit Price Excl. Tax" * TempPOSActiveTaxAmountLine.Quantity * TempPOSActiveTaxAmountLine."Discount %" / 100, Currency."Amount Rounding Precision");
                end;
            LineDisc <> 0:
                begin
                    TempPOSActiveTaxAmountLine."Discount Amount" := Round(LineDisc, Currency."Amount Rounding Precision");
                    TempPOSActiveTaxAmountLine."Discount %" := TempPOSActiveTaxAmountLine."Discount Amount" * 100 / TempPOSActiveTaxAmountLine."Unit Price Excl. Tax" * TempPOSActiveTaxAmountLine.Quantity;
                end;
        end;
        TempPOSActiveTaxAmountLine."Allow Line Discount" := (TempPOSActiveTaxAmountLine."Discount Amount" > 0) or (TempPOSActiveTaxAmountLine."Discount %" > 0);
    end;

    local procedure StorePOSActiveTaxAmounts(var TempPOSPostedTaxAmountLine: Record "NPR POS Entry Tax Line"; POSActiveTaxAmount: Record "NPR POS Sale Tax")
    begin
        TempPOSPostedTaxAmountLine.Quantity += POSActiveTaxAmount."Source Quantity";
        TempPOSPostedTaxAmountLine."Tax Base Amount" += POSActiveTaxAmount."Calculated Amount Excl. Tax";
        TempPOSPostedTaxAmountLine."Tax Base Amount FCY" += POSActiveTaxAmount."Calculated Amount Excl. Tax";
        TempPOSPostedTaxAmountLine."Line Amount" += POSActiveTaxAmount."Calculated Line Amount";
        TempPOSPostedTaxAmountLine."Tax Amount" += POSActiveTaxAmount."Calculated Tax Amount";
        TempPOSPostedTaxAmountLine."Calculated Tax Amount" += POSActiveTaxAmount."Calculated Tax Amount";
        TempPOSPostedTaxAmountLine."Amount Including Tax" += POSActiveTaxAmount."Calculated Amount Incl. Tax";
    end;

    local procedure StorePOSActiveTaxAmounts(var TempPOSPostedTaxAmountLine: Record "NPR POS Entry Tax Line"; var POSSaleTaxLine: Record "NPR POS Sale Tax Line")
    begin
        POSSaleTaxLine.CalcSums(Quantity, "Amount Excl. Tax", "Line Amount", "Tax Amount", "Amount Incl. Tax");
        TempPOSPostedTaxAmountLine.Quantity += POSSaleTaxLine.Quantity;
        TempPOSPostedTaxAmountLine."Tax Base Amount" += POSSaleTaxLine."Amount Excl. Tax";
        TempPOSPostedTaxAmountLine."Tax Base Amount FCY" += POSSaleTaxLine."Amount Excl. Tax";
        TempPOSPostedTaxAmountLine."Line Amount" += POSSaleTaxLine."Line Amount";
        TempPOSPostedTaxAmountLine."Tax Amount" += POSSaleTaxLine."Tax Amount";
        TempPOSPostedTaxAmountLine."Calculated Tax Amount" += POSSaleTaxLine."Tax Amount";
        TempPOSPostedTaxAmountLine."Amount Including Tax" += POSSaleTaxLine."Amount Incl. Tax";
    end;

    local procedure VerifyTaxLineCalc(var TempPOSActiveTaxAmountLine: Record "NPR POS Sale Tax Line"; var POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line")
    var
        Currency: Record Currency;
        POSActiveTaxAmountLine2: Record "NPR POS Sale Tax Line";
        POSActiveTaxCalc: codeunit "NPR POS Sale Tax Calc.";
    begin
        POSActiveTaxAmountLine2.Copy(POSActiveTaxAmountLine);
        POSActiveTaxCalc.GetCurrency(Currency, POSActiveTaxAmountLine."Currency Code");

        TempPOSActiveTaxAmountLine."Amount Excl. Tax" := TempPOSActiveTaxAmountLine."Unit Price Excl. Tax" * TempPOSActiveTaxAmountLine.Quantity - TempPOSActiveTaxAmountLine."Discount Amount";
        TempPOSActiveTaxAmountLine."Amount Excl. Tax" := Round(TempPOSActiveTaxAmountLine."Amount Excl. Tax", Currency."Amount Rounding Precision");
        TempPOSActiveTaxAmountLine."Unit Price Excl. Tax" := Round(TempPOSActiveTaxAmountLine."Unit Price Excl. Tax", Currency."Unit-Amount Rounding Precision");

        POSActiveTaxAmountLine2.FindSet();
        repeat
            Assert.AreEqual(TempPOSActiveTaxAmountLine."Amount Excl. Tax", POSActiveTaxAmountLine2."Amount Excl. Tax", 'Calculated amount excluding tax is not equal to source line amount');
            Assert.AreEqual(TempPOSActiveTaxAmountLine."Unit Price Excl. Tax", POSActiveTaxAmountLine2."Unit Price Excl. Tax", 'Calculated price excluding tax is not correct');

            if POSActiveTaxAmountLine2."Tax Liable" then begin
                Assert.AreNotEqual(0, POSActiveTaxAmountLine2."Tax Amount", 'Tax Amount not calculated on tax line');
                Assert.IsTrue(POSActiveTaxAmountLine2."Amount Incl. Tax" > POSActiveTaxAmountLine2."Amount Excl. Tax", 'Amount including tax is less or equal then amount excluding tax');
            end else begin
                Assert.AreEqual(0, POSActiveTaxAmountLine2."Tax Amount", 'Tax Amount calculated on tax line');
                Assert.IsTrue(POSActiveTaxAmountLine2."Amount Incl. Tax" = POSActiveTaxAmountLine2."Amount Excl. Tax", 'Amount including tax is differenet then amount excluding tax');
            end;
        until POSActiveTaxAmountLine2.next() = 0;
    end;

    local procedure VerifyTaxLineCalcWithoutDiscount(var POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line")
    var
        POSActiveTaxAmountLine2: Record "NPR POS Sale Tax Line";
    begin
        POSActiveTaxAmountLine2.Copy(POSActiveTaxAmountLine);

        POSActiveTaxAmountLine2.FindSet();
        repeat
            Assert.IsFalse(POSActiveTaxAmountLine2."Applied Line Discount", 'Line Disocunt applied');
            Assert.AreEqual(0, POSActiveTaxAmountLine2."Discount %", 'Active Tax Line Discount % is not equal to zero');
            Assert.AreEqual(0, POSActiveTaxAmountLine2."Discount Amount", 'Active Tax Line Discount Amount is not equal to zero');
        until POSActiveTaxAmountLine2.next() = 0;
    end;

    local procedure VerifyTaxCalcLineCopied2Header(var POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line"; POSActiveTaxAmount: Record "NPR POS Sale Tax")
    var
        POSActiveTaxAmountLine2: Record "NPR POS Sale Tax Line";
    begin
        POSActiveTaxAmountLine2.Copy(POSActiveTaxAmountLine);
        POSActiveTaxAmountLine2.FindFirst();
        POSActiveTaxAmountLine2.CalcSums("Unit Tax", "Tax Amount");


        Assert.AreEqual(POSActiveTaxAmountLine2."Unit Price Excl. Tax", POSActiveTaxAmount."Calculated Price Excl. Tax", 'Calculated unit prices excluding tax not equal on line and header');
        Assert.AreEqual(POSActiveTaxAmountLine2."Unit Tax", POSActiveTaxAmount."Calculated Unit Tax", 'Calculated unit taxes not equal on line and header');
        Assert.AreEqual(POSActiveTaxAmountLine2."Unit Price Excl. Tax" + POSActiveTaxAmountLine2."Unit Tax", POSActiveTaxAmount."Calculated Price Incl. Tax", 'Calculated unit prices including tax not equal on line and header');

        Assert.AreEqual(POSActiveTaxAmountLine2."Amount Excl. Tax", POSActiveTaxAmount."Calculated Amount Excl. Tax", 'Calculated amounts excluding tax not equal on line and header');
        Assert.AreEqual(POSActiveTaxAmountLine2."Tax Amount", POSActiveTaxAmount."Calculated Tax Amount", 'Calculated tax amounts not equal on line and header');
        Assert.AreEqual(POSActiveTaxAmountLine2."Amount Excl. Tax" + POSActiveTaxAmountLine2."Tax Amount", POSActiveTaxAmount."Calculated Amount Incl. Tax", 'Calculated amounts including tax not equal on line and header');
        if POSActiveTaxAmountLine2.Count() = 1 then
            Assert.AreEqual(POSActiveTaxAmountLine2."Tax %", POSActiveTaxAmount."Calculated Tax %", 'Calculated tax % not equal on line and header');
        Assert.AreEqual(POSActiveTaxAmountLine2."Line Amount", POSActiveTaxAmount."Calculated Line Amount", 'Calculated line amounts not equal on line and header');

        Assert.AreEqual(POSActiveTaxAmountLine2."Applied Line Discount", POSActiveTaxAmount."Calc. Applied Line Discount", 'Calculated applied line discounts not equal on line and header');
        Assert.AreEqual(POSActiveTaxAmountLine2."Discount %", POSActiveTaxAmount."Calculated Discount %", 'Calculated discount % not equal on line and header');
        Assert.AreEqual(POSActiveTaxAmountLine2."Discount Amount", POSActiveTaxAmount."Calculated Discount Amount", 'Calculated discount amounts not equal on line and header');
    end;

    local procedure VerifyTaxCalcHeaderCopied2Source(POSActiveTaxAmount: Record "NPR POS Sale Tax"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        Assert.AreEqual(POSActiveTaxAmount."Calculated Discount %", SaleLinePOS."Discount %", 'Calculated discounts % not equal on header and source');
        Assert.AreEqual(POSActiveTaxAmount."Calculated Discount Amount", SaleLinePOS."Discount Amount", 'Calculated discount amounts not equal on header and source');

        Assert.AreEqual(POSActiveTaxAmount."Calculated Amount Excl. Tax", SaleLinePOS.Amount, 'Calculated amounts excluding tax are not equal on header and source');
        Assert.AreEqual(SaleLinePOS.Amount, SaleLinePOS."VAT Base Amount", 'Amount and VAT Base Amount are not equal on header and source');
        Assert.AreEqual(POSActiveTaxAmount."Calculated Amount Incl. Tax", SaleLinePOS."Amount Including VAT", 'Calculated amounts including tax are not equal on header and source');
    end;

    local procedure VerifyTaxLineCalcWithLineDiscount(var POSActiveTaxAmountLine: Record "NPR POS Sale Tax Line"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSActiveTaxAmountLine2: Record "NPR POS Sale Tax Line";
    begin
        POSActiveTaxAmountLine2.Copy(POSActiveTaxAmountLine);

        POSActiveTaxAmountLine2.FindSet();
        repeat
            Assert.IsTrue(POSActiveTaxAmountLine."Applied Line Discount", 'Line Disocunt not applied');
            Assert.AreEqual(SaleLinePOS."Discount %", POSActiveTaxAmountLine2."Discount %", 'Active Tax Line Discount % is not equal to source discount %');
            Assert.AreEqual(SaleLinePOS."Discount Amount", POSActiveTaxAmountLine2."Discount Amount", 'Active Tax Line Discount Amount is not equal to source discount amount');
        until POSActiveTaxAmountLine2.Next() = 0;
    end;

    local procedure GetAmountToPay(SaleLinePOS: Record "NPR POS Sale Line"): Decimal
    var
        POSActiveTaxAmount: Record "NPR POS Sale Tax";
        POSActiveTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        AmountToPay: Decimal;
    begin
        POSActiveTaxCalc.Find(POSActiveTaxAmount, SaleLinePOS.SystemId);
        AmountToPay := POSActiveTaxAmount."Calculated Amount Incl. Tax";
        AmountToPay := Round(AmountToPay, 1, '>');
        exit(AmountToPay);
    end;

    procedure UpdatePOSSalesRoundingAcc()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        GLAcc: Record "G/L Account";
    begin
        POSStore.GetProfile(POSPostingProfile);
        GLAcc."No." := POSPostingProfile."POS Sales Rounding Account";
        GLAcc.Find();
        GLAcc."VAT Bus. Posting Group" := '';
        GLAcc."VAT Prod. Posting Group" := '';
        GLAcc."Gen. Bus. Posting Group" := '';
        GLAcc."Gen. Prod. Posting Group" := '';
        GLAcc."Gen. Posting Type" := GLAcc."Gen. Posting Type"::" ";
        GLAcc.Modify();
    end;

    local procedure VerifyPostedTaxCalcCopied2POSEntries(var POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line"; POSEntry: Record "NPR POS Entry")
    begin
        POSPostedTaxAmountLine.CalcSums("Calculated Tax Amount", "Tax Amount");
        Assert.AreEqual(POSPostedTaxAmountLine."Tax Amount", POSEntry."Tax Amount", 'POSPostedTaxAmountLine."Tax Amount" <> POSEntry."Tax Amount"');
        Assert.AreEqual(POSPostedTaxAmountLine."Calculated Tax Amount", POSEntry."Tax Amount", 'POSPostedTaxAmountLine."Calculated Tax Amount" <> POSEntry."Tax Amount"');
    end;

    local procedure VerifyPostedTaxCalcCopied2VATEntries(var POSPostedTaxAmountLine: Record "NPR POS Entry Tax Line"; POSEntry: Record "NPR POS Entry")
    var
        VAtEntry: Record "VAT Entry";
    begin
        VAtEntry.SetRange("Document No.", POSEntry."Document No.");
        VAtEntry.SetRange("Posting Date", POSEntry."Posting Date");
        Assert.IsFalse(VAtEntry.IsEmpty(), 'VAT Entry not created');

        VAtEntry.CalcSums(Amount);
        POSPostedTaxAmountLine.CalcSums("Tax Amount", "Calculated Tax Amount");

        Assert.AreEqual(-POSPostedTaxAmountLine."Tax Amount", VAtEntry.Amount, 'POSPostedTaxAmountLine."Tax Amount" <> VAtEntry.Amount');
        Assert.AreEqual(-POSPostedTaxAmountLine."Calculated Tax Amount", VAtEntry.Amount, 'POSPostedTaxAmountLine."Calculated Tax Amount" <> VAtEntry.Amount');
    end;

    local procedure VerifyVATforGLEntry(POSEntry: Record "NPR POS Entry"; TaxArea: Record "Tax Area")
    var
        GLEntry: Record "G/L Entry";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxAreaLine: Record "Tax Area Line";
        GLSetup: Record "General Ledger Setup";
        POSSalesTax: Codeunit "NPR POS Sales Tax";
    begin
        TaxAreaLine.SetRange("Tax Area", TaxArea.Code);
        TaxAreaLine.FindFirst();
        TaxJurisdiction.Get(TaxAreaLine."Tax Jurisdiction Code");
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", TaxJurisdiction.GetSalesAccount(false));
        GLENtry.CalcSums(Amount);
        GLSetup.get();
        if POSSalesTax.NALocalizationEnabled() then begin
            if GLSetup."Summarize G/L Entries" then
                Assert.AreEqual(4, GLEntry.Count(), 'G/L Entries for Tax Jurisdiction account has not been created')
            else
                Assert.AreEqual(3, GLEntry.Count(), 'G/L Entries for Tax Jurisdiction account has not been created');
        end else begin
            Assert.AreEqual(4, GLEntry.Count(), 'G/L Entries for Tax Jurisdiction account has not been created');
        end;
        POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryTaxLine.CalcSums("Tax Amount");
        Assert.AreEqual(3, POSEntryTaxLine.Count(), 'More then 3 POS Entry Tax Line has been posted');
        Assert.IsTrue(ABS(GLEntry.Amount + POSEntryTaxLine."Tax Amount") <= 0.01, 'GLEntry.Amount <> POSEntryTaxLine."Tax Amount"');
    end;

    local procedure VerifyVATforGLEntryUnliable(POSEntry: Record "NPR POS Entry"; TaxArea: Record "Tax Area")
    var
        GLEntry: Record "G/L Entry";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        TaxJurisdiction: Record "Tax Jurisdiction";
        TaxAreaLine: Record "Tax Area Line";
        GLSetup: Record "General Ledger Setup";
        POSSalesTax: Codeunit "NPR POS Sales Tax";
    begin
        TaxAreaLine.SetRange("Tax Area", TaxArea.Code);
        TaxAreaLine.FindFirst();
        TaxJurisdiction.Get(TaxAreaLine."Tax Jurisdiction Code");
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", TaxJurisdiction.GetSalesAccount(false));
        GLENtry.CalcSums(Amount);
        GLSetup.get();
        if POSSalesTax.NALocalizationEnabled() then begin
            if GLSetup."Summarize G/L Entries" then
                Assert.AreEqual(1, GLEntry.Count(), 'G/L Entries for Tax Jurisdiction account has not been created')
            else
                Assert.AreEqual(0, GLEntry.Count(), 'G/L Entries for Tax Jurisdiction account has not been created');
        end else begin
            Assert.AreEqual(1, GLEntry.Count(), 'G/L Entries for Tax Jurisdiction account has not been created');
        end;
        POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryTaxLine.CalcSums("Tax Amount");
        Assert.AreEqual(3, POSEntryTaxLine.Count(), 'More then 3 POS Entry Tax Line has been posted');
        Assert.AreEqual(0, POSEntryTaxLine."Tax Amount", 'Tax Amount created');
    end;

    local procedure VerifySalesforGLEntry(POSEntry: Record "NPR POS Entry"; Item: array[2] of Record Item; GenBusPostingGroup: Code[20])
    var
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        i: Integer;
    begin
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        if Item[1]."Gen. Prod. Posting Group" = Item[2]."Gen. Prod. Posting Group" then begin
            GeneralPostingSetup.Get(GenBusPostingGroup, Item[1]."Gen. Prod. Posting Group");
            GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
            Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry for Sales account has not been created');
            Assert.AreEqual(POSEntry."Amount Excl. Tax", Abs(GLEntry.Amount), 'POSEntry."Amount Excl. Tax" <> GLEntry.Amount');
            Assert.AreEqual(0, Abs(GLEntry."VAT Amount"), '0 <> GLEntry."VAT Amount"');
        end else begin
            POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
            POSEntrySalesLine.FindSet();
            repeat
                GeneralPostingSetup.Get(GenBusPostingGroup, POSEntrySalesLine."Gen. Prod. Posting Group");
                GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
                Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry for Sales account has not been created');
                Assert.AreEqual(POSEntrySalesLine."Amount Excl. VAT (LCY)", Abs(GLEntry.Amount), 'POSEntrySalesLine."Amount Excl. VAT (LCY)" <> GLEntry.Amount');
                Assert.AreEqual(0, Abs(GLEntry."VAT Amount"), '0 <> GLEntry."VAT Amount"');
            until POSEntrySalesLine.Next() = 0;
        end;
    end;

    local procedure VerifyPostedTaxCalcNotCopied2VATEntries(POSEntry: Record "NPR POS Entry")
    var
        VAtEntry: Record "VAT Entry";
    begin
        VAtEntry.SetRange("Document No.", POSEntry."Document No.");
        VAtEntry.SetRange("Posting Date", POSEntry."Posting Date");
        Assert.IsFalse(VAtEntry.IsEmpty(), 'VAT Entry not created');
        VAtEntry.CalcSums(Amount);
        Assert.AreEqual(0, VAtEntry.Amount, 'VAT Entries posted with vat amount');
    end;

    local procedure UpdateTaxJurisdictionSalesTaxAccounts()
    var
        GLAcc: Record "G/L Account";
        TaxJurisdiction: Record "Tax Jurisdiction";
    begin
        TaxJurisdiction.ModifyAll("Tax Account (Sales)", '');
        TaxJurisdiction.ModifyAll("Unreal. Tax Acc. (Sales)", '');
    end;

    local procedure CreateEmptyTaxPostingSetup()
    var
        TaxPostingSetup: Record "VAT Posting Setup";
    begin
        //we need this to be able to post sale to G/L Entry for Automatic VAT Entry
        //with unknown VAT Amount. VAT Amount later will be posted from POS Entry Tax Lines
        if not TaxPostingSetup.get('', '') then begin
            TaxPostingSetup."VAT Bus. Posting Group" := '';
            TaxPostingSetup."VAT Prod. Posting Group" := '';
            TaxPostingSetup.Init();
            TaxPostingSetup.Insert();
        end;
        TaxPostingSetup."VAT Calculation Type" := TaxPostingSetup."VAT Calculation Type"::"Sales Tax";
        TaxPostingSetup."Tax Category" := 'E';
        TaxPostingSetup.Modify();
    end;
}