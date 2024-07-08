table 6151472 "NPR PG Bambora Setup"
{
    Access = Internal;
    Caption = 'Magento Payment Gateway Bambora Setup';
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
        field(6; "Access Token"; Text[100])
        {
            Caption = 'Access Token';
            DataClassification = CustomerContent;
        }
        field(9; "Secret Token Key"; Guid)
        {
            Caption = 'Secret Token';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10; "Merchant ID"; Code[20])
        {
            Caption = 'Merchant Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    [NonDebuggable]
    internal procedure SetSecretToken(NewSecretToken: Text)
    begin
        if (IsNullGuid(Rec."Secret Token Key")) then
            Rec."Secret Token Key" := CreateGuid();

        if (EncryptionEnabled()) then
            IsolatedStorage.SetEncrypted(Rec."Secret Token Key", NewSecretToken, DataScope::Company)
        else
            IsolatedStorage.Set(Rec."Secret Token Key", NewSecretToken, DataScope::Company);
    end;

    [NonDebuggable]
    internal procedure GetSecretToken() Token: Text
    begin
        IsolatedStorage.Get(Rec."Secret Token Key", DataScope::Company, Token);
    end;

    internal procedure DeleteSecretToken()
    begin
        if (IsNullGuid(Rec."Secret Token Key")) then
            exit;

        IsolatedStorage.Delete(Rec."Secret Token Key", DataScope::Company);
    end;

    internal procedure HasSecretToken(): Boolean
    begin
        exit(IsolatedStorage.Contains(Rec."Secret Token Key", DataScope::Company));
    end;

}
