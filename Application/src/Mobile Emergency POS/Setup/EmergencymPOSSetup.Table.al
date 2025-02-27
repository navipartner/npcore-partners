table 6150955 "NPR Emergency mPOS Setup"
{
    Access = Internal;
    Extensible = False;
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Emergency mPOS Setup List";
    LookupPageId = "NPR Emergency mPOS Setup List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; "NP Pay POS Payment Setup"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR NP Pay POS Payment Setup";
        }
        field(3; "Cash Payment Method"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(4; "EFT Payment Method"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(5; "SMS Template"; Code[20])
        {
            Caption = 'SMS Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header";
        }
        field(6; "Email Template"; Code[20])
        {
            Caption = 'Email Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header";
        }
        field(7; "Salespers/Purchaser Code"; Code[20])
        {
            Caption = 'Salespers/Purchaser Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }

        field(8; "CSV Url"; Text[500])
        {
            Caption = 'CSV Url';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {

        }
    }

    internal procedure GetSetup(): Text
    var
        Setup: JsonObject;
        QrJson: Text;
        ManualPaymentMethods: JsonArray;
        EmergencyPOSPayMethods: Record "NPR Emergency POS Pay Methods";
        NPPayPOSPaymentSetup: Record "NPR NP Pay POS Payment Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        Company: Record Company;
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        GeneralLedgerSetup.FindFirst();
        NPPayPOSPaymentSetup.Get(Rec."NP Pay POS Payment Setup");
        Setup.Add('AdyenEncKeyId', NPPayPOSPaymentSetup."Encryption Key Id");
        Setup.Add('AdyenEncKeyVersion', NPPayPOSPaymentSetup."Encryption Key Version");
        Setup.Add('AdyenEncKeyPassphrase', NPPayPOSPaymentSetup."Encryption Key Password");
        Setup.Add('AdyenApiKey', NPPayPOSPaymentSetup."Payment API Key");
        Setup.Add('AdyenMerchantAccount', NPPayPOSPaymentSetup."Merchant Account");
        Setup.Add('AdyenEnvironment', Format(NPPayPOSPaymentSetup.Environment));
        POSPaymentMethod.Get(Rec."EFT Payment Method");
        //Backward compatible START
        Setup.Add('Payment_EftPaymentMethodCode', Rec."EFT Payment Method");
        Setup.Add('Payment_EftPaymentMethodMonetaryUnit', POSPaymentMethod."Rounding Precision");
        //Backward compatible END
        Setup.Add('Payment_EftPaymentMethod', CreatePosPaymentMethodObject(POSPaymentMethod));
        POSPaymentMethod.Get(Rec."Cash Payment Method");
        //Backward compatible START
        Setup.Add('Payment_CashPaymentMethodCode', Rec."Cash Payment Method");
        Setup.Add('Payment_CashPaymentMethodMonetaryUnit', POSPaymentMethod."Rounding Precision");
        //Backward compatible END
        Setup.Add('Payment_CashPaymentMethod', CreatePosPaymentMethodObject(POSPaymentMethod));
        EmergencyPOSPayMethods.SetFilter("Emergency POS Setup Code", Rec.Code);
        if (EmergencyPOSPayMethods.FindSet()) then begin
            repeat begin
                POSPaymentMethod.Get(EmergencyPOSPayMethods."POS Payment Method Code");
                ManualPaymentMethods.Add(CreatePosPaymentMethodObject(POSPaymentMethod));
            end until EmergencyPOSPayMethods.Next() = 0;
            Setup.Add('Payment_ManualPaymentMethods', ManualPaymentMethods);
        end;
        Setup.Add('Payment_Currency', GeneralLedgerSetup."LCY Code");

        if (EnvironmentInformation.IsOnPrem()) then begin
            Setup.Add('Bc_OnPremOdataV4WebServiceUrl', GetUrl(ClientType::ODataV4));
            Setup.Add('Bc_OnPremAPIWebServiceUrl', GetUrl(ClientType::Api));
            Setup.Add('Bc_ProductType', 'Buisness_Central_OnPrem');
            Setup.Add('Bc_AuthType', 'BasicAuth');
            Setup.Add('Bc_TenantId', TenantId());
        end else begin
            Setup.Add('Bc_ProductType', 'Buisness_Central_SaaS');
            Setup.Add('Bc_AuthType', 'OAuth');
            Setup.Add('Bc_TenantId', AzureADTenant.GetAadTenantId());
            Setup.Add('Bc_Environment', EnvironmentInformation.GetEnvironmentName());
        end;
        Company.Get(CurrentCompany());
        Setup.Add('Bc_Company', Company.Name);
        Setup.Add('Bc_CompanyId', Format(Company.Id).Replace('{', '').Replace('}', ''));
        Setup.Add('Bc_SMSTemplateCode', Rec."SMS Template");
        Setup.Add('Bc_EmailTemplateCode', Rec."Email Template");
        Setup.Add('Bc_SalesPersonCode', Rec."Salespers/Purchaser Code");
        Setup.Add('CSVUrl', Rec."CSV Url");
        Setup.WriteTo(QrJson);
        exit(QrJson);
    end;

    local procedure CreatePosPaymentMethodObject(POSPaymentMethod: Record "NPR POS Payment Method") PosPaymetnMethod: JsonObject
    begin
        PosPaymetnMethod.Add('Code', POSPaymentMethod.Code);
        PosPaymetnMethod.Add('Description', POSPaymentMethod.Description);
        PosPaymetnMethod.Add('MonetaryUnit', POSPaymentMethod."Rounding Precision");
        PosPaymetnMethod.Add('RoundingType', POSPaymentMethod."Rounding Type");
    end;
}