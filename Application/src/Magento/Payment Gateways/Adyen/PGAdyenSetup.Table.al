table 6151466 "NPR PG Adyen Setup"
{
    Access = Internal;
    Caption = 'Payment Gateway Adyen Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Magento Payment Gateway";
        }
        field(2; Environment; Option)
        {
            Caption = 'Environment';
            DataClassification = CustomerContent;
            OptionMembers = Test,Production;
            OptionCaption = 'Test,Production';
        }
        field(6; "API Username"; Text[100])
        {
            Caption = 'Api Username';
            DataClassification = CustomerContent;
        }
        field(9; "API Password IS Key"; Guid)
        {
            Caption = 'Api Password Key';
            Access = Protected;
            DataClassification = CustomerContent;
        }
        field(15; "Merchant Name"; Text[50])
        {
            Caption = 'Merchant Name';
            DataClassification = CustomerContent;
        }
        field(16; "API URL Prefix"; Text[250])
        {
            Caption = 'API Url Prefix';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    var
        UnsupportedEnvironmentErr: Label 'The environment (%1) provided is not supported', Comment = '%1 = environment type';



    [NonDebuggable]
    internal procedure GetApiPassword() PasswordValue: Text
    begin
        IsolatedStorage.Get("API Password IS Key", DataScope::Company, PasswordValue);
    end;

    [NonDebuggable]
    internal procedure SetAPIPassword(NewPassword: Text)
    begin
        if (IsNullGuid(Rec."API Password IS Key")) then
            Rec."API Password IS Key" := CreateGuid();

        if (EncryptionEnabled()) then
            IsolatedStorage.SetEncrypted(Rec."API Password IS Key", NewPassword, DataScope::Company)
        else
            IsolatedStorage.Set(Rec."API Password IS Key", NewPassword, DataScope::Company);
    end;

    internal procedure DeleteAPIPassword()
    begin
        if (IsNullGuid(Rec."API Password IS Key")) then
            exit;

        IsolatedStorage.Delete(Rec."API Password IS Key", DataScope::Company);
    end;

    internal procedure HasAPIPassword(): Boolean
    begin
        if (IsNullGuid(Rec."API Password IS Key")) then
            exit(false);

        exit(IsolatedStorage.Contains(Rec."API Password IS Key", DataScope::Company));
    end;

    internal procedure GetAPIBaseUrl(): Text
    begin
        case Rec.Environment of
            Rec.Environment::Test:
                exit('https://pal-test.adyen.com/pal/servlet/Payment/V49/');
            Rec.Environment::Production:
                begin
                    Rec.TestField("API URL Prefix");
                    exit(StrSubstNo('https://%1-pal-live.adyenpayments.com/pal/servlet/Payment/V49/', Rec."API URL Prefix"));
                end;
            else
                Error(UnsupportedEnvironmentErr, Format(Rec.Environment));
        end;
    end;

    internal procedure GetAPIPayByLinkUrl(): Text
    begin
        case Rec.Environment of
            Rec.Environment::Test:
                exit('https://checkout-test.adyen.com/v71/paymentLinks');
            Rec.Environment::Production:
                begin
                    Rec.TestField("API URL Prefix");
                    exit(StrSubstNo('https://%1-checkout-live.adyenpayments.com/checkout/v71/paymentLinks', Rec."API URL Prefix"));
                end;
            else
                Error(UnsupportedEnvironmentErr, Format(Rec.Environment));
        end;
    end;
}