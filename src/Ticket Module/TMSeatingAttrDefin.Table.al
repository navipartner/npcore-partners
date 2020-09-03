table 6151132 "NPR TM Seating Attr. Defin."
{
    // TM1.45/TSA/20200122  CASE 322432-01 Transport TM1.45 - 22 January 2020

    Caption = 'Seating Attr. Definition';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

