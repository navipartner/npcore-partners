table 6151507 "Nc Task Processor"
{
    // NC1.22/MHA/20160125 CASE 239371 Object created
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NaviConnect Task Processor';
    DrillDownPageID = "Nc Task Proces. List";
    LookupPageID = "Nc Task Proces. List";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(100;"Filter Code";Code[20])
        {
            Caption = 'Filter Code';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

