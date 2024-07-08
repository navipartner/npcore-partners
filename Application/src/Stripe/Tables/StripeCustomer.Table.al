table 6014638 "NPR Stripe Customer"
{
    Access = Internal;
    Caption = 'Stripe Customer';

    fields
    {
        field(1; Id; Text[50])
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(5; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(6; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(7; City; Text[30])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
            TableRelation = if ("Country/Region Code" = const('')) "Post Code".City
            else
            if ("Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
#pragma warning disable AA0139
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
#pragma warning restore AA0139
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(9; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;

            trigger OnValidate()
            begin
                ValidatePhoneNo();
            end;
        }
        field(35; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
#pragma warning disable AA0139
                PostCode.CheckClearPostCodeCityCounty(City, "Post Code", County, "Country/Region Code", xRec."Country/Region Code");
#pragma warning restore AA0139
                if "Country/Region Code" <> xRec."Country/Region Code" then
                    VATRegistrationValidation();
            end;
        }
        field(86; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "VAT Registration No." := UpperCase("VAT Registration No.");
                if "VAT Registration No." <> xRec."VAT Registration No." then
                    VATRegistrationValidation();
            end;
        }
        field(91; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Country/Region Code" = const('')) "Post Code"
            else
            if ("Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
#pragma warning disable AA0139
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
#pragma warning restore AA0139
            end;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(92; County; Text[30])
        {
            CaptionClass = '5,1,' + "Country/Region Code";
            Caption = 'County';
            DataClassification = CustomerContent;
        }
        field(102; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;

            trigger OnValidate()
            begin
                ValidateEmail();
            end;
        }
        field(8000; "Token Id"; Text[30])
        {
            Caption = 'Token Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    var
        PostCode: Record "Post Code";

    local procedure ValidatePhoneNo()
    var
        TypeHelper: Codeunit "Type Helper";
        InvalidPhoneNumberErr: Label 'The phone number is invalid.';
    begin
        if "Phone No." = '' then
            exit;

        if not TypeHelper.IsPhoneNumber("Phone No.") then
            Error(InvalidPhoneNumberErr);
    end;

    local procedure VATRegistrationValidation()
    var
        VATRegistrationNoFormat: Record "VAT Registration No. Format";
    begin
        VATRegistrationNoFormat.Test("VAT Registration No.", "Country/Region Code", '', Database::"NPR Stripe Customer");

        if VATRegistrationNoMandatory() then
            if not "VAT Registration No.".StartsWith('DK') then
                "VAT Registration No." := CopyStr('DK' + "VAT Registration No.", 1, MaxStrLen("VAT Registration No."));
    end;

    local procedure ValidateEmail()
    var
        MailManagement: Codeunit "Mail Management";
    begin
        if "E-Mail" = '' then
            exit;
        MailManagement.CheckValidEmailAddresses("E-Mail");
    end;

    internal procedure VATRegistrationNoMandatory(): Boolean
    var
        CountryRegion: Record "Country/Region";
    begin
        if "Country/Region Code" = '' then
            exit(false);

        CountryRegion.Get("Country/Region Code");
        if CountryRegion.Code in ['DK', 'DNK'] then
            exit(true);

        if CountryRegion."ISO Code" = 'DK' then
            exit(true);

        if CountryRegion."ISO Numeric Code" = '208' then
            exit(true);

        exit(false);
    end;

    internal procedure TestDetails()
    var
        FieldMustHaveAValueErr: Label '%1 must have a value.', Comment = '%1 - field caption that missing a value';
    begin
        if Name = '' then
            Error(FieldMustHaveAValueErr, FieldCaption(Name));

        if "Country/Region Code" = '' then
            Error(FieldMustHaveAValueErr, FieldCaption("Country/Region Code"));

        if "E-Mail" = '' then
            Error(FieldMustHaveAValueErr, FieldCaption("E-Mail"));

        if VATRegistrationNoMandatory() and ("VAT Registration No." = '') then
            Error(FieldMustHaveAValueErr, FieldCaption("VAT Registration No."));
    end;

    internal procedure CreateTrialCustomer(): Boolean
    var
        StripeCreateTrialCust: Codeunit "NPR Stripe Create Trial Cust.";
    begin
        exit(StripeCreateTrialCust.CreateTrialCustomer(Rec));
    end;

    internal procedure CreateCustomer(): Boolean
    var
        StripeWebService: Codeunit "NPR Stripe Web Service";
    begin
        exit(StripeWebService.CreateCustomer(Rec));
    end;

    internal procedure UpdateCustomer(): Boolean
    var
        StripeWebService: Codeunit "NPR Stripe Web Service";
    begin
        exit(StripeWebService.UpdateCustomer(Rec));
    end;

    internal procedure CreateSubscription(StripePlan: Record "NPR Stripe Plan"): Boolean
    var
        StripeCreateSubs: Codeunit "NPR Stripe Create Subs.";
    begin
        exit(StripeCreateSubs.CreateSubscription(Rec, StripePlan));
    end;

    internal procedure GetCustomerPortalURL(var CustomerPortalURL: Text): Boolean
    var
        StripeWebService: Codeunit "NPR Stripe Web Service";
    begin
        exit(StripeWebService.GetCustomerPortalURL(Rec, CustomerPortalURL));
    end;

    internal procedure GetAsFormData() Data: Text
    var
        DescriptionLbl: Label '%1 - %2, %3', Locked = true, Comment = '%1 = Company name, %2 = Customer name, %3 = Customer address';
    begin
        Data := 'email=' + "E-Mail" +
                '&description=' + StrSubstNo(DescriptionLbl, CompanyName(), Name, Address) +
                '&shipping[name]=' + Name +
                '&shipping[phone]=' + "Phone No." +
                '&shipping[address][line1]=' + Address +
                '&shipping[address][line2]=' + "Address 2" +
                '&shipping[address][postal_code]=' + "Post Code" +
                '&shipping[address][city]=' + City +
                '&shipping[address][state]=' + County +
                '&shipping[address][country]=' + "Country/Region Code";
        if "Token Id" <> '' then
            Data += '&source=' + "Token Id";
    end;

    internal procedure PopulateFromJson(Data: JsonObject)
    var
        StripeJSONHelper: Codeunit "NPR Stripe JSON Helper";
    begin
        StripeJSONHelper.SetJsonObject(Data);
        Id := CopyStr(StripeJSONHelper.GetJsonValue('id').AsText(), 1, MaxStrLen(Id));
        Name := CopyStr(StripeJSONHelper.SelectJsonValue('$.shipping.name').AsText(), 1, MaxStrLen(Name));
        "Phone No." := CopyStr(StripeJSONHelper.SelectJsonValue('$.shipping.phone').AsText(), 1, MaxStrLen("Phone No."));
        Address := CopyStr(StripeJSONHelper.SelectJsonValue('$.shipping.address.line1').AsText(), 1, MaxStrLen(Address));
        "Address 2" := CopyStr(StripeJSONHelper.SelectJsonValue('$.shipping.address.line2').AsText(), 1, MaxStrLen("Address 2"));
        "Post Code" := CopyStr(StripeJSONHelper.SelectJsonValue('$.shipping.address.postal_code').AsText(), 1, MaxStrLen("Post Code"));
        City := CopyStr(StripeJSONHelper.SelectJsonValue('$.shipping.address.city').AsText(), 1, MaxStrLen(City));
        County := CopyStr(StripeJSONHelper.SelectJsonValue('$.shipping.address.state').AsText(), 1, MaxStrLen(County));
        "Country/Region Code" := CopyStr(StripeJSONHelper.SelectJsonValue('$.shipping.address.country').AsText(), 1, MaxStrLen("Country/Region Code"));
    end;

    internal procedure ToJSON(): Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextReaderWriter.WriteStartObject('');
        JsonTextReaderWriter.WriteStringProperty('id', Id);
        JsonTextReaderWriter.WriteEndObject();
        exit(JsonTextReaderWriter.GetJSonAsText());
    end;
}