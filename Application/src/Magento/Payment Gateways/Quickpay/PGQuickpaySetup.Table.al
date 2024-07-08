table 6151471 "NPR PG Quickpay Setup"
{
    Access = Internal;
    Caption = 'Quickpay Setup';
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
        field(9; "Api Password Key"; Guid)
        {
            Caption = 'Api Password Key';
            Access = Protected;
            Editable = false;
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
        if (IsNullGuid(Rec."Api Password Key")) then
            exit('');

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

    internal procedure HasApiPassword(): Boolean
    begin
        exit(IsolatedStorage.Contains(Rec."Api Password Key", DataScope::Company));
    end;

    internal procedure DeleteApiPassword()
    begin
        IsolatedStorage.Delete(Rec."Api Password Key", DataScope::Company);
        Clear(Rec."Api Password Key");
    end;
}
