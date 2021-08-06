table 6151500 "NPR Nc Setup"
{
    Caption = 'Nc Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Keep Tasks for"; Duration)
        {
            Caption = 'Keep Tasks for';
            DataClassification = CustomerContent;
        }
        field(300; "Task Queue Enabled"; Boolean)
        {
            Caption = 'Task Queue Enabled';
            DataClassification = CustomerContent;
            Description = 'NC1.11,NC1.12,NC1.16,NC1.17';
            TableRelation = "NPR Task Worker Group";
            ValidateTableRelation = false;
        }
        field(305; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            DataClassification = CustomerContent;
            Description = 'NC1.09,NC1.11,NC1.12,NC1.17';
            TableRelation = "NPR Task Worker Group";
            ValidateTableRelation = false;
        }
        field(310; "Max Task Count per Batch"; Integer)
        {
            Caption = 'Max Task Count per batch';
            DataClassification = CustomerContent;
            Description = 'NC1.21';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}
