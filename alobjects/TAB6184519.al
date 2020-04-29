table 6184519 "EFT NETS Cloud POS Unit Setup"
{
    // NPR5.54/JAKUBV/20200408  CASE 364340 Transport NPR5.54 - 8 April 2020

    Caption = 'EFT NETS Cloud POS Unit Setup';

    fields
    {
        field(1;"POS Unit No.";Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "POS Unit"."No.";
        }
        field(10;"Terminal ID";Text[50])
        {
            Caption = 'Terminal ID';
        }
    }

    keys
    {
        key(Key1;"POS Unit No.")
        {
        }
    }

    fieldgroups
    {
    }
}

