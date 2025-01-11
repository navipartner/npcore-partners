table 6014529 "NPR DE Audit Setup"
{
    Access = Internal;
    Caption = 'DE Connection Parameter Set';
    DataClassification = CustomerContent;
    LookupPageId = "NPR DE Connection Param. Sets";
    DrillDownPageId = "NPR DE Connection Param. Sets";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Api URL"; Text[250])
        {
            Caption = 'Fiskaly API URL';
            DataClassification = CustomerContent;
        }
        field(21; "DSFINVK Api URL"; Text[250])
        {
            Caption = 'DSFINVK API URL';
            DataClassification = CustomerContent;
        }
        field(22; "Submission Api URL"; Text[250])
        {
            Caption = 'Submission API URL';
            DataClassification = CustomerContent;
        }
        field(30; "Last Fiskaly Context"; Blob)
        {
            Caption = 'Last Fiskaly Context';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not needed in Fiskaly V2 anymore.';
        }
        field(90; "Taxpayer Created"; Boolean)
        {
            Caption = 'Taxpayer Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(95; "Taxpayer Person Type"; Enum "NPR DE Taxpayer Person Type")
        {
            Caption = 'Taxpayer Person Type';
            DataClassification = CustomerContent;
            InitValue = legal;

            trigger OnValidate()
            begin
                if "Taxpayer Person Type" <> xRec."Taxpayer Person Type" then begin
                    ClearTaxpayerFieldValues();
                    if "Taxpayer Person Type" = "Taxpayer Person Type"::legal then
                        SetDefaultLegalPersonFieldValues();
                end;
            end;
        }
        field(100; "Taxpayer VAT Registration No."; Text[20])
        {
            Caption = 'Taxpayer VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(105; "Taxpayer Registration No."; Text[20])
        {
            Caption = 'Taxpayer Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Taxpayer Registration No." <> '' then
                    DEFiskalyCommunication.CheckIsValueAccordingToAllowedPattern("Taxpayer Registration No.", GetTaxpayerRegistrationNoPattern());
            end;
        }
        field(110; "Taxpayer Tax Office Number"; Code[4])
        {
            Caption = 'Tax Office Number';
            DataClassification = CustomerContent;
            Numeric = true;

            trigger OnValidate()
            begin
                if "Taxpayer Tax Office Number" <> '' then
                    DEFiskalyCommunication.CheckIsValueAccordingToAllowedPattern("Taxpayer Tax Office Number", GetTaxpayerTaxOfficeNumberPattern());
            end;
        }
        field(115; "Taxpayer Company Name"; Text[100])
        {
            Caption = 'Taxpayer Company Name';
            DataClassification = CustomerContent;
        }
        field(120; "Taxpayer Legal Form"; Enum "NPR DE Taxpayer Legal Form")
        {
            Caption = 'Taxpayer Legal Form';
            DataClassification = CustomerContent;
        }
        field(125; "Taxpayer Web Address"; Text[255])
        {
            Caption = 'Taxpayer Web Address';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
        field(130; "Taxpayer Birthdate"; Date)
        {
            Caption = 'Taxpayer Birthdate';
            DataClassification = CustomerContent;
        }
        field(135; "Taxpayer First Name"; Text[50])
        {
            Caption = 'Taxpayer First Name';
            DataClassification = CustomerContent;
        }
        field(140; "Taxpayer Last Name"; Text[50])
        {
            Caption = 'Taxpayer Last Name';
            DataClassification = CustomerContent;
        }
        field(145; "Taxpayer Identification No."; Code[20])
        {
            Caption = 'Taxpayer Identification No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Taxpayer Identification No." <> '' then
                    DEFiskalyCommunication.CheckIsValueAccordingToAllowedPattern("Taxpayer Identification No.", GetTaxpayerIdentificationNoPattern());
            end;
        }
        field(150; "Taxpayer Name Prefix"; Text[30])
        {
            Caption = 'Taxpayer Name Prefix';
            DataClassification = CustomerContent;
        }
        field(155; "Taxpayer Salutation"; Enum "NPR DE Taxpayer Salutation")
        {
            Caption = 'Taxpayer Salutation';
            DataClassification = CustomerContent;
        }
        field(160; "Taxpayer Name Suffix"; Text[30])
        {
            Caption = 'Taxpayer Name Suffix';
            DataClassification = CustomerContent;
        }
        field(165; "Taxpayer Title"; Text[30])
        {
            Caption = 'Taxpayer Title';
            DataClassification = CustomerContent;
        }
        field(170; "Taxpayer Street"; Text[100])
        {
            Caption = 'Taxpayer Street';
            DataClassification = CustomerContent;
        }
        field(175; "Taxpayer House Number"; Code[4])
        {
            Caption = 'Taxpayer House Number';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Taxpayer House Number" <> '' then
                    DEFiskalyCommunication.CheckIsValueAccordingToAllowedPattern("Taxpayer House Number", GetTaxpayerHouseNumberPattern());
            end;
        }
        field(180; "Taxpayer House Number Suffix"; Text[20])
        {
            Caption = 'Taxpayer House Number Suffix';
            DataClassification = CustomerContent;
        }
        field(185; "Taxpayer Town"; Text[50])
        {
            Caption = 'Taxpayer Town';
            DataClassification = CustomerContent;
        }
        field(190; "Taxpayer ZIP Code"; Code[20])
        {
            Caption = 'Taxpayer ZIP Code';
            DataClassification = CustomerContent;
        }
        field(195; "Taxpayer Additional Address"; Text[50])
        {
            Caption = 'Taxpayer Additional Address';
            DataClassification = CustomerContent;
        }
        field(200; "Taxpayer International Address"; Boolean)
        {
            Caption = 'Taxpayer International Address';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Taxpayer International Address" <> xRec."Taxpayer International Address" then
                    Clear("Taxpayer Country/Region Code");
            end;
        }
        field(205; "Taxpayer Country/Region Code"; Code[10])
        {
            Caption = 'Taxpayer Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                TestField("Taxpayer International Address");
            end;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    trigger OnDelete()
    var
        DEEstablishment: Record "NPR DE Establishment";
        ConfirmManagement: Codeunit "Confirm Management";
        DeleteConfirmQst: Label 'Are you sure that you want to delete %1 %2 since it already exists at Fiskaly and it can cause data discrepancy?', Comment = '%1 - DE Audit Setup table caption, %2 - Primary Key field value';
        CannotDeleteErr: Label 'You cannot delete %1 %2 since there is at least one related %3 which has been already sent to Fiskaly. You must delete this record(s) first.', Comment = '%1 - DE Audit Setup table caption, %2 - Primary Key field value, %3 - DE Establishment table caption';
    begin
        if "Taxpayer Created" then
            if not ConfirmManagement.GetResponse(StrSubstNo(DeleteConfirmQst, TableCaption(), "Primary Key"), false) then
                Error('');

        DEEstablishment.SetRange("Connection Parameter Set Code", "Primary Key");
        DEEstablishment.SetRange(Created, true);
        if not DEEstablishment.IsEmpty() then
            Error(CannotDeleteErr, TableCaption(), "Primary Key", DEEstablishment.TableCaption());
    end;

    trigger OnRename()
    var
        CannotRenameErr: Label 'You cannot rename a %1 record.', Comment = '%1 - "NPR DE Audit Setup" table caption';
    begin
        Error(CannotRenameErr, TableCaption());
    end;

    var
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";

    local procedure ClearTaxpayerFieldValues()
    begin
        Clear("Taxpayer VAT Registration No.");
        Clear("Taxpayer Registration No.");
        Clear("Taxpayer Tax Office Number");
        Clear("Taxpayer Company Name");
        Clear("Taxpayer Legal Form");
        Clear("Taxpayer Web Address");
        Clear("Taxpayer First Name");
        Clear("Taxpayer Last Name");
        Clear("Taxpayer Birthdate");
        Clear("Taxpayer Identification No.");
        Clear("Taxpayer Name Prefix");
        Clear("Taxpayer Salutation");
        Clear("Taxpayer Name Suffix");
        Clear("Taxpayer Title");
        Clear("Taxpayer Street");
        Clear("Taxpayer House Number");
        Clear("Taxpayer House Number Suffix");
        Clear("Taxpayer Town");
        Clear("Taxpayer ZIP Code");
        Clear("Taxpayer Additional Address");
        Clear("Taxpayer International Address");
        Clear("Taxpayer Country/Region Code");
    end;

    local procedure SetTaxOfficeNumber(RecordRef: RecordRef)
    var
        FieldRef: FieldRef;
    begin
        if RecordRef.FieldExist(11103) then begin
            FieldRef := RecordRef.Field(11103);
            if DEFiskalyCommunication.IsValueAccordingToAllowedPattern(FieldRef.Value(), GetTaxpayerTaxOfficeNumberPattern()) then
                Rec."Taxpayer Tax Office Number" := FieldRef.Value();
        end;
    end;

    local procedure SetTaxOfficeName(RecordRef: RecordRef)
    var
        FieldRef: FieldRef;
    begin
        if RecordRef.FieldExist(11008) then begin
            FieldRef := RecordRef.Field(11008);
            Rec."Taxpayer Company Name" := FieldRef.Value();
        end;
    end;

    local procedure SetTaxOfficeAddress(RecordRef: RecordRef)
    var
        FieldRef: FieldRef;
    begin
        if RecordRef.FieldExist(11010) then begin
            FieldRef := RecordRef.Field(11010);
            Rec."Taxpayer Street" := FieldRef.Value();
        end;
    end;

    local procedure SetTaxOfficeCity(RecordRef: RecordRef)
    var
        FieldRef: FieldRef;
    begin
        if RecordRef.FieldExist(11012) then begin
            FieldRef := RecordRef.Field(11012);
            Rec."Taxpayer Town" := FieldRef.Value();
        end;
    end;

    local procedure SetTaxOfficePostCode(RecordRef: RecordRef)
    var
        FieldRef: FieldRef;
    begin
        if RecordRef.FieldExist(11013) then begin
            FieldRef := RecordRef.Field(11013);
            Rec."Taxpayer ZIP Code" := FieldRef.Value();
        end;
    end;

    local procedure GetTaxpayerRegistrationNoPattern(): Text;
    var
        PatternLbl: Label '^[0-9]{4}0[0-9]{8}$', Locked = true;
    begin
        exit(PatternLbl);
    end;

    local procedure GetTaxpayerTaxOfficeNumberPattern(): Text;
    var
        PatternLbl: Label '^(10\d{2})|(11\d{2})|(21\d{2})|(22\d{2})|(23\d{2})|(24\d{2})|(26\d{2})|(27\d{2})|(28\d{2})|(30\d{2})|(31\d{2})|(32\d{2})|(40\d{2})|(41\d{2})|(51\d{2})|(52\d{2})|(53\d{2})|(54\d{2})|(55\d{2})|(56\d{2})|(91\d{2})|(92\d{2})$', Locked = true;
    begin
        exit(PatternLbl);
    end;

    local procedure GetTaxpayerIdentificationNoPattern(): Text;
    var
        PatternLbl: Label '^[0-9]{11}$', Locked = true;
    begin
        exit(PatternLbl);
    end;

    local procedure GetTaxpayerHouseNumberPattern(): Text;
    var
        PatternLbl: Label '^[0-9]{1,4}$', Locked = true;
    begin
        exit(PatternLbl);
    end;

    procedure ApiKeyLbl(): Text
    begin
        if IsNullGuid(SystemId) then
            exit('');
        exit('DEFiskalyApiKey_' + SystemId);
    end;

    procedure ApiSecretLbl(): Text
    begin
        if IsNullGuid(SystemId) then
            exit('');
        exit('DEFiskalyApiSecret_' + SystemId);
    end;

    #region Getting connection parameter set
    [TryFunction]
    procedure GetSetup(DSFINVKClosing: Record "NPR DSFINVK Closing")
    var
        DETSSClient: Record "NPR DE POS Unit Aux. Info";
    begin
        DSFINVKClosing.TestField("POS Unit No.");
        DETSSClient.Get(DSFINVKClosing."POS Unit No.");
        GetSetup(DETSSClient);
    end;

    procedure GetSetup(DETSSClient: Record "NPR DE POS Unit Aux. Info")
    var
        DETSS: Record "NPR DE TSS";
    begin
        DETSSClient.TestField("TSS Code");
        DETSS.Get(DETSSClient."TSS Code");
        GetSetup(DETSS);
    end;

    procedure GetSetup(DeAuditAux: Record "NPR DE POS Audit Log Aux. Info")
    var
        DETSS: Record "NPR DE TSS";
    begin
        DeAuditAux.TestField("TSS Code");
        DETSS.Get(DeAuditAux."TSS Code");
        GetSetup(DETSS);
    end;

    procedure GetSetup(DETSS: Record "NPR DE TSS")
    begin
        DETSS.TestField("Connection Parameter Set Code");
        Get(DETSS."Connection Parameter Set Code");
    end;

    internal procedure GetWithCheck(ConnectionParameterSetCode: Code[20])
    begin
        Get(ConnectionParameterSetCode);
        TestField("Taxpayer Created");
    end;

    internal procedure SetDefaultLegalPersonFieldValues()
    var
        CompanyInformation: Record "Company Information";
        RecordRef: RecordRef;
    begin
        CompanyInformation.Get();
        if DEFiskalyCommunication.IsValueAccordingToAllowedPattern(CompanyInformation."Registration No.", GetTaxpayerRegistrationNoPattern()) then
            Rec."Taxpayer Registration No." := CompanyInformation."Registration No.";
        Rec."Taxpayer VAT Registration No." := CompanyInformation."VAT Registration No.";
#pragma warning disable AL0432
        Rec."Taxpayer Web Address" := CompanyInformation."Home Page";
#pragma warning restore AL0432

        // getting field values from Germany localization fields
        RecordRef.Open(Database::"Company Information");
        RecordRef.Get(CompanyInformation.RecordId());

        SetTaxOfficeNumber(RecordRef);
        SetTaxOfficeName(RecordRef);
        SetTaxOfficeAddress(RecordRef);
        SetTaxOfficeCity(RecordRef);
        SetTaxOfficePostCode(RecordRef);
    end;

    internal procedure CheckIsPersonTypePopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 %3.', Comment = '%1 - Person Type field caption, %2 - Primary Key field value, %3 - DE Audit Setup table caption';
    begin
        if "Taxpayer Person Type" = "Taxpayer Person Type"::" " then
            Error(NotPopulatedErr, FieldCaption("Taxpayer Person Type"), "Primary Key", TableCaption());
    end;

    internal procedure CheckIsLegalFormPopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 %3.', Comment = '%1 - Legal Form field caption, %2 - Primary Key field value, %3 - DE Audit Setup table caption';
    begin
        if "Taxpayer Legal Form" = "Taxpayer Legal Form"::" " then
            Error(NotPopulatedErr, FieldCaption("Taxpayer Legal Form"), "Primary Key", TableCaption());
    end;

    internal procedure CheckIsSalutationPopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 %3.', Comment = '%1 - Salutation field caption, %2 - Primary Key field value, %3 - DE Audit Setup table caption';
    begin
        if "Taxpayer Salutation" = "Taxpayer Salutation"::" " then
            Error(NotPopulatedErr, FieldCaption("Taxpayer Salutation"), "Primary Key", TableCaption());
    end;
    #endregion
}
