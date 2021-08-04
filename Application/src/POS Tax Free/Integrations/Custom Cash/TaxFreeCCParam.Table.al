table 6014592 "NPR Tax Free CC Param."
{
    Caption = 'Tax Free Custom Cash Parameters';
    DataClassification = ToBeClassified;
    DrillDownPageId = "NPR Tax Free CC Param.";
    LookupPageId = "NPR Tax Free CC Param.";
    fields
    {
        field(1; "Tax Free POS Unit Code"; Code[10])
        {
            Caption = 'Tax Free POS Unit Code';
            TableRelation = "NPR Tax Free POS Unit"."POS Unit No.";
            DataClassification = CustomerContent;
        }
        field(2; "Shop User Name"; Text[50])
        {
            Caption = 'Shop User Name';
            DataClassification = CustomerContent;
        }
        field(3; "Shop Password"; Text[50])
        {
            Caption = 'Shop Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
            trigger OnValidate()
            begin
                InsertPassword()
            end;
        }
        field(4; "X Auth Token"; Text[50])
        {
            Caption = 'X Auth Token';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
            trigger OnValidate()
            begin
                InsertXAuth();
            end;
        }
        field(5; "Shop ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Shop ID';
        }
        field(10; "Shop Password GUID"; Guid)
        {
            Caption = 'Shop Password GUID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "X Auth Token GUID"; Guid)
        {
            Caption = 'X Auth Token GUID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Minimal Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Minimal Amount';
            MinValue = 0;
        }
        field(13; "Maximal Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Maximal Amount';
            MinValue = 0;
        }
    }
    keys
    {
        key(PK; "Tax Free POS Unit Code")
        {
            Clustered = true;
        }
    }
    [NonDebuggable]
    local procedure InsertPassword()
    begin
        if IsNullGuid("Shop Password GUID") then
            "Shop Password GUID" := CreateGuid();

        if IsolatedStorage.Contains("Shop Password GUID") then
            IsolatedStorage.Delete("Shop Password GUID");

        if not EncryptionEnabled() then
            IsolatedStorage.Set("Shop Password GUID", "Shop Password")
        else
            IsolatedStorage.SetEncrypted("Shop Password GUID", "Shop Password");

        "Shop Password" := '*';
    end;

    [NonDebuggable]
    procedure GetPassword() Pass: Text
    begin
        TestField("Shop Password");
        IsolatedStorage.Get("Shop Password GUID", Pass)
    end;

    [NonDebuggable]
    local procedure InsertXAuth()
    begin
        if IsNullGuid("Shop Password GUID") then
            "X Auth Token GUID" := CreateGuid();

        if IsolatedStorage.Contains("X Auth Token GUID") then
            IsolatedStorage.Delete("X Auth Token GUID");

        if not EncryptionEnabled() then
            IsolatedStorage.Set("X Auth Token GUID", "X Auth Token")
        else
            IsolatedStorage.SetEncrypted("X Auth Token GUID", "X Auth Token");

        "X Auth Token" := '*';
    end;

    [NonDebuggable]
    procedure GetXAuth() XAutTok: Text
    begin
        TestField("X Auth Token");
        IsolatedStorage.Get("X Auth Token GUID", XAutTok)
    end;
}
