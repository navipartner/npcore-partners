table 6151221 "PrintNode Printer"
{
    // NPR5.53/THRO/20200106 CASE 383562 Object Created

    Caption = 'PrintNode Printer';
    DrillDownPageID = "PrintNode Printer List";
    LookupPageID = "PrintNode Printer List";

    fields
    {
        field(1;Id;Code[20])
        {
            Caption = 'Id';
        }
        field(10;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(20;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
    }

    fieldgroups
    {
    }
}

