table 6014581 "NPR Web Print Buffer"
{
    // NPR4.15/MMV/20151001 CASE 223893 Created table for use with web service printing

    Caption = 'Web Print Buffer';

    fields
    {
        field(1; "Printjob ID"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Printjob ID';
        }
        field(2; "Printer ID"; Text[250])
        {
            Caption = 'Printer ID';
        }
        field(3; "Print Data"; BLOB)
        {
            Caption = 'Print Data';
        }
        field(4; "Time Created"; DateTime)
        {
            Caption = 'Time Created';
        }
        field(5; Printed; Boolean)
        {
            Caption = 'Printed';
        }
    }

    keys
    {
        key(Key1; "Printjob ID")
        {
        }
    }

    fieldgroups
    {
    }
}

