page 6014573 "NPR Tax Free GB I2 Info Capt."
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB I2 Info Capture';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    SourceTable = "NPR TaxFree GB I2 Info Capt.";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control6014403)
            {
                ShowCaption = false;
                field("Passport Number"; "Passport Number")
                {
                    ApplicationArea = All;
                    Editable = PassportNumberEditable;
                    ShowMandatory = PassportNumberMandatory;
                    Visible = PassportNumberMode <> PassportNumberMode::Hide;
                }
                field("First Name"; "First Name")
                {
                    ApplicationArea = All;
                    Editable = FirstNameEditable;
                    ShowMandatory = FirstNameMandatory;
                    Visible = FirstNameMode <> FirstNameMode::Hide;
                }
                field("Last Name"; "Last Name")
                {
                    ApplicationArea = All;
                    Editable = LastNameEditable;
                    ShowMandatory = LastNameMandatory;
                    Visible = LastNameMode <> LastNameMode::Hide;
                }
                field(Street; Street)
                {
                    ApplicationArea = All;
                    Editable = StreetEditable;
                    ShowMandatory = StreetMandatory;
                    Visible = StreetMode <> StreetMode::Hide;
                }
                field("Postal Code"; "Postal Code")
                {
                    ApplicationArea = All;
                    Editable = PostalCodeEditable;
                    ShowMandatory = PostalCodeMandatory;
                    Visible = PostalCodeMode <> PostalCodeMode::Hide;
                }
                field(Town; Town)
                {
                    ApplicationArea = All;
                    Editable = TownEditable;
                    ShowMandatory = TownMandatory;
                    Visible = TownMode <> TownMode::Hide;
                }
                field("E-mail"; "E-mail")
                {
                    ApplicationArea = All;
                    Editable = EmailEditable;
                    ShowMandatory = EmailMandatory;
                    Visible = EmailMode <> EmailMode::Hide;
                }
                field("Country Of Residence"; "Country Of Residence")
                {
                    ApplicationArea = All;
                    Editable = CountryCodeEditable;
                    ShowMandatory = CountryCodeMandatory;
                    Visible = CountryCodeMode <> CountryCodeMode::Hide;
                }
                field("Passport Country"; "Passport Country")
                {
                    ApplicationArea = All;
                    Editable = PassportCountryCodeEditable;
                    ShowMandatory = PassportCountryCodeMandatory;
                    Visible = PassportCountryCodeMode <> PassportCountryCodeMode::Hide;
                }
                field("Date Of Birth"; "Date Of Birth")
                {
                    ApplicationArea = All;
                    Editable = DateOfBirthEditable;
                    ShowMandatory = DateOfBirthMandatory;
                    Visible = DateOfBirthMode <> DateOfBirthMode::Hide;
                }
                field("Departure Date"; "Departure Date")
                {
                    ApplicationArea = All;
                    Editable = DepartureEditable;
                    ShowMandatory = DepartureMandatory;
                    Visible = DepartureDateMode <> DepartureDateMode::Hide;
                }
                field("Arrival Date"; "Arrival Date")
                {
                    ApplicationArea = All;
                    Editable = ArrivalEditable;
                    ShowMandatory = ArrivalMandatory;
                    Visible = ArrivalDateMode <> ArrivalDateMode::Hide;
                }
                field("Final Destination Country"; "Final Destination Country")
                {
                    ApplicationArea = All;
                    Editable = FinalDestinationCountryCodeEditable;
                    ShowMandatory = FinalDestinationCountryCodeMandatory;
                    Visible = FinalDestinationCountryCodeMode <> FinalDestinationCountryCodeMode::Hide;
                }
            }
            group("Mobile Phone")
            {
                Caption = 'Mobile Phone No.';
                Visible = MobileNumberMode <> MobileNumberMode::Hide;
                field("Mobile No. Country"; "Mobile No. Country")
                {
                    ApplicationArea = All;
                    Editable = MobileNumberEditable;
                    Visible = MobileNumberMode <> MobileNumberMode::Hide;
                }
                field("Mobile No. Prefix Formatted"; "Mobile No. Prefix Formatted")
                {
                    ApplicationArea = All;
                    Caption = 'Phone Prefix';
                    Editable = false;
                    Visible = MobileNumberMode <> MobileNumberMode::Hide;
                }
                field("Mobile No."; "Mobile No.")
                {
                    ApplicationArea = All;
                    Editable = MobileNumberEditable;
                    ShowMandatory = MobileNumberMandatory;
                    Visible = MobileNumberMode <> MobileNumberMode::Hide;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (CloseAction = ACTION::LookupOK) or (CloseAction = ACTION::OK) then
            ValidateInputs();
    end;

    var
        "-- Input Mode": Integer;
        PassportNumberMode: Option Hide,Optional,Required;
        LastNameMode: Option Hide,Optional,Required;
        FirstNameMode: Option Hide,Optional,Required;
        StreetMode: Option Hide,Optional,Required;
        PostalCodeMode: Option Hide,Optional,Required;
        TownMode: Option Hide,Optional,Required;
        CountryCodeMode: Option Hide,Optional,Required;
        EmailMode: Option Hide,Optional,Required;
        MobileNumberMode: Option Hide,Optional,Required;
        PassportCountryCodeMode: Option Hide,Optional,Required;
        DateOfBirthMode: Option Hide,Optional,Required;
        DepartureDateMode: Option Hide,Optional,Required;
        ArrivalDateMode: Option Hide,Optional,Required;
        FinalDestinationCountryCodeMode: Option Hide,Optional,Required;
        Error_MissingRequiredParam: Label 'Missing required parameter: %1';
        "-- Input Editable": Integer;
        PassportNumberEditable: Boolean;
        LastNameEditable: Boolean;
        FirstNameEditable: Boolean;
        StreetEditable: Boolean;
        PostalCodeEditable: Boolean;
        TownEditable: Boolean;
        CountryCodeEditable: Boolean;
        EmailEditable: Boolean;
        MobileNumberEditable: Boolean;
        PassportCountryCodeEditable: Boolean;
        DateOfBirthEditable: Boolean;
        DepartureEditable: Boolean;
        ArrivalEditable: Boolean;
        FinalDestinationCountryCodeEditable: Boolean;
        Error_NotEditable: Label 'Field %1 is not editable';
        "-- Input ShowMandatory": Integer;
        PassportNumberMandatory: Boolean;
        LastNameMandatory: Boolean;
        FirstNameMandatory: Boolean;
        StreetMandatory: Boolean;
        PostalCodeMandatory: Boolean;
        TownMandatory: Boolean;
        CountryCodeMandatory: Boolean;
        EmailMandatory: Boolean;
        MobileNumberMandatory: Boolean;
        PassportCountryCodeMandatory: Boolean;
        DateOfBirthMandatory: Boolean;
        DepartureMandatory: Boolean;
        ArrivalMandatory: Boolean;
        FinalDestinationCountryCodeMandatory: Boolean;

    procedure SetModes(var GlobalBlueParameters: Record "NPR Tax Free GB I2 Param.")
    begin
        //Controls visible parameter
        PassportNumberMode := GlobalBlueParameters."(Dialog) Passport Number";
        LastNameMode := GlobalBlueParameters."(Dialog) Last Name";
        FirstNameMode := GlobalBlueParameters."(Dialog) First Name";
        StreetMode := GlobalBlueParameters."(Dialog) Street";
        PostalCodeMode := GlobalBlueParameters."(Dialog) Postal Code";
        TownMode := GlobalBlueParameters."(Dialog) Town";
        CountryCodeMode := GlobalBlueParameters."(Dialog) Country Code";
        EmailMode := GlobalBlueParameters."(Dialog) Email";
        MobileNumberMode := GlobalBlueParameters."(Dialog) Mobile No.";
        PassportCountryCodeMode := GlobalBlueParameters."(Dialog) Passport Country Code";
        DateOfBirthMode := GlobalBlueParameters."(Dialog) Date Of Birth";
        DepartureDateMode := GlobalBlueParameters."(Dialog) Departure Date";
        ArrivalDateMode := GlobalBlueParameters."(Dialog) Arrival Date";
        FinalDestinationCountryCodeMode := GlobalBlueParameters."(Dialog) Dest. Country Code";

        //Controls ShowMandatory parameter
        PassportNumberMandatory := PassportNumberMode = PassportNumberMode::Required;
        LastNameMandatory := LastNameMode = LastNameMode::Required;
        FirstNameMandatory := FirstNameMode = FirstNameMode::Required;
        StreetMandatory := StreetMode = StreetMode::Required;
        PostalCodeMandatory := PostalCodeMode = PostalCodeMode::Required;
        TownMandatory := TownMode = TownMode::Required;
        CountryCodeMandatory := CountryCodeMode = CountryCodeMode::Required;
        EmailMandatory := EmailMode = EmailMode::Required;
        MobileNumberMandatory := MobileNumberMode = MobileNumberMode::Required;
        PassportCountryCodeMandatory := PassportCountryCodeMode = PassportCountryCodeMode::Required;
        DateOfBirthMandatory := DateOfBirthMode = DateOfBirthMode::Required;
        DepartureMandatory := DepartureDateMode = DepartureDateMode::Required;
        ArrivalMandatory := ArrivalDateMode = ArrivalDateMode::Required;
        FinalDestinationCountryCodeMandatory := FinalDestinationCountryCodeMode = FinalDestinationCountryCodeMode::Required;
    end;

    local procedure ValidateInputs()
    begin
        if PassportNumberMode = PassportNumberMode::Required then
            if "Passport Number" = '' then
                Error(Error_MissingRequiredParam, FieldCaption("Passport Number"));

        if FirstNameMode = FirstNameMode::Required then
            if "First Name" = '' then
                Error(Error_MissingRequiredParam, FieldCaption("First Name"));

        if LastNameMode = LastNameMode::Required then
            if "Last Name" = '' then
                Error(Error_MissingRequiredParam, FieldCaption("Last Name"));

        if StreetMode = StreetMode::Required then
            if Street = '' then
                Error(Error_MissingRequiredParam, FieldCaption(Street));

        if PostalCodeMode = PostalCodeMode::Required then
            if "Postal Code" = '' then
                Error(Error_MissingRequiredParam, FieldCaption("Postal Code"));

        if TownMode = TownMode::Required then
            if Town = '' then
                Error(Error_MissingRequiredParam, FieldCaption(Town));

        if CountryCodeMode = CountryCodeMode::Required then
            if "Country Of Residence" = '' then
                Error(Error_MissingRequiredParam, FieldCaption("Country Of Residence"));

        if EmailMode = EmailMode::Required then
            if "E-mail" = '' then
                Error(Error_MissingRequiredParam, FieldCaption("E-mail"));

        if MobileNumberMode = MobileNumberMode::Required then
            if "Mobile No." = '' then
                Error(Error_MissingRequiredParam, FieldCaption("Mobile No."));

        if PassportCountryCodeMode = PassportCountryCodeMode::Required then
            if "Passport Country" = '' then
                Error(Error_MissingRequiredParam, FieldCaption("Passport Country"));

        if DateOfBirthMode = DateOfBirthMode::Required then
            if "Date Of Birth" = 0D then
                Error(Error_MissingRequiredParam, FieldCaption("Date Of Birth"));

        if DepartureDateMode = DepartureDateMode::Required then
            if "Departure Date" = 0D then
                Error(Error_MissingRequiredParam, FieldCaption("Departure Date"));

        if ArrivalDateMode = ArrivalDateMode::Required then
            if "Arrival Date" = 0D then
                Error(Error_MissingRequiredParam, FieldCaption("Arrival Date"));

        if FinalDestinationCountryCodeMode = FinalDestinationCountryCodeMode::Required then
            if "Final Destination Country" = '' then
                Error(Error_MissingRequiredParam, FieldCaption("Final Destination Country"));
    end;

    procedure SetRec(var tmpCustomerInfoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary)
    begin
        if not tmpCustomerInfoCapture.IsTemporary then
            exit;

        Rec.Copy(tmpCustomerInfoCapture, true);

        PassportNumberEditable := tmpCustomerInfoCapture."Passport Number" = '';
        LastNameEditable := tmpCustomerInfoCapture."Last Name" = '';
        FirstNameEditable := tmpCustomerInfoCapture."First Name" = '';
        StreetEditable := tmpCustomerInfoCapture.Street = '';
        PostalCodeEditable := tmpCustomerInfoCapture."Postal Code" = '';
        TownEditable := tmpCustomerInfoCapture.Town = '';
        CountryCodeEditable := tmpCustomerInfoCapture."Country Of Residence Code" = 0;
        EmailEditable := tmpCustomerInfoCapture."E-mail" = '';
        MobileNumberEditable := tmpCustomerInfoCapture."Mobile No." = '';
        PassportCountryCodeEditable := tmpCustomerInfoCapture."Passport Country Code" = 0;
        DateOfBirthEditable := tmpCustomerInfoCapture."Date Of Birth" = 0D;
        DepartureEditable := tmpCustomerInfoCapture."Departure Date" = 0D;
        ArrivalEditable := tmpCustomerInfoCapture."Arrival Date" = 0D;
        FinalDestinationCountryCodeEditable := tmpCustomerInfoCapture."Final Destination Country Code" = 0;
    end;

    procedure SetAllEditable()
    begin
        PassportNumberEditable := true;
        LastNameEditable := true;
        FirstNameEditable := true;
        StreetEditable := true;
        PostalCodeEditable := true;
        TownEditable := true;
        CountryCodeEditable := true;
        EmailEditable := true;
        MobileNumberEditable := true;
        PassportCountryCodeEditable := true;
        DateOfBirthEditable := true;
        DepartureEditable := true;
        ArrivalEditable := true;
        FinalDestinationCountryCodeEditable := true;
    end;

    procedure SetAllNonMandatory()
    begin
        PassportNumberMandatory := false;
        LastNameMandatory := false;
        FirstNameMandatory := false;
        StreetMandatory := false;
        PostalCodeMandatory := false;
        TownMandatory := false;
        CountryCodeMandatory := false;
        EmailMandatory := false;
        MobileNumberMandatory := false;
        PassportCountryCodeMandatory := false;
        DateOfBirthMandatory := false;
        DepartureMandatory := false;
        ArrivalMandatory := false;
        FinalDestinationCountryCodeMandatory := false;
    end;

    procedure GetRec(var tmpCustomerInfoCapture: Record "NPR TaxFree GB I2 Info Capt." temporary)
    begin
        if not tmpCustomerInfoCapture.IsTemporary then
            exit;

        tmpCustomerInfoCapture.Copy(Rec, true);
    end;
}

