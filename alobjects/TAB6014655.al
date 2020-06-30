table 6014655 "Tax Free GB I2 Info Capture"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB I2 Info Capture';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Shop Country Code"; Integer)
        {
            Caption = 'Shop Country Code';
        }
        field(3; "Passport Number"; Text[20])
        {
            Caption = 'Passport Number';

            trigger OnValidate()
            begin
                if "Passport Number" <> '' then
                    "Passport Number" := UpperCase("Passport Number");
            end;
        }
        field(4; "First Name"; Text[30])
        {
            Caption = 'First Name';
        }
        field(5; "Last Name"; Text[30])
        {
            Caption = 'Last Name';
        }
        field(6; Street; Text[100])
        {
            Caption = 'Street';
        }
        field(7; "Postal Code"; Text[20])
        {
            Caption = 'Postal Code';
        }
        field(8; Town; Text[50])
        {
            Caption = 'Town';
        }
        field(9; "Country Of Residence"; Text[60])
        {
            Caption = 'Country Of Residence';

            trigger OnLookup()
            begin
                LookupCountryOfResidence();
            end;

            trigger OnValidate()
            var
                GlobalBlueCountries: Record "Tax Free GB Country";
                GlobalBlueBlockedCountries: Record "Tax Free GB Blocked Country";
            begin
                if "Country Of Residence" = '' then begin
                    Validate("Country Of Residence Code", 0);
                    Validate("Mobile No. Country", '');
                end else begin
                    GlobalBlueCountries.SetFilter(Name, '@' + "Country Of Residence");
                    if not GlobalBlueCountries.FindFirst then begin
                        GlobalBlueCountries.SetFilter(Name, '@' + "Country Of Residence" + '*');
                        GlobalBlueCountries.FindFirst;
                    end;
                    GlobalBlueBlockedCountries.SetRange("Shop Country Code", "Shop Country Code");
                    GlobalBlueBlockedCountries.SetRange("Country Code", GlobalBlueCountries."Country Code");
                    if GlobalBlueBlockedCountries.FindFirst then
                        Error(Error_BlockedCountry, GlobalBlueCountries.Name);

                    "Country Of Residence" := GlobalBlueCountries.Name;
                    Validate("Country Of Residence Code", GlobalBlueCountries."Country Code");
                    Validate("Mobile No. Country", GlobalBlueCountries.Name);
                end;
            end;
        }
        field(10; "Country Of Residence Code"; Integer)
        {
            Caption = 'Country Of Residence Code';
        }
        field(11; "E-mail"; Text[100])
        {
            Caption = 'E-mail';

            trigger OnValidate()
            begin
                ValidateEmail();
            end;
        }
        field(12; "Mobile No."; Text[20])
        {
            Caption = 'Mobile No.';

            trigger OnValidate()
            begin
                ValidatePhoneNo();
            end;
        }
        field(13; "Mobile No. Prefix"; Integer)
        {
            Caption = 'Mobile No. Prefix';

            trigger OnValidate()
            begin
                if "Mobile No. Prefix" = 0 then
                    "Mobile No. Prefix Formatted" := ''
                else
                    "Mobile No. Prefix Formatted" := '+' + Format("Mobile No. Prefix");
            end;
        }
        field(14; "Mobile No. Prefix Formatted"; Text[10])
        {
            Caption = 'Mobile No. Prefix Formatted';
        }
        field(15; "Mobile No. Country"; Text[60])
        {
            Caption = 'Mobile No. Country';

            trigger OnLookup()
            begin
                LookupMobilePhoneCountry();
            end;

            trigger OnValidate()
            var
                GlobalBlueCountries: Record "Tax Free GB Country";
            begin
                if "Mobile No. Country" = '' then
                    Validate("Mobile No. Prefix", 0)
                else begin
                    GlobalBlueCountries.SetFilter(Name, '@' + "Mobile No. Country");
                    if not GlobalBlueCountries.FindFirst then begin
                        GlobalBlueCountries.SetFilter(Name, '@' + "Mobile No. Country" + '*');
                        GlobalBlueCountries.FindFirst;
                    end;

                    "Mobile No. Country" := GlobalBlueCountries.Name;
                    Validate("Mobile No. Prefix", GlobalBlueCountries."Phone Prefix");
                end;
            end;
        }
        field(16; "Passport Country"; Text[60])
        {
            Caption = 'Passport Country';

            trigger OnLookup()
            begin
                LookupPassportCountry();
            end;

            trigger OnValidate()
            var
                GlobalBlueCountries: Record "Tax Free GB Country";
            begin
                if "Passport Country" = '' then begin
                    Validate("Passport Country Code", 0);
                end else begin
                    GlobalBlueCountries.SetFilter("Passport Code", '<>%1', 0);
                    GlobalBlueCountries.SetFilter(Name, '@' + "Passport Country");
                    if not GlobalBlueCountries.FindFirst then begin
                        GlobalBlueCountries.SetFilter(Name, '@' + "Passport Country" + '*');
                        GlobalBlueCountries.FindFirst;
                    end;

                    "Passport Country" := GlobalBlueCountries.Name;
                    Validate("Passport Country Code", GlobalBlueCountries."Country Code");
                end;
            end;
        }
        field(17; "Passport Country Code"; Integer)
        {
            Caption = 'Passport Country Code';
        }
        field(18; "Date Of Birth"; Date)
        {
            Caption = 'Date Of Birth';

            trigger OnValidate()
            begin
                ValidateDateOfBirth();
            end;
        }
        field(19; "Departure Date"; Date)
        {
            Caption = 'Departure Date';
        }
        field(20; "Arrival Date"; Date)
        {
            Caption = 'Arrival Date';
        }
        field(21; "Final Destination Country"; Text[60])
        {
            Caption = 'Final Destination Country';

            trigger OnLookup()
            begin
                LookupDestinationCountry();
            end;

            trigger OnValidate()
            var
                GlobalBlueCountries: Record "Tax Free GB Country";
            begin
                if "Final Destination Country" = '' then begin
                    Validate("Final Destination Country Code", 0);
                end else begin
                    GlobalBlueCountries.SetFilter(Name, '@' + "Final Destination Country");
                    if not GlobalBlueCountries.FindFirst then begin
                        GlobalBlueCountries.SetFilter(Name, '@' + "Final Destination Country" + '*');
                        GlobalBlueCountries.FindFirst;
                    end;

                    "Final Destination Country" := GlobalBlueCountries.Name;
                    Validate("Final Destination Country Code", GlobalBlueCountries."Country Code");
                end;
            end;
        }
        field(22; "Final Destination Country Code"; Integer)
        {
            Caption = 'Final Destination Country Code';
        }
        field(23; "Global Blue Identifier"; Text[250])
        {
            Caption = 'Global Blue Identifier';
        }
        field(24; "Is Identity Checked"; Boolean)
        {
            Caption = 'Is Identity Checked';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Error_InvalidValue: Label 'Invalid %1: %2';
        Error_BlockedCountry: Label 'Country %1 is blocked from selection';

    local procedure TryLookupCountry(var GlobalBlueCountryOut: Record "Tax Free GB Country"; ShowPassportCodeZero: Boolean; ShowBlocked: Boolean): Boolean
    var
        TaxFreeGBCountries: Record "Tax Free GB Country";
        TaxFreeGBBlockedCountries: Record "Tax Free GB Blocked Country";
        TaxFreeGBCountriesPage: Page "Tax Free GB Countries";
        FilterString: Text;
    begin
        if not ShowBlocked then begin
            TaxFreeGBBlockedCountries.SetRange("Shop Country Code", "Shop Country Code");
            if TaxFreeGBBlockedCountries.FindSet then
                repeat
                    if FilterString <> '' then
                        FilterString += '&';
                    FilterString += '<>' + Format(TaxFreeGBBlockedCountries."Country Code");
                until TaxFreeGBBlockedCountries.Next = 0;
            if FilterString <> '' then
                TaxFreeGBCountries.SetFilter("Country Code", FilterString);
        end;

        if not ShowPassportCodeZero then
            TaxFreeGBCountries.SetFilter("Passport Code", '<>%1', 0);

        TaxFreeGBCountriesPage.LookupMode(true);
        TaxFreeGBCountriesPage.SetTableView(TaxFreeGBCountries);
        if TaxFreeGBCountriesPage.RunModal() = ACTION::LookupOK then begin
            TaxFreeGBCountriesPage.GetRecord(TaxFreeGBCountries);
            GlobalBlueCountryOut := TaxFreeGBCountries;
            exit(true);
        end;
    end;

    procedure ValidateEmail()
    var
        RegEx: Codeunit DotNet_Regex;
    begin
        //Simple error catcher - not required in global blue docs.
        if not RegEx.IsMatch("E-mail", '^[^@\s]+@[^@\s]+\.[^@\s]+$') then
            Error(Error_InvalidValue, FieldCaption("E-mail"), "E-mail");
    end;

    procedure ValidateDateOfBirth()
    begin
        //Simple error catcher - not required in global blue docs.
        if ("Date Of Birth" < DMY2Date(1, 1, 1900)) or ("Date Of Birth" > Today) then
            Error(Error_InvalidValue, FieldCaption("Date Of Birth"), Format("Date Of Birth"));
    end;

    procedure ValidatePhoneNo()
    var
        RegEx: Codeunit DotNet_Regex;
    begin
        if not RegEx.IsMatch("Mobile No.", '^(0|[1-9][0-9]*)$') then
            Error(Error_InvalidValue, FieldCaption("Mobile No."), "Mobile No.");

        if StrLen("Mobile No.") < 5 then
            Error(Error_InvalidValue, FieldCaption("Mobile No."), "Mobile No.");
    end;

    procedure LookupCountryOfResidence()
    var
        GlobalBlueCountry: Record "Tax Free GB Country";
    begin
        if TryLookupCountry(GlobalBlueCountry, true, false) then
            Validate("Country Of Residence", GlobalBlueCountry.Name);
    end;

    procedure LookupPassportCountry()
    var
        GlobalBlueCountry: Record "Tax Free GB Country";
    begin
        if TryLookupCountry(GlobalBlueCountry, false, true) then
            Validate("Passport Country", GlobalBlueCountry.Name);
    end;

    procedure LookupDestinationCountry()
    var
        GlobalBlueCountry: Record "Tax Free GB Country";
    begin
        if TryLookupCountry(GlobalBlueCountry, true, true) then
            Validate("Final Destination Country", GlobalBlueCountry.Name);
    end;

    procedure LookupMobilePhoneCountry()
    var
        GlobalBlueCountry: Record "Tax Free GB Country";
    begin
        if TryLookupCountry(GlobalBlueCountry, true, true) then
            Validate("Mobile No. Country", GlobalBlueCountry.Name);
    end;
}

