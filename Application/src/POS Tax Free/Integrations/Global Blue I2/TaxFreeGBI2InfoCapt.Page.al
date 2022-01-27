page 6014573 "NPR Tax Free GB I2 Info Capt."
{
    Extensible = False;

    UsageCategory = None;
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
                field("Passport Number"; Rec."Passport Number")
                {

                    Editable = PassportNumberEditable;
                    ShowMandatory = PassportNumberMandatory;
                    Visible = PassportNumberMode <> PassportNumberMode::Hide;
                    ToolTip = 'Specifies the value of the Passport Number field';
                    ApplicationArea = NPRRetail;
                }
                field("First Name"; Rec."First Name")
                {

                    Editable = FirstNameEditable;
                    ShowMandatory = FirstNameMandatory;
                    Visible = FirstNameMode <> FirstNameMode::Hide;
                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Name"; Rec."Last Name")
                {

                    Editable = LastNameEditable;
                    ShowMandatory = LastNameMandatory;
                    Visible = LastNameMode <> LastNameMode::Hide;
                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Street; Rec.Street)
                {

                    Editable = StreetEditable;
                    ShowMandatory = StreetMandatory;
                    Visible = StreetMode <> StreetMode::Hide;
                    ToolTip = 'Specifies the value of the Street field';
                    ApplicationArea = NPRRetail;
                }
                field("Postal Code"; Rec."Postal Code")
                {

                    Editable = PostalCodeEditable;
                    ShowMandatory = PostalCodeMandatory;
                    Visible = PostalCodeMode <> PostalCodeMode::Hide;
                    ToolTip = 'Specifies the value of the Postal Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Town; Rec.Town)
                {

                    Editable = TownEditable;
                    ShowMandatory = TownMandatory;
                    Visible = TownMode <> TownMode::Hide;
                    ToolTip = 'Specifies the value of the Town field';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail"; Rec."E-mail")
                {

                    Editable = EmailEditable;
                    ShowMandatory = EmailMandatory;
                    Visible = EmailMode <> EmailMode::Hide;
                    ToolTip = 'Specifies the value of the E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Country Of Residence"; Rec."Country Of Residence")
                {

                    Editable = CountryCodeEditable;
                    ShowMandatory = CountryCodeMandatory;
                    Visible = CountryCodeMode <> CountryCodeMode::Hide;
                    ToolTip = 'Specifies the value of the Country Of Residence field';
                    ApplicationArea = NPRRetail;
                }
                field("Passport Country"; Rec."Passport Country")
                {

                    Editable = PassportCountryCodeEditable;
                    ShowMandatory = PassportCountryCodeMandatory;
                    Visible = PassportCountryCodeMode <> PassportCountryCodeMode::Hide;
                    ToolTip = 'Specifies the value of the Passport Country field';
                    ApplicationArea = NPRRetail;
                }
                field("Date Of Birth"; Rec."Date Of Birth")
                {

                    Editable = DateOfBirthEditable;
                    ShowMandatory = DateOfBirthMandatory;
                    Visible = DateOfBirthMode <> DateOfBirthMode::Hide;
                    ToolTip = 'Specifies the value of the Date Of Birth field';
                    ApplicationArea = NPRRetail;
                }
                field("Departure Date"; Rec."Departure Date")
                {

                    Editable = DepartureEditable;
                    ShowMandatory = DepartureMandatory;
                    Visible = DepartureDateMode <> DepartureDateMode::Hide;
                    ToolTip = 'Specifies the value of the Departure Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Arrival Date"; Rec."Arrival Date")
                {

                    Editable = ArrivalEditable;
                    ShowMandatory = ArrivalMandatory;
                    Visible = ArrivalDateMode <> ArrivalDateMode::Hide;
                    ToolTip = 'Specifies the value of the Arrival Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Final Destination Country"; Rec."Final Destination Country")
                {

                    Editable = FinalDestinationCountryCodeEditable;
                    ShowMandatory = FinalDestinationCountryCodeMandatory;
                    Visible = FinalDestinationCountryCodeMode <> FinalDestinationCountryCodeMode::Hide;
                    ToolTip = 'Specifies the value of the Final Destination Country field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Mobile Phone")
            {
                Caption = 'Mobile Phone No.';
                Visible = MobileNumberMode <> MobileNumberMode::Hide;
                field("Mobile No. Country"; Rec."Mobile No. Country")
                {

                    Editable = MobileNumberEditable;
                    Visible = MobileNumberMode <> MobileNumberMode::Hide;
                    ToolTip = 'Specifies the value of the Mobile No. Country field';
                    ApplicationArea = NPRRetail;
                }
                field("Mobile No. Prefix Formatted"; Rec."Mobile No. Prefix Formatted")
                {

                    Caption = 'Phone Prefix';
                    Editable = false;
                    Visible = MobileNumberMode <> MobileNumberMode::Hide;
                    ToolTip = 'Specifies the value of the Phone Prefix field';
                    ApplicationArea = NPRRetail;
                }
                field("Mobile No."; Rec."Mobile No.")
                {

                    Editable = MobileNumberEditable;
                    ShowMandatory = MobileNumberMandatory;
                    Visible = MobileNumberMode <> MobileNumberMode::Hide;
                    ToolTip = 'Specifies the value of the Mobile No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }


    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (CloseAction = ACTION::LookupOK) or (CloseAction = ACTION::OK) then
            ValidateInputs();
    end;

    var
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
            if Rec."Passport Number" = '' then
                Error(Error_MissingRequiredParam, Rec.FieldCaption("Passport Number"));

        if FirstNameMode = FirstNameMode::Required then
            if Rec."First Name" = '' then
                Error(Error_MissingRequiredParam, Rec.FieldCaption("First Name"));

        if LastNameMode = LastNameMode::Required then
            if Rec."Last Name" = '' then
                Error(Error_MissingRequiredParam, Rec.FieldCaption("Last Name"));

        if StreetMode = StreetMode::Required then
            if Rec.Street = '' then
                Error(Error_MissingRequiredParam, Rec.FieldCaption(Street));

        if PostalCodeMode = PostalCodeMode::Required then
            if Rec."Postal Code" = '' then
                Error(Error_MissingRequiredParam, Rec.FieldCaption("Postal Code"));

        if TownMode = TownMode::Required then
            if Rec.Town = '' then
                Error(Error_MissingRequiredParam, Rec.FieldCaption(Town));

        if CountryCodeMode = CountryCodeMode::Required then
            if Rec."Country Of Residence" = '' then
                Error(Error_MissingRequiredParam, Rec.FieldCaption("Country Of Residence"));

        if EmailMode = EmailMode::Required then
            if Rec."E-mail" = '' then
                Error(Error_MissingRequiredParam, Rec.FieldCaption("E-mail"));

        if MobileNumberMode = MobileNumberMode::Required then
            if Rec."Mobile No." = '' then
                Error(Error_MissingRequiredParam, Rec.FieldCaption("Mobile No."));

        if PassportCountryCodeMode = PassportCountryCodeMode::Required then
            if Rec."Passport Country" = '' then
                Error(Error_MissingRequiredParam, Rec.FieldCaption("Passport Country"));

        if DateOfBirthMode = DateOfBirthMode::Required then
            if Rec."Date Of Birth" = 0D then
                Error(Error_MissingRequiredParam, Rec.FieldCaption("Date Of Birth"));

        if DepartureDateMode = DepartureDateMode::Required then
            if Rec."Departure Date" = 0D then
                Error(Error_MissingRequiredParam, Rec.FieldCaption("Departure Date"));

        if ArrivalDateMode = ArrivalDateMode::Required then
            if Rec."Arrival Date" = 0D then
                Error(Error_MissingRequiredParam, Rec.FieldCaption("Arrival Date"));

        if FinalDestinationCountryCodeMode = FinalDestinationCountryCodeMode::Required then
            if Rec."Final Destination Country" = '' then
                Error(Error_MissingRequiredParam, Rec.FieldCaption("Final Destination Country"));
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

