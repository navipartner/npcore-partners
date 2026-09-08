codeunit 85037 "NPR Test Fixture"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        EnsureFixtureData();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Test Initialize", 'OnBeforeTestSuiteInitialize', '', false, false)]
    local procedure OnBeforeTestSuiteInitialize(CallerCodeunitID: Integer)
    begin
        EnsureFixtureData();
        GlobalLanguage(1033); // standard tests are expected to run with application language set to ENU, but some switch to local language if available
    end;

    local procedure EnsureFixtureData()
    var
        LibraryUtility: Codeunit "Library - Utility";
        NoSeriesCode: Code[20];
    begin
        NoSeriesCode := LibraryUtility.GetGlobalNoSeriesCode();
        EnsureSalesSetup(NoSeriesCode);
        EnsurePurchasesSetup(NoSeriesCode);
        EnsureInventorySetup(NoSeriesCode);
        EnsureAssemblySetup(NoSeriesCode);
        EnsureMarketingSetup(NoSeriesCode);
        EnsureCompanyInformation();
        EnsureGeneralLedgerSetup();
        EnsureGeneralPostingSetup();
        EnsureCountryRegion();
        EnsureCurrency();
        EnsureLanguage();
        EnsureCustomer();
        EnsureSalespersonPurchaser();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Test Initialize", 'OnAfterTestSuiteInitialize', '', false, false)]
    local procedure OnAfterTestSuiteInitialize(CallerCodeunitID: Integer)
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Test Initialize", 'OnTestInitialize', '', false, false)]
    local procedure OnTestInitialize(CallerCodeunitID: Integer)
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if SalesSetup.Get() then begin
            SalesSetup.Validate("Discount Posting", SalesSetup."Discount Posting"::"All Discounts");
            SalesSetup.Modify();
        end;
    end;

    local procedure EnsureSalesSetup(NoSeriesCode: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        SalesSetup: Record "Sales & Receivables Setup";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        if not SalesSetup.Get() then begin
            SalesSetup.Init();
            SalesSetup.Insert();
        end;

        if SalesSetup."Customer Nos." = '' then
            SalesSetup."Customer Nos." := NoSeriesCode;
        if SalesSetup."Quote Nos." = '' then
            SalesSetup."Quote Nos." := NoSeriesCode;
        if SalesSetup."Order Nos." = '' then begin
            LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
            LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'SO00000001', 'SO99999999');
            SalesSetup."Order Nos." := NoSeries.Code;
        end;
        if SalesSetup."Invoice Nos." = '' then
            SalesSetup."Invoice Nos." := NoSeriesCode;
        if SalesSetup."Posted Invoice Nos." = '' then
            SalesSetup."Posted Invoice Nos." := NoSeriesCode;
        if SalesSetup."Credit Memo Nos." = '' then
            SalesSetup."Credit Memo Nos." := NoSeriesCode;
        if SalesSetup."Posted Credit Memo Nos." = '' then begin
            Clear(NoSeries);
            Clear(NoSeriesLine);
            LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
            LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'SCM00000001', 'SCM99999999');
            SalesSetup."Posted Credit Memo Nos." := NoSeries.Code;
        end;
        if SalesSetup."Posted Shipment Nos." = '' then
            SalesSetup."Posted Shipment Nos." := NoSeriesCode;
        if SalesSetup."Blanket Order Nos." = '' then
            SalesSetup."Blanket Order Nos." := NoSeriesCode;
        if SalesSetup."Return Order Nos." = '' then
            SalesSetup."Return Order Nos." := NoSeriesCode;
        if SalesSetup."Posted Return Receipt Nos." = '' then begin
            Clear(NoSeries);
            Clear(NoSeriesLine);
            LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
            LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'SRR00000001', 'SRR99999999');
            SalesSetup."Posted Return Receipt Nos." := NoSeries.Code;
        end;

        SalesSetup.Modify();
    end;

    local procedure EnsurePurchasesSetup(NoSeriesCode: Code[20])
    var
        PurchasesSetup: Record "Purchases & Payables Setup";
    begin
        if not PurchasesSetup.Get() then begin
            PurchasesSetup.Init();
            PurchasesSetup.Insert();
        end;

        if PurchasesSetup."Vendor Nos." = '' then
            PurchasesSetup."Vendor Nos." := NoSeriesCode;
        if PurchasesSetup."Quote Nos." = '' then
            PurchasesSetup."Quote Nos." := NoSeriesCode;
        if PurchasesSetup."Order Nos." = '' then
            PurchasesSetup."Order Nos." := NoSeriesCode;
        if PurchasesSetup."Invoice Nos." = '' then
            PurchasesSetup."Invoice Nos." := NoSeriesCode;
        if PurchasesSetup."Posted Invoice Nos." = '' then
            PurchasesSetup."Posted Invoice Nos." := NoSeriesCode;
        if PurchasesSetup."Credit Memo Nos." = '' then
            PurchasesSetup."Credit Memo Nos." := NoSeriesCode;
        if PurchasesSetup."Posted Credit Memo Nos." = '' then
            PurchasesSetup."Posted Credit Memo Nos." := NoSeriesCode;
        if PurchasesSetup."Posted Receipt Nos." = '' then
            PurchasesSetup."Posted Receipt Nos." := NoSeriesCode;
        if PurchasesSetup."Blanket Order Nos." = '' then
            PurchasesSetup."Blanket Order Nos." := NoSeriesCode;
        if PurchasesSetup."Return Order Nos." = '' then
            PurchasesSetup."Return Order Nos." := NoSeriesCode;
        if PurchasesSetup."Posted Return Shpt. Nos." = '' then
            PurchasesSetup."Posted Return Shpt. Nos." := NoSeriesCode;

        PurchasesSetup.Modify();
    end;

    local procedure EnsureInventorySetup(NoSeriesCode: Code[20])
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if not InventorySetup.Get() then begin
            InventorySetup.Init();
            InventorySetup.Insert();
        end;

        if InventorySetup."Item Nos." = '' then
            InventorySetup."Item Nos." := NoSeriesCode;
        if InventorySetup."Transfer Order Nos." = '' then
            InventorySetup."Transfer Order Nos." := NoSeriesCode;
        if InventorySetup."Posted Transfer Shpt. Nos." = '' then
            InventorySetup."Posted Transfer Shpt. Nos." := NoSeriesCode;
        if InventorySetup."Posted Transfer Rcpt. Nos." = '' then
            InventorySetup."Posted Transfer Rcpt. Nos." := NoSeriesCode;

        InventorySetup.Modify();
    end;

    local procedure EnsureAssemblySetup(NoSeriesCode: Code[20])
    var
        AssemblySetup: Record "Assembly Setup";
        AssemblySetupModified: Boolean;
    begin
        if not AssemblySetup.Get() then begin
            AssemblySetup.Init();
            AssemblySetup.Insert();
        end;

        if AssemblySetup."Assembly Order Nos." = '' then begin
            AssemblySetup."Assembly Order Nos." := NoSeriesCode;
            AssemblySetupModified := true;
        end;
        if AssemblySetup."Posted Assembly Order Nos." = '' then begin
            AssemblySetup."Posted Assembly Order Nos." := NoSeriesCode;
            AssemblySetupModified := true;
        end;
        if AssemblySetupModified then
            AssemblySetup.Modify();
    end;

    local procedure EnsureMarketingSetup(NoSeriesCode: Code[20])
    var
        BusinessRelation: Record "Business Relation";
        MarketingSetup: Record "Marketing Setup";
        CustomerBusRelCodeLbl: Label 'CUST', Locked = true;
        CustomerBusRelDescriptionLbl: Label 'Customer', Locked = true;
        MarketingSetupModified: Boolean;
    begin
        if not MarketingSetup.Get() then begin
            MarketingSetup.Init();
            MarketingSetup.Insert();
        end;

        if MarketingSetup."Contact Nos." = '' then begin
            MarketingSetup."Contact Nos." := NoSeriesCode;
            MarketingSetupModified := true;
        end;
        // Blank means the Base App customer <-> contact sync (CustCont-Update) is off. CRONUS always has it
        // configured, and member -> customer name propagation behaves differently without it.
        if MarketingSetup."Bus. Rel. Code for Customers" = '' then begin
            if not BusinessRelation.Get(CustomerBusRelCodeLbl) then begin
                BusinessRelation.Init();
                BusinessRelation.Code := CustomerBusRelCodeLbl;
                BusinessRelation.Description := CustomerBusRelDescriptionLbl;
                BusinessRelation.Insert();
            end;
            MarketingSetup."Bus. Rel. Code for Customers" := BusinessRelation.Code;
            MarketingSetupModified := true;
        end;
        if MarketingSetupModified then
            MarketingSetup.Modify();
    end;

    local procedure EnsureCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        CompanyNameLbl: Label 'My Company', Locked = true;
        CompanyVatRegistrationNoLbl: Label 'ZZVAT', Locked = true;
        CompanyInformationModified: Boolean;
    begin
        if not CompanyInformation.Get() then begin
            CompanyInformation.Init();
            CompanyInformation.Insert();
        end;

        if CompanyInformation.Name = '' then begin
            CompanyInformation.Name := CompanyNameLbl;
            CompanyInformationModified := true;
        end;
        if CompanyInformation."VAT Registration No." = '' then begin
            CompanyInformation."VAT Registration No." := CompanyVatRegistrationNoLbl;
            CompanyInformationModified := true;
        end;
        if CompanyInformationModified then
            CompanyInformation.Modify();
    end;

    local procedure EnsureGeneralLedgerSetup()
    var
        Dimension: Record Dimension;
        GeneralLedgerSetup: Record "General Ledger Setup";
        GlobalDimension1CodeLbl: Label 'ZZDIM1', Locked = true;
        LcyCodeLbl: Label 'ZZLCY', Locked = true;
    begin
        if not GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup.Init();
            GeneralLedgerSetup.Insert();
        end;

        if GeneralLedgerSetup."LCY Code" = '' then begin
            GeneralLedgerSetup."LCY Code" := LcyCodeLbl;
            GeneralLedgerSetup.Modify();
        end;

        if GeneralLedgerSetup."Global Dimension 1 Code" = '' then begin
            if not Dimension.Get(GlobalDimension1CodeLbl) then begin
                Dimension.Init();
                Dimension.Code := GlobalDimension1CodeLbl;
                Dimension.Name := GlobalDimension1CodeLbl;
                Dimension.Insert();
            end;

            GeneralLedgerSetup.Validate("Global Dimension 1 Code", Dimension.Code);
            GeneralLedgerSetup.Modify();
        end;
    end;

    local procedure EnsureCountryRegion()
    begin
        EnsureCountryRegion('DK', 'Denmark');
        EnsureCountryRegion('RS', 'Serbia');
    end;

    local procedure EnsureCountryRegion(CountryRegionCode: Code[10]; CountryRegionName: Text[50])
    var
        CountryRegion: Record "Country/Region";
    begin
        if CountryRegion.Get(CountryRegionCode) then
            exit;

        CountryRegion.Init();
        CountryRegion.Code := CountryRegionCode;
        CountryRegion.Name := CountryRegionName;
        CountryRegion.Insert();
    end;

    local procedure EnsureGeneralPostingSetup()
    var
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
    begin
        GeneralPostingSetup.SetFilter("Gen. Bus. Posting Group", '<>%1', '');
        GeneralPostingSetup.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
        GeneralPostingSetup.SetFilter("Sales Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("Sales Line Disc. Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("Purch. Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("COGS Account", '<>%1', '');
        GeneralPostingSetup.SetFilter("Inventory Adjmt. Account", '<>%1', '');
        if GeneralPostingSetup.FindFirst() then
            exit;

        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);
        LibraryERM.SetGeneralPostingSetupSalesAccounts(GeneralPostingSetup);
        GeneralPostingSetup.Modify(true);
    end;

    local procedure EnsureCurrency()
    var
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if not Currency.Get('EUR') then begin
            Currency.Init();
            Currency.Code := 'EUR';
            Currency.Insert();
            Currency.InitRoundingPrecision();
            Currency.Modify();
        end;

        if not CurrencyExchangeRate.Get('EUR', 0D) then
            LibraryERM.CreateExchangeRate('EUR', 0D, 1, 1);
    end;

    local procedure EnsureLanguage()
    var
        Language: Record Language;
    begin
        if Language.Get('ENU') then
            exit;

        Language.Init();
        Language.Code := 'ENU';
        Language.Name := 'English (United States)';
        Language."Windows Language ID" := 1033;
        Language.Insert();
    end;

    local procedure EnsureCustomer()
    var
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
    begin
        if Customer.IsEmpty() then
            LibrarySales.CreateCustomer(Customer);
    end;

    local procedure EnsureSalespersonPurchaser()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        LibrarySales: Codeunit "Library - Sales";
    begin
        if SalespersonPurchaser.IsEmpty() then
            LibrarySales.CreateSalesperson(SalespersonPurchaser);
    end;
}
