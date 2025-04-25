table 6059877 "NPR Return Info Collect Setup"
{
    Access = Internal;
    Caption = 'Return Information Collection Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Collect Signature"; Boolean)
        {
            Caption = 'Collect Signature';
            DataClassification = CustomerContent;
        }
        field(20; "Collect Phone No."; Boolean)
        {
            Caption = 'Collect Phone No.';
            DataClassification = CustomerContent;
        }
        field(30; "Collect E-Mail"; Boolean)
        {
            Caption = 'Collect E-Mail';
            DataClassification = CustomerContent;
        }
        field(40; "Api Key Token"; Guid)
        {
            Caption = 'Api Key';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(50; Environment; Enum "NPR Adyen Environment Type")
        {
            Caption = 'Environment';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
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
