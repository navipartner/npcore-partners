table 6059926 "NPR QR Code Setup Header"
{
    Access = Internal;
    Caption = 'QR Code Setup Header';
    DataClassification = CustomerContent;
    LookupPageId = "NPR QR Code Setup List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(40; "API Key Token"; Guid)
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
        field(60; "Integration Type"; Enum "NPR QRCode Integration Type")
        {
            Caption = 'Integration Type';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        TestField(Code);
    end;

    trigger OnDelete()
    var
        QRCodeSetupLine: Record "NPR QR Code Setup Line";
    begin
        QRCodeSetupLine.SetRange("QR Code Setup Header Code", Rec.Code);
        QRCodeSetupLine.DeleteAll();
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
        if Rec.Code = '' then
            exit;

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
