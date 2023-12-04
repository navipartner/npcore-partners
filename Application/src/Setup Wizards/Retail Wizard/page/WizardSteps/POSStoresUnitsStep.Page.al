page 6150859 "NPR POS Stores & Units Step"
{
    Caption = 'POS Stores and Units';
    Extensible = False;
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(POSStoresUnitsCreate)
            {
                Caption = '';
                InstructionalText = 'In case that the selected Starting No. is taken, the first available No. will be used.';
            }
            group(NoOfPOSStoresToCreateGroup)
            {
                Caption = 'POS Stores';
                field(NoOfPOSStoresToCreate; NoOfPOSStoresToCreate)
                {
                    ApplicationArea = NPRRetail;
                    BlankZero = true;
                    Caption = 'No. of POS Stores to create:';
                    ToolTip = 'Specifies the value of the Number of stores to create:  field';

                    trigger OnValidate()
                    begin
                        NoOfPOSUnitsToCreate := NoOfPOSStoresToCreate;
                        CurrPage.Update(false);
                    end;
                }
            }
            group(StartingNoStoreGroup)
            {
                Caption = '';
                field(StartingNoStore; StartingNoStore)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Starting No.:';
                    ToolTip = 'Specifies the value of the Starting No.:  field';

                    trigger OnValidate()
                    begin
                        StartingNoUnit := StartingNoStore;
                        CurrPage.Update(false);
                    end;
                }
            }
            group(POSStoreDimension1)
            {
                Caption = '';
                field(POSStoreDimension1CodeFld; POSStoreDimension1Code)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Global Dimension 1';
                    CaptionClass = '1,1,1';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
                    ToolTip = 'Specifies the code of the first Global Dimension to be assigned to the POS Store.';
                }
            }
            group(POSStoreDimension2)
            {
                Caption = '';
                field(POSStoreDimension2CodeFld; POSStoreDimension2Code)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Global Dimension 2';
                    CaptionClass = '1,1,2';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
                    ToolTip = 'Specifies the code of the second Global Dimension to be assigned to the POS Store.';
                }
            }
            group(NoOfPOSUnitsToCreateGroup)
            {
                Caption = 'POS Units';
                field(NoOfPOSUnitsToCreate; NoOfPOSUnitsToCreate)
                {
                    ApplicationArea = NPRRetail;
                    BlankZero = true;
                    Caption = 'Number of POS units to create';
                    ShowMandatory = POSUnitsMandatory;

                    ToolTip = 'Specifies the value of the Number of POS units to create.';

                    trigger OnValidate()
                    var
                        POSUnitErrorLbl: Label 'Minimum number of POS units to create must be equal or greater then %1, because you have created %1 Pos Stores.';
                    begin
                        if NoOfPOSUnitsToCreate < NoOfPOSStoresToCreate then
                            error(POSUnitErrorLbl, NoOfPOSStoresToCreate);
                        CurrPage.Update(false);
                    end;
                }
            }
            group(StartingNoUnitGroup)
            {
                Caption = '';
                field(StartingNoUnitField; StartingNoUnit)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Starting No.';
                    ShowMandatory = POSUnitsMandatory;

                    ToolTip = 'Specifies the value of the Starting No. field';
                }
            }

            group(POSUnitDimension1)
            {
                Caption = '';
                field(POSUnitDimension1CodeFld; POSUnitDimension1Code)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Global Dimension 1';
                    CaptionClass = '1,1,1';
                    ShowMandatory = POSUnitsMandatory;
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
                    ToolTip = 'Specifies the code of the first Global Dimension to be assigned to the POS Unit.';
                }
            }
            group(POSUnitDimension2)
            {
                Caption = '';
                field(POSUnitDimension2CodeFld; POSUnitDimension2Code)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Global Dimension 2';
                    CaptionClass = '1,1,2';
                    ShowMandatory = POSUnitsMandatory;
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
                    ToolTip = 'Specifies the code of the second Global Dimension to be assigned to the POS Unit.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        POSUnitsMandatory := ((not TempPOSStore_.IsEmpty) and (TempPOSUnit_.IsEmpty));
    end;

    var
        CompanyInfo: Record "Company Information";
        TempPOSStore_: Record "NPR POS Store" temporary;
        TempPOSUnit_: Record "NPR POS Unit" temporary;
        NoOfPOSStoresToCreate: Integer;
        NoOfPOSUnitsToCreate: Integer;
        StartingNoStore: Code[10];
        StartingNoUnit: Code[10];
        POSUnitsMandatory: Boolean;
        POSUnitDimension1Code: Code[20];
        POSUnitDimension2Code: Code[20];
        POSStoreDimension1Code: Code[20];
        POSStoreDimension2Code: Code[20];

    internal procedure CreateTempPOSStores()
    var
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
        i: Integer;
        LastNoUsed: Code[10];
    begin
        CompanyInfo.Get();
        TempPOSStore_.DeleteAll();

        TempPOSStore_.Reset();
        LastNoUsed := StartingNoStore;

        for i := 1 to NoOfPOSStoresToCreate do begin
            TempPOSStore_.Init();
            LastNoUsed := CheckIfNoAvailableInPOSStore(POSStore, LastNoUsed);
            LastNoUsed := CheckIfNoAvailableInPOSStore(TempPOSStore_, LastNoUsed);
            TempPOSStore_.Code := LastNoUsed;
            TempPOSStore_."Global Dimension 1 Code" := POSStoreDimension1Code;
            TempPOSStore_."Global Dimension 2 Code" := POSStoreDimension2Code;

            FillAddressFromCompInfo(TempPOSStore_);

            if POSPostingProfile.Get('DEFAULT') then
                TempPOSStore_."POS Posting Profile" := POSPostingProfile.Code;
            TempPOSStore_.Insert();

            if i = 1 then
                HelperFunctions.FormatCode(LastNoUsed, true)
            else
                LastNoUsed := IncStr(LastNoUsed);
        end;
    end;

    local procedure FillAddressFromCompInfo(var PosStore: record "NPR POS Store")
    begin
        PosStore.Validate(Name, CopyStr(CompanyInfo.Name, 1, MaxStrLen(PosStore.Name)));
        PosStore.Validate("Name 2", CompanyInfo."Name 2");
        PosStore.Validate(Address, CopyStr(CompanyInfo.Address, 1, MaxStrLen(PosStore.Address)));
        PosStore.Validate("Address 2", CompanyInfo."Address 2");
        PosStore.Validate("Post Code", CompanyInfo."Post Code");
        PosStore.Validate(City, CompanyInfo.City);
        PosStore.Validate("Country/Region Code", CompanyInfo."Country/Region Code");
        PosStore.Validate("Registration No.", CompanyInfo."Registration No.");
        PosStore.Validate("VAT Registration No.", CompanyInfo."VAT Registration No.");
        PosStore.Validate("Location Code", CompanyInfo."Location Code");
        POSStore.Validate("Phone No.", CompanyInfo."Phone No.");
        PosStore.Validate("E-Mail", CompanyInfo."E-Mail");
        PosStore.Validate("Home Page", CompanyInfo."Home Page");
        PosStore.Validate("Responsibility Center", CompanyInfo."Responsibility Center");
    end;

    local procedure CheckIfNoAvailableInPOSStore(var POSStore: Record "NPR POS Store"; var WantedStartingNo: Code[10]) CalculatedNo: Code[10]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        if POSStore.Get(WantedStartingNo) then begin
            HelperFunctions.FormatCode(WantedStartingNo, true);
            CalculatedNo := CheckIfNoAvailableInPOSStore(POSStore, WantedStartingNo);
        end;
    end;

    internal procedure CreateTempPOSUnits()
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSViewProfile: Record "NPR POS View Profile";
        POSEodProfile: Record "NPR POS End of Day Profile";
        POSInputBoxSalesProfile: Record "NPR Ean Box Setup";
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
        i: Integer;
        LastNoUsed: Code[10];
        POSStoreCode: Code[10];
        POSUnitNameLbl: Label 'POS Unit %1';
    begin
        TempPOSUnit_.DeleteAll();
        TempPOSUnit_.Reset();

        if TempPOSStore_.FindFirst() then
            POSStoreCode := TempPOSStore_.Code;

        LastNoUsed := StartingNoUnit;

        for i := 1 to NoOfPOSUnitsToCreate do begin
            TempPOSUnit_.Init();
            LastNoUsed := CheckIfNoAvailableInPOSUnit(POSUnit, LastNoUsed);
            LastNoUsed := CheckIfNoAvailableInPOSUnit(TempPOSUnit_, LastNoUsed);
            TempPOSUnit_."No." := LastNoUsed;
            TempPOSUnit_.Name := StrSubstNo(POSUnitNameLbl, TempPOSUnit_."No.");
            TempPOSUnit_."POS Store Code" := POSStoreCode;
            TempPOSUnit_."Default POS Payment Bin" := LastNoUsed;
            TempPOSUnit_."POS Layout Code" := 'DEFAULT';
            TempPOSUnit_."Global Dimension 1 Code" := POSUnitDimension1Code;
            TempPOSUnit_."Global Dimension 2 Code" := POSUnitDimension2Code;

            if POSAuditProfile.Get('DEFAULT') then
                TempPOSUnit_."POS Audit Profile" := POSAuditProfile.Code;

            if POSViewProfile.Get('DEFAULT') then
                TempPOSUnit_."POS View Profile" := POSViewProfile.Code;

            if POSEodProfile.Get('DEFAULT') then
                TempPOSUnit_."POS End of Day Profile" := POSEodProfile.Code;

            if POSInputBoxSalesProfile.Get('SALE') then
                TempPOSUnit_."Ean Box Sales Setup" := POSInputBoxSalesProfile.Code;

            TempPOSUnit_.Insert();

            if i = 1 then
                HelperFunctions.FormatCode(LastNoUsed, true)
            else
                LastNoUsed := IncStr(LastNoUsed);

            if TempPOSStore_.Next() > 0 then
                POSStoreCode := TempPOSStore_.Code;
        end;
    end;

    internal procedure CreateDefaultLayout()
    var
        POSLayout: Record "NPR POS Layout";
    begin
        if not POSLayout.Get('DEFAULT') then begin
            POSLayout.Init();
            POSLayout.Code := 'DEFAULT';
            POSLayout.Description := 'Default POS Layout';
            POSLayout.Insert();
        end
    end;

    local procedure CheckIfNoAvailableInPOSUnit(var POSUnit: Record "NPR POS Unit"; var WantedStartingNo: Code[10]) CalculatedNo: Code[10]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        if POSUnit.Get(WantedStartingNo) then begin
            HelperFunctions.FormatCode(WantedStartingNo, false);
            HelperFunctions.FormatCode(WantedStartingNo, true);
            CalculatedNo := CheckIfNoAvailableInPOSUnit(POSUnit, WantedStartingNo);
        end;
    end;

    internal procedure CreateTempPOSPaymentBin(var POSPaymentBin: Record "NPR POS Payment Bin"; var POSUnit: Record "NPR POS Unit")
    var
        DescriptionLbl: Label 'Cash Drawer %1';
    begin
        POSPaymentBin.DeleteAll();

        if POSUnit.FindSet() then
            repeat
                POSPaymentBin.Init();
                POSPaymentBin."No." := POSUnit."No.";
                POSPaymentBin.Description := StrSubstNo(DescriptionLbl, POSUnit."No.");
                POSPaymentBin."POS Store Code" := POSUnit."POS Store Code";
                POSPaymentBin."Attached to POS Unit No." := POSUnit."No.";
                POSPaymentBin."Eject Method" := 'PRINTER';
                POSPaymentBin."Bin Type" := POSPaymentBin."Bin Type"::CASH_DRAWER;
                POSPaymentBin.Status := POSPaymentBin.Status::CLOSED;
                if not POSPaymentBin.Insert() then
                    POSPaymentBin.Modify();
            until POSUnit.Next() = 0;
    end;

    internal procedure CopyTempStores(var TempPOSStore: Record "NPR POS Store")
    begin
        TempPOSStore.DeleteAll();
        if TempPOSStore_.FindSet() then
            repeat
                TempPOSStore := TempPOSStore_;
                TempPOSStore.Insert();
            until TempPOSStore_.Next() = 0;
    end;

    internal procedure CopyTempUnits(var TempPOSUnit: Record "NPR POS Unit")
    begin
        TempPOSUnit.DeleteAll();
        if TempPOSUnit_.FindSet() then
            repeat
                TempPOSUnit := TempPOSUnit_;
                TempPOSUnit.Insert();
            until TempPOSUnit_.Next() = 0;
    end;

    internal procedure POSStoresToCreate(): Boolean
    begin
        exit(TempPOSStore_.FindSet());
    end;

    internal procedure POSUnitsToCreate(): Boolean
    begin
        exit(TempPOSUnit_.FindSet());
    end;

    internal procedure GetPOSUnitDimensionCodes(var Dimension1Code: Code[20]; var Dimension2Code: Code[20])
    begin
        Dimension1Code := POSUnitDimension1Code;
        Dimension2Code := POSUnitDimension2Code;
    end;

    internal procedure GetPOSStoreDimensionCodes(var Dimension1Code: Code[20]; var Dimension2Code: Code[20])
    begin
        Dimension1Code := POSStoreDimension1Code;
        Dimension2Code := POSStoreDimension2Code;
    end;
}
