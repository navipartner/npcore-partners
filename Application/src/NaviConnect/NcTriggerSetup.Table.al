table 6151521 "NPR Nc Trigger Setup"
{
    Access = Internal;
    Caption = 'Nc Trigger Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Task Template Name"; Code[10])
        {
            Caption = 'Task Template Name';
            DataClassification = CustomerContent;
            TableRelation = "NPR Task Template";
        }
        field(20; "Task Batch Name"; Code[10])
        {
            Caption = 'Task Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "NPR Task Batch".Name WHERE("Journal Template Name" = FIELD("Task Template Name"));
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

