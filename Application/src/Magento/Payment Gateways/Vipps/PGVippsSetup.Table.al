table 6059841 "NPR PG Vipps Setup"
{
    Access = Internal;
    Caption = 'Vipps Setup';
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

        field(6; Environment; Option)
        {
            Caption = 'Environment';
            DataClassification = CustomerContent;
            OptionMembers = Test,Production;
            OptionCaption = 'Test,Production';
        }

        field(3; "Merchant Serial Number"; Text[50])
        {
            Caption = 'Merchant Serial Number';
            DataClassification = CustomerContent;
        }

        field(2; "Ocp-Apim-Subscription-Key Key"; Guid)
        {
            Caption = 'Ocp-Apim-Subscription-Key';
            DataClassification = CustomerContent;
            Access = Protected;
        }

        field(4; "API Client ID"; Text[50])
        {
            Caption = 'API Client ID';
            DataClassification = CustomerContent;
        }

        field(5; "API Client Secret Key"; Guid)
        {
            Caption = 'API Client Secret';
            DataClassification = CustomerContent;
            Access = Protected;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    var
        ValueMissingErr: Label 'A value for field %1 must be specified on %2', Comment = '%1 = field caption, %2 = vipps setup table caption';

    [NonDebuggable]
    procedure SetOcpApimSubscriptionKey(NewKey: Text)
    begin
        if (IsNullGuid(Rec."Ocp-Apim-Subscription-Key Key")) then
            Rec."Ocp-Apim-Subscription-Key Key" := CreateGuid();

        if (EncryptionEnabled()) then
            IsolatedStorage.SetEncrypted(Rec."Ocp-Apim-Subscription-Key Key", NewKey, DataScope::Company)
        else
            IsolatedStorage.Set(Rec."Ocp-Apim-Subscription-Key Key", NewKey, DataScope::Company);
    end;

    internal procedure HasOcpApimSubscriptionKey(): Boolean
    begin
        if (IsNullGuid(Rec."Ocp-Apim-Subscription-Key Key")) then
            exit(false);

        exit(IsolatedStorage.Contains(Rec."Ocp-Apim-Subscription-Key Key", DataScope::Company));
    end;

    [NonDebuggable]
    procedure GetOcpApimSubscriptionKey() KeyValue: Text
    begin
        if (IsNullGuid(Rec."Ocp-Apim-Subscription-Key Key")) then
            exit('');

        if (IsolatedStorage.Get(Rec."Ocp-Apim-Subscription-Key Key", DataScope::Company, KeyValue)) then;
    end;

    procedure RemoveOcpApimSubscriptionKey()
    begin
        if (IsNullGuid(Rec."Ocp-Apim-Subscription-Key Key")) then
            exit;

        Clear(Rec."Ocp-Apim-Subscription-Key Key");
        IsolatedStorage.Delete(Rec."Ocp-Apim-Subscription-Key Key", DataScope::Company);
    end;

    internal procedure VerifyHasOcpApimSubscriptionKey()
    begin
        if (not HasOcpApimSubscriptionKey()) then
            Rec.FieldError(Rec."Ocp-Apim-Subscription-Key Key", StrSubstNo(ValueMissingErr, Rec.FieldCaption("Ocp-Apim-Subscription-Key Key"), Rec.TableCaption()));
    end;

    [NonDebuggable]
    procedure SetAPIClientSecret(NewSecret: Text)
    begin
        if (IsNullGuid(Rec."API Client Secret Key")) then
            Rec."API Client Secret Key" := CreateGuid();

        if (EncryptionEnabled()) then
            IsolatedStorage.SetEncrypted(Rec."API Client Secret Key", NewSecret, DataScope::Company)
        else
            IsolatedStorage.Set(Rec."API Client Secret Key", NewSecret, DataScope::Company);
    end;

    internal procedure HasAPIClientSecret(): Boolean
    begin
        if (IsNullGuid(Rec."API Client Secret Key")) then
            exit(false);

        exit(IsolatedStorage.Contains(Rec."API Client Secret Key", DataScope::Company));
    end;

    [NonDebuggable]
    procedure GetAPIClientSecret() Secret: Text
    begin
        if (IsNullGuid(Rec."API Client Secret Key")) then
            exit('');

        if (IsolatedStorage.Get(Rec."API Client Secret Key", DataScope::Company, Secret)) then;
    end;

    procedure RemoveAPIClientSecret()
    begin
        if (IsNullGuid(Rec."API Client Secret Key")) then
            exit;

        Clear(Rec."API Client Secret Key");
        IsolatedStorage.Delete(Rec."API Client Secret Key", DataScope::Company);
    end;

    internal procedure VerifyHasAPIClientSecret()
    begin
        if (not HasAPIClientSecret()) then
            Rec.FieldError(Rec."API Client Secret Key", StrSubstNo(ValueMissingErr, Rec.FieldCaption("API Client Secret Key"), Rec.TableCaption()));
    end;
}