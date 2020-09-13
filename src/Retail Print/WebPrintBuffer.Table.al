table 6014581 "NPR Web Print Buffer"
{
    // NPR4.15/MMV/20151001 CASE 223893 Created table for use with web service printing

    Caption = 'Web Print Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Printjob ID"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Printjob ID';
            DataClassification = CustomerContent;
        }
        field(2; "Printer ID"; Text[250])
        {
            Caption = 'Printer ID';
            DataClassification = CustomerContent;
        }
        field(3; "Print Data"; BLOB)
        {
            Caption = 'Print Data';
            DataClassification = CustomerContent;
        }
        field(4; "Time Created"; DateTime)
        {
            Caption = 'Time Created';
            DataClassification = CustomerContent;
        }
        field(5; Printed; Boolean)
        {
            Caption = 'Printed';
            DataClassification = CustomerContent;
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

