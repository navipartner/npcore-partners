table 6150643 "POS Info Audit Roll"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name

    Caption = 'POS Info Audit Roll';

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
        }
        field(2;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
        }
        field(3;"Sales Line No.";Integer)
        {
            Caption = 'Sales Line No.';
        }
        field(4;"Sale Date";Date)
        {
            Caption = 'Sale Date';
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
        key(Key1;"POS Info Code","Register No.","Sales Ticket No.","Sales Line No.","Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

