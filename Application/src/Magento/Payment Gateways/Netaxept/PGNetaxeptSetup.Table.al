table 6151469 "NPR PG Netaxept Setup"
{
    Access = Internal;
    Caption = 'Magento Payment Gateway Netaxept Setup';
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
        field(5; Environment; Option)
        {
            Caption = 'Environment';
            OptionMembers = Test,Production;
            OptionCaption = 'Test,Production';
            DataClassification = CustomerContent;
        }
        field(9; "Api Access Token Key"; Guid)
        {
            Caption = 'Api Password Key';
            Access = Protected;
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
    internal procedure GetApiAccessToken() Token: Text
    begin
        IsolatedStorage.Get("Api Access Token Key", DataScope::Company, Token);
    end;

    [NonDebuggable]
    internal procedure SetApiAccessToken(NewToken: Text)
    begin
        if (IsNullGuid(Rec."Api Access Token Key")) then
            Rec."Api Access Token Key" := CreateGuid();

        if (EncryptionEnabled()) then
            IsolatedStorage.SetEncrypted(Rec."Api Access Token Key", NewToken, DataScope::Company)
        else
            IsolatedStorage.Set(Rec."Api Access Token Key", NewToken, DataScope::Company);
    end;

    internal procedure DeleteApiAccessToken()
    begin
        if (IsNullGuid(Rec."Api Access Token Key")) then
            exit;

        IsolatedStorage.Delete(Rec."Api Access Token Key", DataScope::Company);
    end;

    internal procedure HasApiAccessToken(): Boolean
    begin
        if (IsNullGuid(Rec."Api Access Token Key")) then
            exit(false);

        exit(IsolatedStorage.Contains(Rec."Api Access Token Key", DataScope::Company));
    end;
}
