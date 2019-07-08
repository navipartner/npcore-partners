table 6014459 "Register Types"
{
    // NPR5.30/TJ  /20170215 CASE 265504 Changed table ENU caption

    Caption = 'Cash Register Type';
    LookupPageID = "Register Types";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(2;Description;Text[30])
        {
            Caption = 'Description';
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

