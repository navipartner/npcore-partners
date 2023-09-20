page 6150760 "NPR OIOUBL Update Document"
{
    PageType = ConfirmationDialog;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Caption = 'Change Document';
    Extensible = false;

    layout
    {
        area(Content)
        {
            field("VAT Registration No."; VATRegNo)
            {
                ApplicationArea = NPRRetail;
                Caption = 'VAT Registration No.';
                ToolTip = 'Specify the VAT Registration No. to be set on the Document';
            }
            field("OIOUBL - GLN"; OIOUBLGLN)
            {
                ApplicationArea = NPRRetail;
                Caption = 'GLN';
                ToolTip = 'Specify the GLN to be set on the Document';
            }
            field("Payment Terms Code"; PaymentTermsCode)
            {
                ApplicationArea = NPRRetail;
                Visible = ShowPaymentTerms;
                Caption = 'Payment Terms Code';
                ToolTip = 'Specify the Payment Terms Code to be set on the Document';
            }
            field(Contact; Contact)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Contact';
                ToolTip = 'Specify the Contact to be set on the Document';
            }
            field(CountryRegionCodeFld; CountryRegionCode)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Country/Region Code';
                ToolTip = 'Specify the Country/Region Code to be set on the Document';
                TableRelation = "Country/Region";

                trigger OnValidate()
                begin
                    SetCountryRegionCode(CountryRegionCode, CountryRegionCode);
                end;
            }
        }
    }
    var
        ShowPaymentTerms: Boolean;
        CountryRegionCode: Code[10];
        OIOUBLGLN: Code[13];
        PaymentTermsCode: Code[10];
        Contact: Text[100];
        VATRegNo: Text[20];

    [Obsolete('Procedure GetDocument with additional parameter will be used instead.', 'NPR26.0')]
    procedure GetDocument(CustomerNo: Code[20]; PaymentTermsVisible: Boolean)
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        ShowPaymentTerms := PaymentTermsVisible;
        if (VATRegNo = '') then
            VATRegNo := Customer."VAT Registration No.";
        if (OIOUBLGLN = '') then
            OIOUBLGLN := Customer.GLN;
        if (PaymentTermsCode = '') then
            PaymentTermsCode := Customer."Payment Terms Code";
        if (Contact = '') then
            Contact := Customer.Contact;
    end;

    procedure GetDocument(CustomerNo: Code[20]; CountryRegCode: Code[10]; PaymentTermsVisible: Boolean)
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        ShowPaymentTerms := PaymentTermsVisible;
        if (VATRegNo = '') then
            VATRegNo := Customer."VAT Registration No.";
        if (OIOUBLGLN = '') then
            OIOUBLGLN := Customer.GLN;
        if (PaymentTermsCode = '') then
            PaymentTermsCode := Customer."Payment Terms Code";
        if (Contact = '') then
            Contact := Customer.Contact;
        if CountryRegCode <> '' then
            CountryRegionCode := CountryRegCode
        else
            CountryRegionCode := Customer."Country/Region Code";
    end;

    [Obsolete('Procedure SetDocument with additional parameter will be used instead.', 'NPR26.0')]
    procedure SetDocument(var SetVATRegNo: Text[20]; var SetOIOUBLGLN: Code[13]; var SetPaymentTermsCode: Code[10]; var SetContact: Text[100])
    begin
        SetVATRegNo := VATRegNo;
        SetOIOUBLGLN := OIOUBLGLN;
        SetPaymentTermsCode := PaymentTermsCode;
        SetContact := Contact;
    end;

    procedure SetDocument(var SetVATRegNo: Text[20]; var SetOIOUBLGLN: Code[13]; var SetPaymentTermsCode: Code[10]; var SetContact: Text[100]; var SetCountryRegCode: Code[10])
    begin
        SetVATRegNo := VATRegNo;
        SetOIOUBLGLN := OIOUBLGLN;
        SetPaymentTermsCode := PaymentTermsCode;
        SetContact := Contact;
        SetCountryRegionCode(SetCountryRegCode, CountryRegionCode);
    end;

    local procedure SetCountryRegionCode(var ToValue: Code[10]; FromValue: Code[10])
    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
        InvalidContryRegionCodeErrLbl: Label 'To change the Country/Region Code on the document, the customer''s specified Country/Region Code must match the one in the Company Information.';
    begin
        if FromValue = '' then begin
            ToValue := FromValue;
            exit;
        end;

        CompanyInformation.Get();
        CountryRegion.Get(FromValue);

        if (CountryRegion.Code <> CompanyInformation."Country/Region Code") and (CompanyInformation."Country/Region Code" <> '') then
            Error(InvalidContryRegionCodeErrLbl);

        ToValue := FromValue;
    end;
}