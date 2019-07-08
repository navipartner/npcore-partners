table 6151062 "Retail Replenishment Setup"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Retail Replenishment Setup';

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(10;"Item Demand Calc. Codeunit";Integer)
        {
            Caption = 'Item Demand Calc. Codeunit';
        }
        field(20;"Default Transit Location";Code[10])
        {
            Caption = 'Default Transit Location';
            TableRelation = Location;
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

