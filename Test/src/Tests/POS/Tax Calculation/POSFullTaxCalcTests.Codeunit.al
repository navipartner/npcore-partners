codeunit 85029 "NPR POS Full Tax Calc. Tests"
{
    // // [Feature] POS Active Full Tax Calculation
    Subtype = Test;

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
        POSSession: Codeunit "NPR POS Session";
        LibraryRandom: Codeunit "Library - Random";
        Initialized: Boolean;

    [Test]
    procedure CalculateTaxForwardNotSupportedDirectSale()
    var
        POSViewProfile: Record "NPR POS View Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        // [SCENARIO] POS Tax Amount calculation is terminated for full vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, false);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [WHEN] Add Item to active sale
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [THEN] Expected Error
        asserterror LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalculateTaxBackwardNotSupportedDirectSale()
    var
        POSViewProfile: Record "NPR POS View Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        // [SCENARIO] POS Tax Amount calculation is terminated for full vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup);
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile, true);
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [WHEN] Add Item to active sale
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [THEN] Expected Error
        asserterror LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //Revert
        AssignPOSViewProfileToPOSUnit('');
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalculateTaxForwardNotSupportedDebitSale()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
    begin
        // [SCENARIO] POS Tax Amount calculation is terminated for full vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] POS Pricing Profile
        CreateCustomer(Customer, false);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup);
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [WHEN] Add Item to active sale
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [THEN] Expected Error
        asserterror LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    [Test]
    procedure CalculateTaxBackwardNotSupportedDebitSale()
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select";
    begin
        // [SCENARIO] POS Tax Amount calculation is terminated for full vat

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] POS Pricing Profile
        CreateCustomer(Customer, true);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup);
        Customer."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        // [GIVEN] Customer applied to sale
        SelectCustomerAction.AttachCustomer(POSSession, '', 0, Customer."No.");

        // [WHEN] Add Item to active sale
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", true);
        Item."Unit Price" := LibraryRandom.RandDecInRange(1, 100, 5);
        Item.Modify();

        // [THEN] Expected Error
        asserterror LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //Revert
        AssignVATBusPostGroupToPOSPostingProfile('');
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryTaxCalc: Codeunit "NPR POS Lib. - Tax Calc.";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.Destructor();
            Clear(POSSession);
        end;

        if not Initialized then begin
            LibraryApplicationArea.EnableVATSetup();
            LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            LibraryPOSMasterData.CreatePOSSetup(POSSetup);
            LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);

            DeletePOSPostedEntries();

            Initialized := true;
        end;

        Commit();
    end;

    local procedure DeletePOSPostedEntries()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
    begin
        //Just in case if performance test is created and run on test company for POS test unit
        //then POS posting is terminated because POS entries are stored in database with sales tickect no.
        //defined in the Library POS Master Data 
        POSEntry.DeleteAll();
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
        POSEntryTaxLine.DeleteAll();
        VATEntry.DeleteAll();
        GLEntry.DeleteAll();
    end;

    local procedure CreateCustomer(var Customer: Record Customer; PricesIncludingTax: Boolean)
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomerWithAddress(Customer);
        Customer."Prices Including VAT" := PricesIncludingTax;
        Customer.Modify();
    end;

    local procedure CreatePOSViewProfile(var POSViewProfile: Record "NPR POS View Profile"; PricesIncludingTax: Boolean)
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := PricesIncludingTax;
        POSViewProfile.Modify();
    end;

    local procedure AssignPOSViewProfileToPOSUnit(POSViewProfileCode: Code[20])
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(POSUnit, POSViewProfileCode);
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        LibraryTaxCalc: codeunit "NPR POS Lib. - Tax Calc.";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryTaxCalc.CreateTaxPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code, "TAX Calculation Type"::"Full VAT");
    end;

    local procedure AssignVATBusPostGroupToPOSPostingProfile(VATBusPostingGroupCode: Code[20])
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignVATBusPostGroupToPOSPostingProfile(POSStore, VATBusPostingGroupCode);
    end;

    local procedure CreateItem(var Item: Record Item; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; PricesIncludesVAT: Boolean)
    var
        LibraryTaxCalc: codeunit "NPR POS Lib. - Tax Calc.";
    begin
        LibraryTaxCalc.CreateItem(Item, VATProdPostingGroupCode, VATBusPostingGroupCode);
        Item."Price Includes VAT" := PricesIncludesVAT;
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
}