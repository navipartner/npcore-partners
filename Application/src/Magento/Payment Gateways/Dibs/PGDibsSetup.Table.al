table 6151467 "NPR PG Dibs Setup"
{
    Access = Internal;
    Caption = 'Magento Payment Gateway Dibs Setup';
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
        field(5; "Api Url"; Text[250])
        {
            Caption = 'Api Url';
            DataClassification = CustomerContent;
        }
        field(6; "Api Username"; Text[100])
        {
            Caption = 'Api Username';
            DataClassification = CustomerContent;
        }
        field(9; "Api Password Key"; Guid)
        {
            Caption = 'Api Password Key';
            Access = Protected;
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
    internal procedure GetApiPassword() PasswordValue: Text
    begin
        IsolatedStorage.Get("Api Password Key", DataScope::Company, PasswordValue);
    end;

    [NonDebuggable]
    internal procedure SetApiPassword(NewPassword: Text)
    begin
        if (IsNullGuid(Rec."Api Password Key")) then
            Rec."Api Password Key" := CreateGuid();

        if (EncryptionEnabled()) then
            IsolatedStorage.SetEncrypted(Rec."Api Password Key", NewPassword, DataScope::Company)
        else
            IsolatedStorage.Set(Rec."Api Password Key", NewPassword, DataScope::Company);
    end;

    internal procedure DeleteApiPassword()
    begin
        if (IsNullGuid(Rec."Api Password Key")) then
            exit;

        IsolatedStorage.Delete(Rec."Api Password Key", DataScope::Company);
    end;

    internal procedure HasApiPassword(): Boolean
    begin
        if (IsNullGuid(Rec."Api Password Key")) then
            exit(false);

        exit(IsolatedStorage.Contains(Rec."Api Password Key", DataScope::Company));
    end;
}