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
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the company''s name and corporate form. For example, Inc. or Ltd.';
                }
                field(Address; Address)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the company''s address.';
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies additional address information.';
                }
                field(City; City)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the company''s city.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PostCode: Record "Post Code";
                        PostCodeList: Page "Post Codes";
                    begin
                        PostCodeList.LookupMode := true;

                        if ("Post Code" <> '') and (City <> '') then
                            if PostCode.Get("Post Code", City) then
                                PostCodeList.SetRecord(PostCode);

                        if PostCodeList.RunModal() = Action::LookupOK then begin
                            PostCodeList.GetRecord(PostCode);
                            "Post Code" := PostCode.Code;
                            City := PostCode.City;
                            "Country/Region Code" := PostCode."Country/Region Code";
                        end;
                    end;
                }
                field(County; County)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state, province or county of the company''s address.';
                    Visible = CountyVisible;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the postal code.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PostCode: Record "Post Code";
                        PostCodeList: Page "Post Codes";
                    begin
                        PostCodeList.LookupMode := true;

                        if ("Post Code" <> '') and (City <> '') then
                            if PostCode.Get("Post Code", City) then
                                PostCodeList.SetRecord(PostCode);

                        if PostCodeList.RunModal() = Action::LookupOK then begin
                            PostCodeList.GetRecord(PostCode);
                            "Post Code" := PostCode.Code;
                            City := PostCode.City;
                        end;
                    end;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the country/region of the address.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CountryRegion: Record "Country/Region";
                        CountriesRegions: Page "Countries/Regions";
                    begin
                        CountriesRegions.LookupMode := true;

                        if "Country/Region Code" <> '' then
                            if CountryRegion.Get("Country/Region Code") then
                                CountriesRegions.SetRecord(CountryRegion);

                        if CountriesRegions.RunModal() = Action::LookupOK then begin
                            CountriesRegions.GetRecord(CountryRegion);
                            "Country/Region Code" := CountryRegion.Code;
                        end;
                    end;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company''s telephone number.';
                }
                field("VAT Registration No."; "VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company''s VAT registration number.';
                }
                field(GLN; GLN)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies your company in connection with electronic document exchange.';
                }
                field("Industrial Classification"; "Industrial Classification")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the company''s industrial classification code.';
                }
                group(Pic)
                {
                    Caption = 'Picture';
                    field(Picture; Picture)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the picture that has been set up for the company, such as a company logo.';

                        trigger OnValidate()
                        begin
                            CurrPage.SaveRecord;
                        end;
                    }
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
                field("Bank Name"; "Bank Name")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the bank the company uses.';
                }
                field("Bank Branch No."; "Bank Branch No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = IBANMissing;
                    ToolTip = 'Specifies the bank''s branch number.';

                    trigger OnValidate()
                    begin
                        SetShowMandatoryConditions();
                    end;
                }
                field("Bank Account No."; "Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = IBANMissing;
                    ToolTip = 'Specifies the company''s bank account number.';

                    trigger OnValidate()
                    begin
                        SetShowMandatoryConditions();
                    end;
                }
                field("Giro No."; "Giro No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company''s giro number.';
                }
                field("SWIFT Code"; "SWIFT Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SWIFT code (international bank identifier code) of your primary bank.';

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

                        if "SWIFT Code" <> '' then
                            if SWIFTCode.Get("SWIFT Code") then
                                SWIFTCodes.SetRecord(SWIFTCode);

                        if SWIFTCodes.RunModal() = Action::LookupOK then begin
                            SWIFTCodes.GetRecord(SWIFTCode);
                            "SWIFT Code" := SWIFTCode.Code;
                        end;
                    end;
                }
                field(IBAN; IBAN)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = BankBranchNoOrAccountNoMissing;
                    ToolTip = 'Specifies the international bank account number of your primary bank account.';

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
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;

    var
        IBANMissing: Boolean;
        BankBranchNoOrAccountNoMissing: Boolean;
        CountyVisible: Boolean;

    local procedure SetShowMandatoryConditions()
    begin
        BankBranchNoOrAccountNoMissing := ("Bank Branch No." = '') or ("Bank Account No." = '');
        IBANMissing := IBAN = '';
    end;

    procedure MandatoryDataFilledIn(): Boolean
    begin
        with Rec do
            if (Name <> '')
            and (Address <> '')
            and (City <> '')
            and ("Post Code" <> '')
            and ("Country/Region Code" <> '')
            and ("Bank Name" <> '')
            and ("Bank Branch No." <> '')
            and (("Bank Account No." <> '') or (IBAN <> '')) then
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