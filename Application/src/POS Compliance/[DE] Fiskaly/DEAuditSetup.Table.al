table 6014529 "NPR DE Audit Setup"
{
    Access = Internal;
    Caption = 'DE Audit Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
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
            ObsoleteReason = 'Not needed in Fiskaly V2 anymore.';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    var
        RecordHasBeenRead: Boolean;

    procedure GetRecordOnce(ReRead: Boolean)
    begin
        if RecordHasBeenRead and not ReRead then
            exit;
        if not Get() then begin
            Init();
            Insert();
        end;
        RecordHasBeenRead := true;
    end;

    procedure ApiKeyLbl(): Text
    begin
        exit('DEFiskalyApiKey');
    end;

    procedure ApiSecretLbl(): Text
    begin
        exit('DEFiskalyApiSecret');
    end;
}