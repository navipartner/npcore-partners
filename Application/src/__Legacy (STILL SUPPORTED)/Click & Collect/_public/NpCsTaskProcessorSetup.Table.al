table 6059837 "NPR NpCs Task Processor Setup"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Caption = 'Collect Task Processor Setup';
    DataClassification = CustomerContent;
    LookupPageId = "NPR NpCs Task Processor Setup";
    DrillDownPageId = "NPR NpCs Task Processor Setup";
    fields
    {
        field(1; PK; Code[10])
        {
            Caption = 'PK';
            DataClassification = CustomerContent;
        }
        field(10; "Run Workflow Code"; Code[20])
        {
            Caption = 'Workflow Processor Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Task Processor";
        }
        field(11; "Document Posting Code"; Code[20])
        {
            Caption = 'Document Posting Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Task Processor";
        }
        field(12; "Expiration Code"; Code[20])
        {
            Caption = 'Expiration Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Task Processor";
        }
    }
    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }
}
