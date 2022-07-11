table 6014687 "NPR DE TSS"
{
    Access = Internal;
    Caption = 'DE Technical Security System';
    DataClassification = CustomerContent;
    LookupPageId = "NPR DE TSS List";
    DrillDownPageId = "NPR DE TSS List";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Connection Parameter Set Code"; Code[10])
        {
            Caption = 'Connection Parameter Set Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR DE Audit Setup";

            trigger OnValidate()
            begin
                if "Connection Parameter Set Code" <> xRec."Connection Parameter Set Code" then
                    TestField("Fiskaly TSS Created at", 0DT);
            end;
        }
        field(100; "Fiskaly TSS Created at"; DateTime)
        {
            Caption = 'Fiskaly TSS Created at';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(101; "Fiskaly TSS State"; Enum "NPR DE TSS State")
        {
            Caption = 'Last Known Fiskaly State';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    procedure AdminPUKSecretLbl(): Text
    begin
        if IsNullGuid(SystemId) then
            exit('');
        exit('DEFiskalyTSSAdminPUK_' + SystemId);
    end;

    procedure AdminPINSecretLbl(): Text
    begin
        if IsNullGuid(SystemId) then
            exit('');
        exit('DEFiskalyTSSAdminPIN_' + SystemId);
    end;
}