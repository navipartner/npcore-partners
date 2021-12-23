codeunit 85028 "NPR POS Lib. - Tax Calc."
{
    var
        LibraryUtility: Codeunit "Library - Utility";

    procedure BindNormalTaxCalcTest()
    var
        POSNormalTaxCalcTest: codeunit "NPR POS Normal Tax Calc. Tests";
    begin
        BindSubscription(POSNormalTaxCalcTest);
    end;

    procedure BindSalesTaxCalcTest()
    var
        POSSalesTaxCalcTest: codeunit "NPR POS Sales Tax Calc. Tests";
    begin
        BindSubscription(POSSalesTaxCalcTest);
    end;

    local procedure CreateTaxJurisdiction(NewJurisdictionCode: Code[10])
    var
        TaxJurisdiction: Record "Tax Jurisdiction";
    begin
        if NewJurisdictionCode = '' then
            NewJurisdictionCode := LibraryUtility.GenerateRandomCode(TaxJurisdiction.FieldNo(Code), Database::"Tax Jurisdiction");
        TaxJurisdiction.CreateTaxJurisdiction(NewJurisdictionCode);
        TaxJurisdiction.Validate("Report-to Jurisdiction", TaxJurisdiction.Code);
        TaxJurisdiction.Modify();
    end;

    procedure TaxJurisdictionCalculateTaxOnTax(var TaxJurisdiction: Record "Tax Jurisdiction")
    begin
        TaxJurisdiction.Validate("Calculate Tax on Tax", true);
        TaxJurisdiction.Modify()
    end;

    procedure CreateTaxGroup(var TaxGroup: Record "Tax Group")
    begin
        TaxGroup.CreateTaxGroup(LibraryUtility.GenerateRandomCode(TaxGroup.FieldNo(Code), Database::"Tax Group"));
    end;

    procedure CreateTaxSetup()
    var
        TaxSetup: Record "Tax Setup";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if not TaxSetup.Get() then begin
            TaxSetup.Init();
            TaxSetup.Insert();
        end;
        TaxSetup."Auto. Create Tax Details" := true;
        TaxSetup."Non-Taxable Tax Group Code" := '';
        TaxSetup."Tax Account (Sales)" := LibraryERM.CreateGLAccountNo();
        TaxSetup."Tax Account (Purchases)" := LibraryERM.CreateGLAccountNo();
        TaxSetup."Reverse Charge (Purchases)" := TaxSetup."Tax Account (Sales)";
        TaxSetup.Modify();
    end;

    procedure CreateTaxArea(var TaxArea: Record "Tax Area"; Levels: Integer; TaxCountry: Integer)
    var
        TaxJurisdiction: Record "Tax Jurisdiction";
        i: Integer;
    begin
        TaxArea.CreateTaxArea(LibraryUtility.GenerateRandomCode(TaxArea.FieldNo(Code), Database::"Tax Area"), '', '');
        if IsUSLocalizationEnabled() then begin
            UpdateTaxAreaCountryRegion(TaxArea, TaxCountry);
        end;
        if Levels = 0 then
            exit;
        for i := 1 to Levels do begin
            CreateTaxAreaLine(TaxArea, LibraryUtility.GenerateRandomCode(TaxJurisdiction.FieldNo(Code), Database::"Tax Jurisdiction"))
        end;
    end;

    procedure CreateTaxAreaLine(TaxArea: Record "Tax Area"; NewJurisdictionCode: Code[10])
    var
        TaxAreaLine: Record "Tax Area Line";
    begin
        if TaxAreaLine.Get(TaxArea.Code, NewJurisdictionCode) then
            exit;
        TaxAreaLine.Init();
        TaxAreaLine."Tax Area" := TaxArea.Code;
        TaxAreaLine."Tax Jurisdiction Code" := NewJurisdictionCode;
        TaxAreaLine.Insert();
        CreateTaxJurisdiction(NewJurisdictionCode);
    end;

    procedure CreateTaxDetail(var TaxDetail: Record "Tax Detail"; TaxAreaCode: Code[20]; TaxGroupCode: Code[20]; CityRate: Decimal; CountyRate: Decimal; StateRate: Decimal)
    begin
        TaxDetail.SetSalesTaxRateDetailed(TaxAreaCode, TaxGroupCode, CityRate, CountyRate, StateRate, Today());
    end;

    procedure UpdateTaxDetailAboveMaximum(var TaxDetail: Record "Tax Detail"; MaxAmtQty: Decimal; TaxAboveMax: Decimal)
    begin
        TaxDetail."Maximum Amount/Qty." := MaxAmtQty;
        TaxDetail."Tax Above Maximum" := TaxAboveMax;
        TaxDetail.Modify();
    end;

    procedure UpdateTaxJurisdictionSalesAccounts()
    var
        TaxJurisdiction: Record "Tax Jurisdiction";
        LibraryERM: Codeunit "Library - ERM";
    begin
        TaxJurisdiction.ModifyAll("Tax Account (Sales)", LibraryERM.CreateGLAccountNo());
        TaxJurisdiction.ModifyAll("Unreal. Tax Acc. (Sales)", LibraryERM.CreateGLAccountNo());
    end;

    procedure IsUSLocalizationEnabled(): Boolean
    var
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FieldReference: FieldRef;
    begin
        RecRef.Open(Database::"Tax Area");
        exit(DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'Country/Region'));
    end;

    local procedure UpdateTaxAreaCountryRegion(var TaxArea: Record "Tax Area"; TaxCountry: Integer)
    var
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FieldReference: FieldRef;
    begin
        DataTypeMgt.GetRecordRef(TaxArea, RecRef);
        DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'Country/Region');
        FieldReference.Value := TaxCountry;
        RecRef.Modify();
        RecRef.SetTable(TaxArea);
    end;

    procedure CreateTaxPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; TaxCalculationType: Enum "Tax Calculation Type")
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
    begin
        if VATPostingSetup.Get(VATBusPostingGroupCode, VATProdPostingGroupCode) then
            exit;

        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusPostingGroupCode, VATProdPostingGroupCode);
        VATPostingSetup."VAT %" := LibraryRandom.RandIntInRange(5, 95);
        VATPostingSetup."VAT Calculation Type" := TaxCalculationType;
        VATPostingSetup.Validate("VAT Identifier",
          LibraryUtility.GenerateRandomCode(VATPostingSetup.FieldNo("VAT Identifier"), DATABASE::"VAT Posting Setup"));
        VATPostingSetup.Validate("Sales VAT Account", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Validate("Purchase VAT Account", LibraryERM.CreateGLAccountNo());
        VATPostingSetup.Validate("Tax Category", 'S');
        VATPostingSetup.Modify();
    end;

    procedure CreateSalesTaxPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; TaxCalculationType: Enum "Tax Calculation Type")
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
    begin
        if VATPostingSetup.Get(VATBusPostingGroupCode, VATProdPostingGroupCode) then
            exit;

        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusPostingGroupCode, VATProdPostingGroupCode);
        VATPostingSetup."VAT %" := LibraryRandom.RandIntInRange(5, 95);
        VATPostingSetup."VAT Calculation Type" := TaxCalculationType;
        VATPostingSetup.Validate("VAT Identifier",
          LibraryUtility.GenerateRandomCode(VATPostingSetup.FieldNo("VAT Identifier"), DATABASE::"VAT Posting Setup"));
        VATPostingSetup.Validate("Tax Category", 'S');
        VATPostingSetup.Modify();
    end;

    procedure CreateItem(var Item: Record Item; VATProdPostingGroupCode: Code[20]; VATBusPostingGroupCode: Code[20])
    var
        NPRLibraryInventory: Codeunit "NPR Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        NPRLibraryInventory.CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATProdPostingGroupCode);
        Item.Validate("VAT Bus. Posting Gr. (Price)", VATBusPostingGroupCode);

        Item."Unit Price" := LibraryRandom.RandDec(1000, 2) + 1; //more than 1
        Item."Unit Cost" := LibraryRandom.RandDecInDecimalRange(0.01, Item."Unit Price", 1);
        Item.Modify;
    end;
}