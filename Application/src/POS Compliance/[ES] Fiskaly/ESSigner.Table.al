table 6150887 "NPR ES Signer"
{
    Access = Internal;
    Caption = 'ES Signer';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR ES Signers";
    LookupPageId = "NPR ES Signers";

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
        field(20; "ES Organization Code"; Code[20])
        {
            Caption = 'ES Organization Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR ES Organization";

            trigger OnValidate()
            begin
                if "ES Organization Code" <> xRec."ES Organization Code" then begin
                    TestField(State, State::" ");

                    if "ES Organization Code" <> '' then
                        IsThereAnyOtherActiveSignerForThisOrganization();
                end;
            end;
        }
        field(30; State; Enum "NPR ES Signer State")
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "Certificate Serial Number"; Text[100])
        {
            Caption = 'Certificate Serial Number';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Certificate Expires At"; DateTime)
        {
            Caption = 'Certificate Expires At';
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
        ESClient: Record "NPR ES Client";
        ConfirmManagement: Codeunit "Confirm Management";
        CannotDeleteErr: Label 'You cannot delete %1 %2 since there is at least one related %3 which has been already created at Fiskaly. You must delete this record(s) first.', Comment = '%1 - ES Signer table caption, %2 - ES Signer Code field value, %3 - ES Client table caption';
        DeleteConfirmQst: Label 'Are you sure that you want to delete %1 %2 since it has been already sent to Fiskaly and it can cause data discrepancy?', Comment = '%1 - ES Signer table caption, %2 - ES Signer Code field value';
    begin
        ESClient.SetRange("ES Signer Code", Code);
        ESClient.SetFilter(State, '<>%1', ESClient.State::" ");
        if not ESClient.IsEmpty() then
            Error(CannotDeleteErr, TableCaption(), Code, ESClient.TableCaption());

        if State <> State::" " then
            if not ConfirmManagement.GetResponse(StrSubstNo(DeleteConfirmQst, TableCaption(), Code), false) then
                Error('');
    end;

    trigger OnRename()
    var
        CannotRenameErr: Label 'You cannot rename a %1 %2 since it has been already sent to Fiskaly and it can cause data discrepancy.', Comment = '%1 - ES Signer table caption, %2 - ES Signer Code field value';
    begin
        if State <> State::" " then
            Error(CannotRenameErr, TableCaption(), Code);
    end;

    internal procedure GetWithCheck(ESSignerCode: Code[20])
    begin
        Get(ESSignerCode);
        TestField(State, State::ENABLED);
    end;

    internal procedure IsThereAnyOtherActiveSignerForThisOrganization()
    var
        ESSigner: Record "NPR ES Signer";
        OtherActiveSCUExistsErr: Label '%1 %2 is already assigned to active %3 %4.', Comment = '%1 - ES Organization Code field caption, %2 - ES Organization Code field value, %3 - table caption, %4 - Active ES Signer Code field value';
    begin
        ESSigner.SetFilter(Code, '<>%1', Code);
        ESSigner.SetRange("ES Organization Code", "ES Organization Code");
        ESSigner.SetRange(State, State::ENABLED);
        if ESSigner.FindFirst() then
            Error(OtherActiveSCUExistsErr, FieldCaption("ES Organization Code"), "ES Organization Code", TableCaption(), ESSigner.Code);
    end;
}