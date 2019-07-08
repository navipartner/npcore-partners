table 6151171 "NpGp POS Info POS Entry"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'POS Info POS Entry';
    DrillDownPageID = "NpGp POS Info POS Entry";
    LookupPageID = "NpGp POS Info POS Entry";

    fields
    {
        field(1;"POS Entry No.";Integer)
        {
            Caption = 'POS Entry No.';
            TableRelation = "POS Entry";
        }
        field(5;"POS Info Code";Code[20])
        {
            Caption = 'POS Info Code';
            TableRelation = "POS Info";
        }
        field(10;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(15;"Sales Line No.";Integer)
        {
            Caption = 'Sales Line No.';
        }
        field(20;"POS Info";Text[250])
        {
            Caption = 'POS Info';
        }
        field(25;"No.";Code[30])
        {
            Caption = 'No.';
        }
        field(30;Quantity;Decimal)
        {
            Caption = 'Quantity';
        }
        field(35;Price;Decimal)
        {
            Caption = 'Price';
        }
        field(40;"Net Amount";Decimal)
        {
            Caption = 'Net Amount';
        }
        field(45;"Gross Amount";Decimal)
        {
            Caption = 'Gross Amount';
        }
        field(50;"Discount Amount";Decimal)
        {
            Caption = 'Discount Amount';
        }
    }

    keys
    {
        key(Key1;"POS Entry No.","POS Info Code","Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

