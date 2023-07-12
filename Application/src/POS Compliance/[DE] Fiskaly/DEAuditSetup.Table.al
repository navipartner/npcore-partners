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
        field(30; "Last Fiskaly Context"; Blob)
        {
            Caption = 'Last Fiskaly Context';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Not needed in Fiskaly V2 anymore.';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
    trigger OnRename()
    var
        CannotRenameErr: Label 'You cannot rename a %1 record.', Comment = '%1 - "NPR DE Audit Setup" table caption';
    begin
        Error(CannotRenameErr, TableCaption());
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
        DEPosUnit: Record "NPR DE POS Unit Aux. Info";
    begin
        DSFINVKClosing.TestField("POS Unit No.");
        DEPosUnit.Get(DSFINVKClosing."POS Unit No.");
        GetSetup(DEPosUnit);
    end;

    procedure GetSetup(DEPosUnit: Record "NPR DE POS Unit Aux. Info")
    var
        DETSS: Record "NPR DE TSS";
    begin
        DEPosUnit.TestField("TSS Code");
        DETSS.Get(DEPosUnit."TSS Code");
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
    #endregion
}
