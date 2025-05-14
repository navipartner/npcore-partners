table 6150972 "NPR NP Pay POS Payment Setup"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR NP Pay POS Payment Setups";
    LookupPageId = "NPR NP Pay POS Payment Setups";
    Extensible = false;
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; "Encryption Key Id"; Text[100])
        {
            Caption = 'Encryption Key ID';
            DataClassification = CustomerContent;
        }
        field(3; "Encryption Key Version"; Integer)
        {
            Caption = 'Encryption Key Version';
            DataClassification = CustomerContent;
        }
        field(4; "Encryption Key Password"; Text[100])
        {
            Caption = 'Encryption Key Password';
            DataClassification = CustomerContent;
        }
        field(5; "Payment API Key"; Text[500])
        {
            Caption = 'Payment API Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-05-11';
            ObsoleteReason = 'Replaced with Isolated Storage API Key Token';
        }
        field(6; "Merchant Account"; Text[50])
        {
            Caption = 'Merchant Account';
            DataClassification = CustomerContent;
        }
        field(7; Environment; Option)
        {
            Caption = 'Environment';
            DataClassification = CustomerContent;
            OptionMembers = "Test","Live";
            InitValue = Live;
        }
        field(8; "API Key Token"; Guid)
        {
            Caption = 'API Key Token';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }

    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
    begin
        DeleteAPIKey();
    end;

    [NonDebuggable]
    internal procedure GetApiKey() ApiKeyValue: Text
    begin
        IsolatedStorage.Get("API Key Token", DataScope::Company, ApiKeyValue);
    end;

    [NonDebuggable]
    internal procedure SetAPIKey(NewApiKeyValue: Text)
    begin
        if (IsNullGuid(Rec."API Key Token")) then
            Rec."API Key Token" := CreateGuid();

        if (EncryptionEnabled()) then
            IsolatedStorage.SetEncrypted(Rec."API Key Token", NewApiKeyValue, DataScope::Company)
        else
            IsolatedStorage.Set(Rec."API Key Token", NewApiKeyValue, DataScope::Company);
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
}