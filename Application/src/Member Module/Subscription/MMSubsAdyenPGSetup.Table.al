table 6150962 "NPR MM Subs Adyen PG Setup"
{
    Access = Internal;
    Caption = 'Subscriptions Adyen Payment Gateway Setup';
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
        field(2; Environment; Enum "NPR MM Subs Adyen PG Env Type")
        {
            Caption = 'Environment';
            DataClassification = CustomerContent;
        }
        field(3; "API Key Token"; Guid)
        {
            Caption = 'API Key';
            Access = Protected;
            DataClassification = CustomerContent;
        }
        field(4; "Merchant Name"; Text[50])
        {
            Caption = 'Merchant Name';
            DataClassification = CustomerContent;
        }
        field(5; "API URL Prefix"; Text[250])
        {
            Caption = 'API Url Prefix';
            DataClassification = CustomerContent;
        }
        field(6; "Card Update by Pay by Link"; Boolean)
        {
            Caption = 'Card Update by Pay by Link';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-02-27';
            ObsoleteReason = 'Not used.';
        }
        field(7; "Pay By Link Exp. Duration"; Duration)
        {
            Caption = 'Pay by Link Expiration';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CheckExpDuration("Pay By Link Exp. Duration");
            end;
        }
        field(10; "Payment Account Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Account Type';
            ValuesAllowed = "G/L Account", "Bank Account";
        }
        field(11; "Payment Account No."; Code[20])
        {
            Caption = 'Payment Account No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Payment Account Type" = const("G/L Account")) "G/L Account" else if ("Payment Account Type" = const("Bank Account")) "Bank Account";
        }
        field(12; "Pay by Link Rec Proc Model"; Enum "NPR MM SubsAdyenRecProcModel")
        {
            Caption = 'Pay by Link Recurring Processing Model';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
    trigger OnDelete()
    begin
        DeleteAPIKey();
    end;

    [NonDebuggable]
    internal procedure GetApiKey() PasswordValue: Text
    begin
        IsolatedStorage.Get("API Key Token", DataScope::Company, PasswordValue);
    end;

    [NonDebuggable]
    internal procedure SetAPIKey(NewPassword: Text)
    begin
        if (IsNullGuid(Rec."API Key Token")) then
            Rec."API Key Token" := CreateGuid();

        if (EncryptionEnabled()) then
            IsolatedStorage.SetEncrypted(Rec."API Key Token", NewPassword, DataScope::Company)
        else
            IsolatedStorage.Set(Rec."API Key Token", NewPassword, DataScope::Company);
    end;

    internal procedure DeleteAPIKey()
    begin
        if (IsNullGuid(Rec."API Key Token")) then
            exit;

        IsolatedStorage.Delete(Rec."API Key Token", DataScope::Company);
    end;

    internal procedure HasAPIKey(): Boolean
    begin
        if (IsNullGuid(Rec."API Key Token")) then
            exit(false);

        exit(IsolatedStorage.Contains(Rec."API Key Token", DataScope::Company));
    end;

    internal procedure GetAPIPaymentsURL(): Text
    var
        UnsupportedEnvironmentErr: Label 'The environment (%1) provided is not supported', Comment = '%1 = environment type';
    begin
        case Rec.Environment of
            Rec.Environment::Test:
                exit('https://checkout-test.adyen.com/v71/payments');
            Rec.Environment::Production:
                begin
                    Rec.TestField("API URL Prefix");
                    exit(StrSubstNo('https://%1-checkout-live.adyenpayments.com/checkout/v71/payments', Rec."API URL Prefix"));
                end;
            else
                Error(UnsupportedEnvironmentErr, Format(Rec.Environment));
        end;
    end;

    [TryFunction]
    internal procedure TryGetAPIPaymentsURL(var Url: Text)
    begin
        Url := GetAPIPaymentsURL();
    end;

    procedure CheckExpDuration(ExpDuration: Duration)
    var
        MaxDurationTxt: Text;
        MaxDuration: Duration;
        ExperationErr: Label 'The expiration duration cannot be more than %1';
    begin
        MaxDurationTxt := '70 days';
        Evaluate(MaxDuration, MaxDurationTxt);

        if ExpDuration > MaxDuration then
            Error(ExperationErr, MaxDurationTxt);
    end;

    internal procedure GetAPIPayByLinkUrl(): Text
    var
        UnsupportedEnvironmentErr: Label 'The environment (%1) provided is not supported', Comment = '%1 = environment type';
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