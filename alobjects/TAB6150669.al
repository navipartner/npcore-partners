table 6150669 "NPRE Restaurant Setup"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant

    Caption = 'Restaurant Setup';

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(10;"Waiter Pad No. Serie";Code[10])
        {
            Caption = 'Waiter Pad No. Serie';
            TableRelation = "No. Series".Code;
        }
        field(11;"Kitchen Order Template";Code[20])
        {
            Caption = 'Kitchen Order Template';
            TableRelation = "RP Template Header".Code;
            ValidateTableRelation = true;
        }
        field(12;"Pre Receipt Template";Code[20])
        {
            Caption = 'Pre Receipt Template';
            TableRelation = "RP Template Header".Code;
        }
        field(13;"Auto Print Kitchen Order";Boolean)
        {
            Caption = 'Auto Print Kitchen Order';
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

