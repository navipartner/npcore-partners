table 6150890 "NPR ES Client"
{
    Access = Internal;
    Caption = 'ES Client';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR ES Clients";
    LookupPageId = "NPR ES Clients";

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Unit";

            trigger OnValidate()
            var
                POSUnit: Record "NPR POS Unit";
            begin
                if "POS Unit No." <> xRec."POS Unit No." then begin
                    Clear(Description);
                    if POSUnit.Get("POS Unit No.") then
                        Description := POSUnit.Name;
                end;
            end;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "ES Organization Code"; Code[20])
        {
            Caption = 'ES Organization Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR ES Organization";

            trigger OnValidate()
            begin
                if "ES Organization Code" <> xRec."ES Organization Code" then
                    TestField(State, State::" ");
            end;
        }
        field(30; State; Enum "NPR ES Client State")
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "ES Signer Code"; Code[20])
        {
            Caption = 'ES Signer Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "NPR ES Signer";
        }
        field(41; "ES Signer Id"; Guid)
        {
            Caption = 'ES Signer Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Invoice No. Series"; Code[20])
        {
            Caption = 'Invoice No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(51; "Complete Invoice No. Series"; Code[20])
        {
            Caption = 'Complete Invoice No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(52; "Correction Invoice No. Series"; Code[20])
        {
            Caption = 'Correction Invoice No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "POS Unit No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        SystemId := CreateGuid();
    end;

    trigger OnDelete()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        DeleteConfirmQst: Label 'Are you sure that you want to delete %1 %2 since it has been already created at Fiskaly and it can cause data discrepancy?', Comment = '%1 - ES Client table caption, %2 - POS Unit Number field value';
    begin
        if State <> State::" " then
            if not ConfirmManagement.GetResponse(StrSubstNo(DeleteConfirmQst, TableCaption(), "POS Unit No."), false) then
                Error('');
    end;

    trigger OnRename()
    var
        CannotRenameErr: Label 'You cannot rename a %1 %2 since it has been already created at Fiskaly and it can cause data discrepancy.', Comment = '%1 - ES Client table caption, %2 - POS Unit Number field value';
    begin
        if State <> State::" " then
            Error(CannotRenameErr, TableCaption(), "POS Unit No.");
    end;

    internal procedure GetWithCheck(POSUnitNo: Code[10])
    begin
        Get(POSUnitNo);
        TestField(State, State::ENABLED);
    end;
}