table 6060063 "Nonstock Item Material"
{
    // NPR5.45/RA  /20180802  CASE 295322 Created Table.
    // NPR5.45/RA  /20180827  CASE 325023 Added field 3

    Caption = 'Nonstock Item Material';

    fields
    {
        field(1;"Nonstock Item Entry No.";Code[20])
        {
            Caption = 'Nonstock Item Entry No.';
            NotBlank = true;
            TableRelation = "Nonstock Item";
        }
        field(2;"Item Material";Code[20])
        {
            Caption = 'Item Material';
            NotBlank = true;
        }
        field(3;"Item Material Density";Code[20])
        {
            Caption = 'Item Material Density';
        }
    }

    keys
    {
        key(Key1;"Nonstock Item Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

