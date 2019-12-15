table 6059829 "Transactional JSON Result"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created

    Caption = 'Transactional JSON Result';
    DrillDownPageID = "Transactional JSON Result";
    LookupPageID = "Transactional JSON Result";

    fields
    {
        field(1;"Entry No";Integer)
        {
            Caption = 'Entry No';
        }
        field(10;ID;Text[50])
        {
            Caption = 'ID';
        }
        field(20;Name;Text[100])
        {
            Caption = 'Name';
        }
        field(30;Status;Text[30])
        {
            Caption = 'Status';
        }
        field(40;Created;Date)
        {
            Caption = 'Created';
        }
    }

    keys
    {
        key(Key1;"Entry No")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;Name,Status,ID)
        {
        }
    }
}

