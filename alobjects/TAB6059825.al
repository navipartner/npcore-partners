table 6059825 "Transactional Email Log"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created

    Caption = 'Transactional Email Log';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"Message ID";Guid)
        {
            Caption = 'Message ID';
        }
        field(20;Status;Text[30])
        {
            Caption = 'Status';
        }
        field(30;Recipient;Text[80])
        {
            Caption = 'Recipient';
        }
        field(35;Subject;Text[250])
        {
            Caption = 'Subject';
        }
        field(40;"Smart Email ID";Guid)
        {
            Caption = 'Smart Email ID';
        }
        field(50;"Sent At";DateTime)
        {
            Caption = 'Sent At';
        }
        field(60;"Total Opens";Integer)
        {
            Caption = 'Total Opens';
        }
        field(65;"Total Clicks";Integer)
        {
            Caption = 'Total Clicks';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

