table 6151172 "NpGp Cross Company Setup"
{
    // NPR5.51/ALST/20190422 CASE 337539 New object
    // NPR5.53/ALST/20191106 CASE 372895 allow general Cross company setup entry

    Caption = 'Cross Company Setup';

    fields
    {
        field(1;"Original Company";Text[30])
        {
            Caption = 'Company of Origin';
        }
        field(10;"Location Code";Code[10])
        {
            Caption = 'Location';
            NotBlank = true;
            TableRelation = Location;
        }
        field(20;"Gen. Bus. Posting Group";Code[10])
        {
            Caption = 'Gen. Bus. Posting Group';
            NotBlank = true;
            TableRelation = "Gen. Business Posting Group";
        }
        field(30;"Generic Item No.";Code[20])
        {
            Caption = 'Generic Item Number';
            NotBlank = true;
            TableRelation = Item;
        }
        field(40;Customer;Code[20])
        {
            Caption = 'Customer';
            NotBlank = true;
            TableRelation = Customer;
        }
        field(50;"Use Original Item No.";Boolean)
        {
            Caption = 'Use Original Item No.';
        }
    }

    keys
    {
        key(Key1;"Original Company")
        {
        }
    }

    fieldgroups
    {
    }
}

