table 6150840 "NPR AT SCU"
{
    Access = Internal;
    Caption = 'AT Signature Creation Unit';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR AT SCUs";
    LookupPageId = "NPR AT SCUs";

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
        field(20; "AT Organization Code"; Code[20])
        {
            Caption = 'AT Organization Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR AT Organization";

            trigger OnValidate()
            begin
                if "AT Organization Code" <> xRec."AT Organization Code" then begin
                    TestField("Pending At", 0DT);
                    TestField("Created At", 0DT);

                    if "AT Organization Code" <> '' then
                        IsThereAnyOtherActiveSCUForThisOrganization();
                end;
            end;
        }
        field(30; State; Enum "NPR AT SCU State")
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(35; "Certificate Serial Number"; Text[100])
        {
            Caption = 'Certificate Serial Number';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "Pending At"; DateTime)
        {
            Caption = 'Pending At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Initialized At"; DateTime)
        {
            Caption = 'Initialized At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(70; "Decommissioned At"; DateTime)
        {
            Caption = 'Decommissioned At';
            DataClassification = CustomerContent;
            Editable = false;
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
        SystemId := CreateGuid();
    end;

    trigger OnDelete()
    var
        ATCashRegister: Record "NPR AT Cash Register";
        CannotDeleteErr: Label 'You cannot delete %1 %2 since there is at least one related %3 which has been already created at Fiskaly. You must delete this record(s) first.', Comment = '%1 - AT SCU table caption, %2 - AT SCU Code field value, %3 - AT Cash Register table caption';
        DeleteConfirmQst: Label 'Are you sure that you want to delete %1 %2 since it has been already sent to Fiskaly and it can cause data discrepancy?', Comment = '%1 - AT SCU table caption, %2 - AT SCU Code field value';
    begin
        ATCashRegister.SetRange("AT SCU Code", Code);
        ATCashRegister.SetFilter("Created At", '<>%1', 0DT);
        if not ATCashRegister.IsEmpty() then
            Error(CannotDeleteErr, TableCaption(), Code, ATCashRegister.TableCaption());

        if ("Pending At" <> 0DT) or ("Created At" <> 0DT) then
            if not Confirm(StrSubstNo(DeleteConfirmQst, TableCaption(), Code), false) then
                Error('');
    end;

    trigger OnRename()
    var
        CannotRenameErr: Label 'You cannot rename a %1 %2 since it has been already sent to Fiskaly and it can cause data discrepancy.', Comment = '%1 - AT SCU table caption, %2 - AT SCU Code field value';
    begin
        if ("Pending At" <> 0DT) or ("Created At" <> 0DT) then
            Error(CannotRenameErr, TableCaption(), Code);
    end;

    internal procedure GetWithCheck(ATSCUCode: Code[20])
    begin
        Get(ATSCUCode);
        TestField(State, State::INITIALIZED);
    end;

    internal procedure IsThereAnyOtherActiveSCUForThisOrganization()
    var
        ATSCU: Record "NPR AT SCU";
        OtherActiveSCUExistsErr: Label '%1 %2 is already assigned to active %3 %4.', Comment = '%1 - AT Organization Code field caption, %2 - AT Organization Code field value, %3 - table caption, %4 - Active AT SCU Code field value';
    begin
        ATSCU.SetFilter(Code, '<>%1', Code);
        ATSCU.SetRange("AT Organization Code", "AT Organization Code");
        ATSCU.SetFilter(State, '%1|%2|%3|%4', State::PENDING, State::CREATED, State::INITIALIZED, State::OUTAGE);
        if ATSCU.FindFirst() then
            Error(OtherActiveSCUExistsErr, FieldCaption("AT Organization Code"), "AT Organization Code", TableCaption(), ATSCU.Code);
    end;
}