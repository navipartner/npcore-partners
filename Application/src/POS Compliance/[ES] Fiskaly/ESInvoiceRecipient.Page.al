page 6184716 "NPR ES Invoice Recipient"
{
    Caption = 'Invoice Recipient';
    Extensible = false;
    PageType = StandardDialog;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field("Recipient Type"; RecipientType)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Type';
                ShowMandatory = true;
                ToolTip = 'Specifies the type of the recipient.';
                ValuesAllowed = National, International;
            }
            field("Recipient Legal Name"; RecipientLegalName)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Legal Name';
                ShowMandatory = true;
                ToolTip = 'Specifies the legal name of the recipient.';

                trigger OnValidate()
                begin
                    if RecipientLegalName <> '' then
                        CheckIsValueAccordingToAllowedPattern(RecipientLegalName, GetRecipientLegalNamePattern());
                end;
            }
            field("Recipient Address"; RecipientAddress)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Address';
                ShowMandatory = true;
                ToolTip = 'Specifies the address of the recipient.';

                trigger OnValidate()
                begin
                    if RecipientAddress <> '' then
                        CheckIsValueAccordingToAllowedPattern(RecipientAddress, GetRecipientAddressPattern());
                end;
            }
            field("Recipient Post Code"; RecipientPostCode)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Post Code';
                ShowMandatory = true;
                ToolTip = 'Specifies the post code of the recipient.';

                trigger OnValidate()
                begin
                    if RecipientPostCode <> '' then
                        CheckIsValueAccordingToAllowedPattern(RecipientPostCode, GetRecipientPostCodePattern());
                end;
            }
            group(NationalIdentificationGroup)
            {
                ShowCaption = false;
                Visible = RecipientType = RecipientType::National;

                field("Recipient VAT Registration No."; RecipientVATRegistrationNo)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'VAT Registration No.';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the VAT registration number of the recipient.';

                    trigger OnValidate()
                    begin
                        if RecipientVATRegistrationNo <> '' then
                            CheckIsValueAccordingToAllowedPattern(RecipientVATRegistrationNo, GetRecipientVATRegistrationNoPattern());
                    end;
                }
            }
            group(InternationalIdentificationGroup)
            {
                ShowCaption = false;
                Visible = RecipientType = RecipientType::International;

                field("Recipient Identification Type"; RecipientIdentificationType)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Identification Type';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the type of the recipient identification.';
                    ValuesAllowed = TAX_NUMBER, PASSPORT, DOCUMENT, CERTIFICATE, OTHER;
                }
                field("Recipient Identification No."; RecipientIdentificationNo)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Identification No.';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the identification number of the recipient.';

                    trigger OnValidate()
                    begin
                        if RecipientIdentificationNo <> '' then
                            CheckIsValueAccordingToAllowedPattern(RecipientIdentificationNo, GetRecipientIdentificationNoPattern());
                    end;
                }
                field("Recipient Country/Region Code"; RecipientCountryRegionCode)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Country/Region Code';
                    ShowMandatory = true;
                    TableRelation = "Country/Region";
                    ToolTip = 'Specifies the country/region code of the recipient.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if RecipientType = RecipientType::" " then
            RecipientType := RecipientType::National;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        AbortCreationOfCompletedInvoiceQst: Label 'Are you sure that you do not want to create completed invoice?';
    begin
        Clear(AllInvoiceDataEntered);
        Clear(CreationAborted);
        if CloseAction <> Action::OK then
            CreationAborted := ConfirmManagement.GetResponse(AbortCreationOfCompletedInvoiceQst, false);

        if CreationAborted then
            if not ManuallyComplete then
                Error(MustEnterNecessaryCompleteInvoiceDataErr)
            else
                exit(true);

        AllInvoiceDataEntered := (RecipientLegalName <> '') and (RecipientAddress <> '') and (RecipientPostCode <> '');
        ThrowMustEnterNecessaryCompleteInvoiceDataError();

        case RecipientType of
            RecipientType::National:
                AllInvoiceDataEntered := RecipientVATRegistrationNo <> '';
            RecipientType::International:
                AllInvoiceDataEntered := (RecipientIdentificationType <> RecipientIdentificationType::" ") and (RecipientIdentificationNo <> '') and (RecipientCountryRegionCode <> '');
        end;

        ThrowMustEnterNecessaryCompleteInvoiceDataError();
    end;

    var
        AllInvoiceDataEntered: Boolean;
        CreationAborted: Boolean;
        ManuallyComplete: Boolean;
        RecipientCountryRegionCode: Code[20];
        RecipientPostCode: Code[20];
        RecipientIdentificationType: Enum "NPR ES Inv. Rcpt. Id Type";
        RecipientType: Enum "NPR ES Inv. Recipient Type";
        MustEnterNecessaryCompleteInvoiceDataErr: Label 'You must enter all the necessary data for complete invoice.';
        RecipientVATRegistrationNo: Text[9];
        RecipientIdentificationNo: Text[20];
        RecipientLegalName: Text[120];
        RecipientAddress: Text[250];

    local procedure CheckIsValueAccordingToAllowedPattern(Value: Text; Pattern: Text)
    var
        ValueErr: Label '%1 is not according to pattern %2.', Comment = '%1 - value to check %2 - allowed pattern value';
    begin
        if not IsValueAccordingToAllowedPattern(Value, Pattern) then
            Error(ValueErr, Value, Pattern);
    end;

    local procedure IsValueAccordingToAllowedPattern(Value: Text; Pattern: Text): Boolean
    var
