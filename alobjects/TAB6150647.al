table 6150647 "POS Info POS Entry"
{
    // NPR5.38/BR  /20171222 CASE 295503 Object Created
    // NPR5.41/THRO/20180416 CASE 311499 Added field 3 Sales Line No.

    Caption = 'POS Info POS Entry';

    fields
    {
        field(1;"POS Entry No.";Integer)
        {
            Caption = 'POS Entry No.';
            TableRelation = "POS Entry";
        }
        field(3;"Sales Line No.";Integer)
        {
            Caption = 'Sales Line No.';
        }
        field(5;"Receipt Type";Option)
        {
            Caption = 'Receipt Type';
            OptionCaption = 'G/L,Item,Payment,Open/Close,Customer,Debit Sale,Cancelled,Comment';
            OptionMembers = "G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
        }
        field(6;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(10;"POS Info Code";Code[20])
        {
            Caption = 'POS Info Code';
            TableRelation = "POS Info";
        }
        field(11;"POS Info";Text[250])
        {
            Caption = 'POS Info';
        }
        field(20;"No.";Code[30])
        {
            Caption = 'No.';
        }
        field(21;Quantity;Decimal)
        {
            Caption = 'Quantity';
        }
        field(22;Price;Decimal)
        {
            Caption = 'Price';
        }
        field(23;"Net Amount";Decimal)
        {
            Caption = 'Net Amount';
        }
        field(24;"Gross Amount";Decimal)
        {
            Caption = 'Gross Amount';
        }
        field(25;"Discount Amount";Decimal)
        {
            Caption = 'Discount Amount';
        }
    }

    keys
    {
        key(Key1;"POS Info Code","POS Entry No.","Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

