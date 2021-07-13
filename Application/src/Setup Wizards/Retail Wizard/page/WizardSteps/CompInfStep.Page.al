page 6014652 "NPR Comp. Inf. Step"
{
    Caption = 'Company Information';
    DeleteAllowed = false;
    PageType = CardPart;
    SourceTable = "Company Information";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Name; Rec.Name)
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the company''s name and corporate form. For example, Inc. or Ltd.';
                    ApplicationArea = NPRRetail;
                }
                field(Address; Rec.Address)
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the company''s address.';
                    ApplicationArea = NPRRetail;
                }
                field("Address 2"; Rec."Address 2")
                {

                    ToolTip = 'Specifies additional address information.';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the company''s city.';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PostCode: Record "Post Code";
                        PostCodeList: Page "Post Codes";
                    begin
                        PostCodeList.LookupMode := true;

                        if (Rec."Post Code" <> '') and (Rec.City <> '') then
                            if PostCode.Get(Rec."Post Code", Rec.City) then
                                PostCodeList.SetRecord(PostCode);

                        if PostCodeList.RunModal() = Action::LookupOK then begin
                            PostCodeList.GetRecord(PostCode);
                            Rec."Post Code" := PostCode.Code;
                            Rec.City := PostCode.City;
                            Rec."Country/Region Code" := PostCode."Country/Region Code";
                        end;
                    end;
                }
                field(County; Rec.County)
                {

                    ToolTip = 'Specifies the state, province or county of the company''s address.';
                    Visible = CountyVisible;
                    ApplicationArea = NPRRetail;
                }
                field("Post Code"; Rec."Post Code")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the postal code.';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PostCode: Record "Post Code";
                        PostCodeList: Page "Post Codes";
                    begin
                        PostCodeList.LookupMode := true;

                        if (Rec."Post Code" <> '') and (Rec.City <> '') then
                            if PostCode.Get(Rec."Post Code", Rec.City) then
                                PostCodeList.SetRecord(PostCode);

                        if PostCodeList.RunModal() = Action::LookupOK then begin
                            PostCodeList.GetRecord(PostCode);
                            Rec."Post Code" := PostCode.Code;
                            Rec.City := PostCode.City;
                        end;
                    end;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the country/region of the address.';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CountryRegion: Record "Country/Region";
                        CountriesRegions: Page "Countries/Regions";
                    begin
                        CountriesRegions.LookupMode := true;

                        if Rec."Country/Region Code" <> '' then
                            if CountryRegion.Get(Rec."Country/Region Code") then
                                CountriesRegions.SetRecord(CountryRegion);

                        if CountriesRegions.RunModal() = Action::LookupOK then begin
                            CountriesRegions.GetRecord(CountryRegion);
                            Rec."Country/Region Code" := CountryRegion.Code;
                        end;
                    end;
                }
                field("Phone No."; Rec."Phone No.")
                {

                    ToolTip = 'Specifies the company''s telephone number.';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {

                    ToolTip = 'Specifies the company''s VAT registration number.';
                    ApplicationArea = NPRRetail;
                }
                field(GLN; Rec.GLN)
                {

                    ToolTip = 'Specifies your company in connection with electronic document exchange.';
                    ApplicationArea = NPRRetail;
                }
                field("Industrial Classification"; Rec."Industrial Classification")
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the company''s industrial classification code.';
                    ApplicationArea = NPRRetail;
                }
                group(Separator1)
                {
                    Caption = '';
                    InstructionalText = ' ';
                }
            }
            group(Separator2)
            {
                Caption = '';
                InstructionalText = ' ';
            }
            group(Payments)
            {
                Caption = 'Payments';
                field("Bank Name"; Rec."Bank Name")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the bank the company uses.';
                    ApplicationArea = NPRRetail;
                }
                field("Bank Branch No."; Rec."Bank Branch No.")
                {

                    ShowMandatory = IBANMissing;
                    ToolTip = 'Specifies the bank''s branch number.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetShowMandatoryConditions();
                    end;
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {

                    ShowMandatory = IBANMissing;
                    ToolTip = 'Specifies the company''s bank account number.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetShowMandatoryConditions();
                    end;
                }
                field("Giro No."; Rec."Giro No.")
                {

                    ToolTip = 'Specifies the company''s giro number.';
                    ApplicationArea = NPRRetail;
                }
                field("SWIFT Code"; Rec."SWIFT Code")
                {

                    ToolTip = 'Specifies the SWIFT code (international bank identifier code) of your primary bank.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetShowMandatoryConditions();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SWIFTCode: Record "SWIFT Code";
                        SWIFTCodes: Page "SWIFT Codes";
                    begin
                        SWIFTCodes.LookupMode := true;

                        if Rec."SWIFT Code" <> '' then
                            if SWIFTCode.Get(Rec."SWIFT Code") then
                                SWIFTCodes.SetRecord(SWIFTCode);

                        if SWIFTCodes.RunModal() = Action::LookupOK then begin
                            SWIFTCodes.GetRecord(SWIFTCode);
                            Rec."SWIFT Code" := SWIFTCode.Code;
                        end;
                    end;
                }
                field(IBAN; Rec.IBAN)
                {

                    ShowMandatory = BankBranchNoOrAccountNoMissing;
                    ToolTip = 'Specifies the international bank account number of your primary bank account.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetShowMandatoryConditions();
                    end;
                }
            }
        }
    }

    trigger OnInit()
    begin
        SetShowMandatoryConditions();
    end;

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    var
        IBANMissing: Boolean;
        BankBranchNoOrAccountNoMissing: Boolean;
        CountyVisible: Boolean;

    local procedure SetShowMandatoryConditions()
    begin
        BankBranchNoOrAccountNoMissing := (Rec."Bank Branch No." = '') or (Rec."Bank Account No." = '');
        IBANMissing := Rec.IBAN = '';
    end;

    procedure MandatoryDataFilledIn(): Boolean
    begin
        if (Rec.Name <> '')
and (Rec.Address <> '')
and (Rec.City <> '')
and (Rec."Post Code" <> '')
and (Rec."Country/Region Code" <> '')
and (Rec."Bank Name" <> '')
and (Rec."Bank Branch No." <> '')
and ((Rec."Bank Account No." <> '') or (Rec.IBAN <> '')) then
            exit(true);
    end;

    procedure CreateCompanyInfoData()
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo := Rec;
        if not CompanyInfo.Insert() then
            CompanyInfo.Modify();
    end;
}