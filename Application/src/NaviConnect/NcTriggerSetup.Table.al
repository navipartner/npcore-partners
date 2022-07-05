table 6151521 "NPR Nc Trigger Setup"
{
    Access = Internal;
    Caption = 'Nc Trigger Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteReason = 'Task Queue module is about to be removed from NpCore so NC Trigger is also going to be removed.';
    ObsoleteTag = 'BC 20 - Task Queue deprecating starting from 28/06/2022';

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

