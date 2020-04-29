table 6060102 Periodes
{
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption

    Caption = 'Period';
    DataPerCompany = false;

    fields
    {
        field(1;"Period Code";Code[20])
        {
            Caption = 'Period Code';
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(3;"Start Date";Date)
        {
            Caption = 'Start Date';
        }
        field(4;"End Date";Date)
        {
            Caption = 'End Date';
        }
        field(5;"Start Date Last Year";Date)
        {
            Caption = 'Start Date Last Year';
        }
        field(6;"End Date Last Year";Date)
        {
            Caption = 'End Date Last Year';
        }
    }

    keys
    {
        key(Key1;"Period Code")
        {
        }
    }

    fieldgroups
    {
    }
}

