#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6059892 "NPR Entria Integration Setup"
{
    Access = Internal;
    Caption = 'Entria Integration Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Entria Integration Setup";
    LookupPageID = "NPR Entria Integration Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Enable Integration"; Boolean)
        {
            Caption = 'Enable Integration';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
            begin
                if (CurrFieldNo = FieldNo("Enable Integration")) and ("Enable Integration" <> xRec."Enable Integration") then begin
                    Modify();
                    EntriaIntegrationMgt.SetupJobQueues();
                end;
            end;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
    procedure GetRecordOnce(ReRead: Boolean)
    begin
        if RecordHasBeenRead and not ReRead then
            exit;
        if not Get() then begin
            Init();
            Insert(true);
        end;
        RecordHasBeenRead := true;
    end;

    var
        RecordHasBeenRead: Boolean;
}
#endif