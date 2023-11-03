table 6150693 "NPR PG Stripe Setup"
{
    Access = Internal;
    Caption = 'Stripe Setup';
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

        field(5; "Live API Client Secret Key"; Guid)
        {
            Caption = 'API Client Secret';
            DataClassification = CustomerContent;
        }

        field(7; "Test API Client Secret Key"; Guid)
        {
            Caption = 'Test API Client Secret';
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

    var
        ValueMissingErr: Label 'A value for field %1 must be specified on %2', Comment = '%1 = field caption, %2 = vipps setup table caption';

    internal procedure VerifyHasAPISecretKeys(FieldNo: Integer)
    begin
        Case FieldNo of
            Rec.FieldNo("Live API Client Secret Key"):
                if (not HasSecret(Rec.FieldNo("Live API Client Secret Key"))) then
                    Rec.FieldError(Rec."Live API Client Secret Key", StrSubstNo(ValueMissingErr, Rec.FieldCaption("Live API Client Secret Key"), Rec.TableCaption()));
            Rec.FieldNo("Test API Client Secret Key"):
                if (not HasSecret(Rec.FieldNo("Test API Client Secret Key"))) then
                    Rec.FieldError(Rec."Test API Client Secret Key", StrSubstNo(ValueMissingErr, Rec.FieldCaption("Test API Client Secret Key"), Rec.TableCaption()));
        end;
    end;

    [NonDebuggable]
    procedure GetSecret(FieldNo: Integer) SecretValue: Text
    begin
        Case FieldNo of
            Rec.FieldNo("Live API Client Secret Key"):
                if not IsNullGuid(Rec."Live API Client Secret Key") then
                    if IsolatedStorage.Get("Live API Client Secret Key", DataScope::Company, SecretValue) then;
            Rec.FieldNo("Test API Client Secret Key"):
                if not IsNullGuid(Rec."Test API Client Secret Key") then
                    if IsolatedStorage.Get("Test API Client Secret Key", DataScope::Company, SecretValue) then;
        End;
    end;

    [NonDebuggable]
    procedure HasSecret(FieldNo: Integer): Boolean
    begin
        exit(GetSecret(FieldNo) <> '');
    end;

    procedure RemoveSecret(FieldNo: Integer)
    begin
        Case FieldNo of
            Rec.FieldNo("Live API Client Secret Key"):
                begin
                    IsolatedStorage.Delete("Live API Client Secret Key", DataScope::Company);
                    Clear("Live API Client Secret Key");
                end;
            Rec.FieldNo("Test API Client Secret Key"):
                begin
                    IsolatedStorage.Delete("Test API Client Secret Key", DataScope::Company);
                    Clear("Test API Client Secret Key");
                end;
        End;
    end;

    [NonDebuggable]
    local procedure SetSecret(SecretKey: Text; NewSecretValue: Text)
    begin
        if not EncryptionEnabled() or (StrLen(NewSecretValue) > 150) then
            IsolatedStorage.Set(SecretKey, NewSecretValue, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted(SecretKey, NewSecretValue, DataScope::Company);

    end;

    [NonDebuggable]
    procedure SetSecret(FieldNo: Integer; NewSecretValue: Text)
    begin
        Case FieldNo of
            Rec.FieldNo("Live API Client Secret Key"):
                begin
                    if IsNullGuid("Live API Client Secret Key") then
                        Rec."Live API Client Secret Key" := CreateGuid();
                    SetSecret("Live API Client Secret Key", NewSecretValue);
                end;

            Rec.FieldNo("Test API Client Secret Key"):
                begin
                    if IsNullGuid("Test API Client Secret Key") then
                        Rec."Test API Client Secret Key" := CreateGuid();
                    SetSecret("Test API Client Secret Key", NewSecretValue);
                end;
        End;
    end;
}