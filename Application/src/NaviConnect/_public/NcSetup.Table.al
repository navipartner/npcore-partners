﻿table 6151500 "NPR Nc Setup"
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
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Task Queue module removed from NP Retail. We are now using Job Queue instead.';
            Caption = 'Task Queue Enabled';
            DataClassification = CustomerContent;
            Description = 'NC1.11,NC1.12,NC1.16,NC1.17';
        }
        field(305; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            DataClassification = CustomerContent;
            Description = 'NC1.09,NC1.11,NC1.12,NC1.17';
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