#IF BC17
        RegEx: Codeunit DotNet_Regex;
#ELSE
        Regex: Codeunit Regex;
#ENDIF
    begin
        exit(RegEx.IsMatch(Value, Pattern));
    end;

    local procedure GetRecipientLegalNamePattern(): Text
    var
        PatternLbl: Label '^( *[0-9A-Za-zñÑáÁàÀéÉíÍïÏóÓòÒúÚüÜçÇ°ºª.,()\-_/] *)*$', Locked = true;
    begin
        exit(PatternLbl);
    end;

    local procedure GetRecipientAddressPattern(): Text
    var
        PatternLbl: Label '^( *[0-9A-Za-zñÑáÁàÀéÉíÍïÏóÓòÒúÚüÜçÇ°ºª.,()\-_/] *)*$', Locked = true;
    begin
        exit(PatternLbl);
    end;

    local procedure GetRecipientPostCodePattern(): Text
    var
        PatternLbl: Label '^( *[0-9A-Za-z.\-_/] *)*$', Locked = true;
    begin
        exit(PatternLbl);
    end;

    local procedure GetRecipientVATRegistrationNoPattern(): Text
    var
        PatternLbl: Label '^(([A-Za-z][0-9]{7}[A-Za-z])|([0-9]{8}[A-Za-z])|([A-Za-z][0-9]{8}))$', Locked = true;
    begin
        exit(PatternLbl);
    end;

    local procedure GetRecipientIdentificationNoPattern(): Text
    var
        PatternLbl: Label '^( *[0-9A-Za-z.\-_/] *)*$', Locked = true;
    begin
        exit(PatternLbl);
    end;

    internal procedure SetRecipientData(Customer: Record Customer)
    var
        SpainLbl: Label 'ES', Locked = true;
    begin
        if (Customer."Country/Region Code" = '') or (Customer."Country/Region Code" = SpainLbl) then
            RecipientType := RecipientType::National
        else
            RecipientType := RecipientType::International;

        if IsValueAccordingToAllowedPattern(Customer.Name, GetRecipientLegalNamePattern()) then
            RecipientLegalName := Customer.Name;

        if IsValueAccordingToAllowedPattern(Customer.Address, GetRecipientAddressPattern()) then
            RecipientAddress := Customer.Address;

        if IsValueAccordingToAllowedPattern(Customer."Post Code", GetRecipientPostCodePattern()) then
            RecipientPostCode := Customer."Post Code";

        case RecipientType of
            RecipientType::National:
                if IsValueAccordingToAllowedPattern(Customer."VAT Registration No.", GetRecipientVATRegistrationNoPattern()) then
                    RecipientVATRegistrationNo := CopyStr(Customer."VAT Registration No.", 1, MaxStrLen(RecipientVATRegistrationNo));
            RecipientType::International:
                begin
                    if IsValueAccordingToAllowedPattern(Customer."VAT Registration No.", GetRecipientIdentificationNoPattern()) then
                        RecipientIdentificationNo := Customer."VAT Registration No.";

                    RecipientCountryRegionCode := Customer."Country/Region Code";
                end;
        end;
    end;

    internal procedure SetManuallyComplete(NewManuallyComplete: Boolean)
    begin
        ManuallyComplete := NewManuallyComplete;
    end;

    internal procedure GetCreationAborted(): Boolean
    begin
        exit(CreationAborted);
    end;

    internal procedure ThrowMustEnterNecessaryCompleteInvoiceDataError()
    begin
        if not AllInvoiceDataEntered then
            Error(MustEnterNecessaryCompleteInvoiceDataErr);
    end;

    internal procedure GetRecipientType(): Enum "NPR ES Inv. Recipient Type"
    begin
        exit(RecipientType);
    end;

    internal procedure GetRecipientLegalName(): Text[120]
    begin
        exit(RecipientLegalName);
    end;

    internal procedure GetRecipientAddress(): Text[250]
    begin
        exit(RecipientAddress);
    end;

    internal procedure GetRecipientPostCode(): Code[20]
    begin
        exit(RecipientPostCode);
    end;

    internal procedure GetRecipientVATRegistrationNo(): Text[9]
    begin
        exit(RecipientVATRegistrationNo);
    end;

    internal procedure GetRecipientIdentificationType(): Enum "NPR ES Inv. Rcpt. Id Type";
    begin
        exit(RecipientIdentificationType);
    end;

    internal procedure GetRecipientIdentificationNo(): Text[20]
    begin
        exit(RecipientIdentificationNo);
    end;

    internal procedure GetRecipientCountryRegionCode(): Code[20]
    begin
        exit(RecipientCountryRegionCode);
    end;
}
