table 6150884 "NPR ES Organization"
{
    Access = Internal;
    Caption = 'ES Organization';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR ES Organization List";
    LookupPageId = "NPR ES Organization List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            begin
                if Code <> xRec.Code then
                    TestDisabled();
            end;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Description <> xRec.Description then
                    TestDisabled();
            end;
        }
        field(20; "Taxpayer Territory"; Enum "NPR ES Taxpayer Territory")
        {
            Caption = 'Taxpayer Territory';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Taxpayer Territory" <> xRec."Taxpayer Territory" then begin
                    TestDisabled();
                    if IsThereAnyRelatedSigner() then
                        ErrorIfThereIsAnyRelatedSigner();

                    Clear("Taxpayer Created");
                    Clear("Responsibility Declaration URL");
                end;
            end;
        }
        field(30; "Taxpayer Type"; Enum "NPR ES Taxpayer Type")
        {
            Caption = 'Taxpayer Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "Taxpayer Created"; Boolean)
        {
            Caption = 'Taxpayer Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; Disabled; Boolean)
        {
            Caption = 'Disabled';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Company Legal Name"; Text[100])
        {
            Caption = 'Company Legal Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(70; "Company Tax Number"; Text[9])
        {
            Caption = 'Company Tax Number';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(80; "Software Name"; Text[100])
        {
            Caption = 'Software Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(90; "Software License"; Text[20])
        {
            Caption = 'Software License';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(100; "Software Version"; Text[20])
        {
            Caption = 'Software Version';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(110; "Responsibility Declaration URL"; Text[250])
        {
            Caption = 'Responsibility Declaration URL';
            DataClassification = CustomerContent;
            Editable = false;
            ExtendedDatatype = URL;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        ESSigner: Record "NPR ES Signer";
        ConfirmManagement: Codeunit "Confirm Management";
        DeleteConfirmQst: Label 'Are you sure that you want to delete %1 %2 since it has been already sent to Fiskaly and it can cause data discrepancy?', Comment = '%1 - ES Organization table caption, %2 - ES Organization Code field value';
        CannotDeleteErr: Label 'You cannot delete %1 %2 since there is at least one related %3 which has been already sent to Fiskaly. You must delete this record(s) first.', Comment = '%1 - ES Organization table caption, %2 - ES Organization Code field value, %3 - ES Signer table caption';
    begin
        if "Taxpayer Created" then
            if not ConfirmManagement.GetResponse(StrSubstNo(DeleteConfirmQst, TableCaption(), Code), false) then
                Error('');

        ESSigner.SetRange("ES Organization Code", Code);
        ESSigner.SetFilter(State, '<>%1', ESSigner.State::" ");
        if not ESSigner.IsEmpty() then
            Error(CannotDeleteErr, TableCaption(), Code, ESSigner.TableCaption());
    end;

    trigger OnRename()
    var
        CannotRenameErr: Label 'You cannot rename a %1 %2 since it has been already sent to Fiskaly and it can cause data discrepancy.', Comment = '%1 - ES Organization table caption, %2 - ES Organization Code field value';
    begin
        if "Taxpayer Created" then
            Error(CannotRenameErr, TableCaption(), Code);
    end;

    local procedure TestDisabled()
    begin
        TestField(Disabled, false);
    end;

    local procedure IsThereAnyRelatedSigner(): Boolean
    var
        ESSigner: Record "NPR ES Signer";
    begin
        ESSigner.SetRange("ES Organization Code", Code);
        exit(not ESSigner.IsEmpty());
    end;

    local procedure ErrorIfThereIsAnyRelatedSigner()
    var
        ESSigner: Record "NPR ES Signer";
        RelatedSignerErr: Label 'You cannot perform this action, since there is at least one related %1. You should disable this %2 and create new one if new taxpayer data is needed.', Comment = '%1 - ES Signer table caption, %2 - ES Organization table caption';
    begin
        Error(RelatedSignerErr, ESSigner.TableCaption(), TableCaption());
    end;

    internal procedure CheckIsThereAnyRelatedSigner()
    var
        ESSigner: Record "NPR ES Signer";
        RelatedSignerErr: Label 'You cannot perform this action, since there is at least one related %1.', Comment = '%1 - ES Signer table caption';
    begin
        if IsThereAnyRelatedSigner() then
            Error(RelatedSignerErr, ESSigner.TableCaption());
    end;

    internal procedure Disable()
    var
        ConfirmDisableQst: Label 'Are you sure that you want to perform this action, since it is irreversible?';
    begin
        if Confirm(ConfirmDisableQst, false) then
            Disabled := true;
    end;

    internal procedure GetWithCheck(ESOrganizationCode: Code[20])
    begin
        Get(ESOrganizationCode);
        TestField("Taxpayer Created");
    end;

    internal procedure CheckIsTerritoryPopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 %3.', Comment = '%1 - Territory field caption, %2 - Code field value, %3 - ES Organization table caption';
    begin
        if "Taxpayer Territory" = "Taxpayer Territory"::" " then
            Error(NotPopulatedErr, FieldCaption("Taxpayer Territory"), Code, TableCaption());
    end;

    internal procedure GetAPIKeyName(): Text
    begin
        if IsNullGuid(SystemId) then
            exit('');

        exit('ESFiskalyAPIKey_' + SystemId);
    end;

    internal procedure GetAPISecretName(): Text
    begin
        if IsNullGuid(SystemId) then
            exit('');

        exit('ESFiskalyAPISecret_' + SystemId);
    end;
}
