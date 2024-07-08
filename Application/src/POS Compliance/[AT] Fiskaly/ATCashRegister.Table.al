table 6150844 "NPR AT Cash Register"
{
    Access = Internal;
    Caption = 'AT Cash Register';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR AT Cash Registers";
    LookupPageId = "NPR AT Cash Registers";

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
        field(20; "AT SCU Code"; Code[20])
        {
            Caption = 'AT Signature Creation Unit Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR AT SCU";

            trigger OnValidate()
            begin
                if "AT SCU Code" <> xRec."AT SCU Code" then
                    TestField("Created At", 0DT);
            end;
        }
        field(30; State; Enum "NPR AT Cash Register State")
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(35; "Serial Number"; Text[100])
        {
            Caption = 'Serial Number';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Registered At"; DateTime)
        {
            Caption = 'Registered At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Initialized At"; DateTime)
        {
            Caption = 'Initialized At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(65; "Initialization Receipt Id"; Guid)
        {
            Caption = 'Initialization Receipt Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(70; "Decommissioned At"; DateTime)
        {
            Caption = 'Decommissioned At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75; "Decommission Receipt Id"; Guid)
        {
            Caption = 'Decommission Receipt Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(80; "Outage At"; DateTime)
        {
            Caption = 'Outage At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(90; "Defect At"; DateTime)
        {
            Caption = 'Defect At';
            DataClassification = CustomerContent;
            Editable = false;
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
        DeleteConfirmQst: Label 'Are you sure that you want to delete %1 %2 since it has been already created at Fiskaly and it can cause data discrepancy?', Comment = '%1 - AT Cash Register table caption, %2 - POS Unit Number field value';
    begin
        if "Created At" <> 0DT then
            if not Confirm(StrSubstNo(DeleteConfirmQst, TableCaption(), "POS Unit No."), false) then
                Error('');
    end;

    trigger OnRename()
    var
        CannotRenameErr: Label 'You cannot rename a %1 %2 since it has been already created at Fiskaly and it can cause data discrepancy.', Comment = '%1 - AT Cash Register table caption, %2 - POS Unit Number field value';
    begin
        if "Created At" <> 0DT then
            Error(CannotRenameErr, TableCaption(), "POS Unit No.");
    end;

    internal procedure GetWithCheck(POSUnitNo: Code[10])
    begin
        Get(POSUnitNo);
        TestField(State, State::INITIALIZED);
    end;
}