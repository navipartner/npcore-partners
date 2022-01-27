table 6151507 "NPR Nc Task Processor"
{
    Caption = 'NaviConnect Task Processor';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Nc Task Proces. List";
    LookupPageID = "NPR Nc Task Proces. List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(100; "Filter Code"; Code[20])
        {
            Caption = 'Filter Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}

