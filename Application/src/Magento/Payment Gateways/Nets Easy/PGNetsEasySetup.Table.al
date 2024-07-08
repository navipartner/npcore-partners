table 6151470 "NPR PG Nets Easy Setup"
{
    Access = Internal;
    Caption = 'Payment Gateway EasyNets Setup';
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
        field(8; "Authorization Token IS Key"; Guid)
        {
            Caption = 'Authorization Token';
            DataClassification = CustomerContent;
            Access = Protected;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    var
        EnvironmentNotSupportedErr: Label 'The provided environment %1 is not supported by Nets Easy integration', Comment = '%1 = environment';
        AuthorizationTokenMissingErr: Label 'Authorization token is required but could not be obtained for Nets Easy Setup (Payment Gateway Code: %1).', Comment = 'Payment Gateway Code';

    [NonDebuggable]
    internal procedure GetAuthorizationToken() Token: Text
    begin
        if (IsNullGuid(Rec."Authorization Token IS Key")) then
            exit('');

        IsolatedStorage.Get(Rec."Authorization Token IS Key", DataScope::Company, Token);
    end;

    [NonDebuggable]
    internal procedure SetAuthorizationToken(NewToken: Text)
    begin
        if (IsNullGuid(Rec."Authorization Token IS Key")) then
            Rec."Authorization Token IS Key" := CreateGuid();

        if (EncryptionEnabled()) then
            IsolatedStorage.SetEncrypted(Rec."Authorization Token IS Key", NewToken, DataScope::Company)
        else
            IsolatedStorage.Set(Rec."Authorization Token IS Key", NewToken, DataScope::Company);
    end;

    internal procedure HasAuthorizationToken(): Boolean
    begin
        if (IsNullGuid(Rec."Authorization Token IS Key")) then
            exit(false);

        exit(IsolatedStorage.Contains(Rec."Authorization Token IS Key", DataScope::Company));
    end;

    internal procedure DeleteAuthorizationToken()
    begin
        if (IsNullGuid(Rec."Authorization Token IS Key")) then
            exit;

        IsolatedStorage.Delete(Rec."Authorization Token IS Key", DataScope::Company);
    end;

    internal procedure VerifyHasAuthorizationToken()
    begin
        if (not HasAuthorizationToken()) then
            Error(AuthorizationTokenMissingErr, Rec.Code);
    end;

    internal procedure GetBaseAPIUrl(): Text
    begin
        case Rec.Environment of
            Rec.Environment::Test:
                exit('https://test.api.dibspayment.eu/v1/');
            Rec.Environment::Production:
                exit('https://api.dibspayment.eu/v1/');
            else
                Error(EnvironmentNotSupportedErr, Format(Rec.Environment));
        end;
    end;
}
