table 6151521 "NPR Nc Trigger Setup"
{
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Task Queue module to be removed from NP Retail. We are now using Job Queue instead. This table was used for Task Que only.';
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
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Task Queue module to be removed from NP Retail. We are now using Job Queue instead.';
            Caption = 'Task Template Name';
            DataClassification = CustomerContent;
        }
        field(20; "Task Batch Name"; Code[10])
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Task Queue module to be removed from NP Retail. We are now using Job Queue instead.';
            Caption = 'Task Batch Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

