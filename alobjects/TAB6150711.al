table 6150711 "POS Default View"
{
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name

    Caption = 'POS Default View';

    fields
    {
        field(1;ID;Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            Editable = false;
        }
        field(2;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Login,Sale,Payment,Balance,Locked';
            OptionMembers = Login,Sale,Payment,Balance,Locked;
        }
        field(3;"Salesperson Filter";Text[250])
        {
            Caption = 'Salesperson Filter';
        }
        field(4;"Register Filter";Text[250])
        {
            Caption = 'Cash Register No. Filter';
        }
        field(5;"Starting Date";Date)
        {
            Caption = 'Starting Date';
        }
        field(6;"Ending Date";Date)
        {
            Caption = 'Ending Date';
        }
        field(7;Monday;Boolean)
        {
            Caption = 'Monday';
            InitValue = true;
        }
        field(8;Tuesday;Boolean)
        {
            Caption = 'Tuesday';
            InitValue = true;
        }
        field(9;Wednesday;Boolean)
        {
            Caption = 'Wednesday';
            InitValue = true;
        }
        field(10;Thursday;Boolean)
        {
            Caption = 'Thursday';
            InitValue = true;
        }
        field(11;Friday;Boolean)
        {
            Caption = 'Friday';
            InitValue = true;
        }
        field(12;Saturday;Boolean)
        {
            Caption = 'Saturday';
            InitValue = true;
        }
        field(13;Sunday;Boolean)
        {
            Caption = 'Sunday';
            InitValue = true;
        }
        field(21;"POS View Code";Code[10])
        {
            Caption = 'POS View Code';
            TableRelation = "POS View";
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
    }

    fieldgroups
    {
    }
}

