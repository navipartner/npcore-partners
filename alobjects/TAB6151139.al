table 6151139 "TM Waiting List Entry"
{
    // TM1.45/TSA /20191203 CASE 380754 Initial Version

    Caption = 'Waiting List Entry';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(3;"Ticket Waiting List Entry No.";Integer)
        {
            Caption = 'Ticket Waiting List Entry No.';
        }
        field(10;"Created At";DateTime)
        {
            Caption = 'Created At';
        }
        field(15;"Expires At";DateTime)
        {
            Caption = 'Expires At';
        }
        field(20;"Reference Code";Code[20])
        {
            Caption = 'Reference Code';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Reference Code")
        {
        }
    }

    fieldgroups
    {
    }
}

