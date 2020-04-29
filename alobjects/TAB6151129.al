table 6151129 "NpIa Item AddOn Line Setup"
{
    // NPR5.48/MHA /20181109  CASE 334922 Object created - Before Insert Setup

    Caption = 'Item AddOn Line Option';

    fields
    {
        field(1;"AddOn No.";Code[20])
        {
            Caption = 'AddOn No.';
            NotBlank = true;
            TableRelation = "NpIa Item AddOn";
        }
        field(5;"AddOn Line No.";Integer)
        {
            Caption = 'AddOn Line No.';
        }
        field(15;"Unit Price % from Master";Decimal)
        {
            Caption = 'Unit Price % from Master';
            DecimalPlaces = 0:5;
        }
    }

    keys
    {
        key(Key1;"AddOn No.","AddOn Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

