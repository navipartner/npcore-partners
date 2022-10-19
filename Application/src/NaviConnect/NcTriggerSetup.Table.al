table 6151521 "NPR Nc Trigger Setup"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Task Queue module to be removed from NP Retail. We are now using Job Queue instead. This table was used for Task Que only.';
    ObsoleteTag = '20.0';
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
            ObsoleteReason = 'Task Queue module to be removed from NP Retail. We are now using Job Queue instead.';
            ObsoleteTag = '20.0';
            Caption = 'Task Template Name';
            DataClassification = CustomerContent;
        }
        field(20; "Task Batch Name"; Code[10])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Task Queue module to be removed from NP Retail. We are now using Job Queue instead.';
            ObsoleteTag = '20.0';
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

