table 6150647 "POS Info POS Entry"
{
    // NPR5.38/BR  /20171222 CASE 295503 Object Created
    // NPR5.41/THRO/20180416 CASE 311499 Added field 3 Sales Line No.
    // NPR5.53/ALPO/20200204 CASE 387750 Added fields: 2 "Document No.", 4 "Entry Date", 26 "POS Unit No.", 27 "Salesperson Code"

    Caption = 'POS Info POS Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Entry";
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
        field(3; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Entry Date"; Date)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
        }
        field(5; "Receipt Type"; Option)
        {
            Caption = 'Receipt Type';
            DataClassification = CustomerContent;
            OptionCaption = 'G/L,Item,Payment,Open/Close,Customer,Debit Sale,Cancelled,Comment';
            OptionMembers = "G/L",Item,Payment,"Open/Close",Customer,"Debit Sale",Cancelled,Comment;
        }
        field(6; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "POS Info Code"; Code[20])
        {
            Caption = 'POS Info Code';
            DataClassification = CustomerContent;
            TableRelation = "POS Info";
        }
        field(11; "POS Info"; Text[250])
        {
            Caption = 'POS Info';
            DataClassification = CustomerContent;
        }
        field(20; "No."; Code[30])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(21; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(22; Price; Decimal)
        {
            Caption = 'Price';
            DataClassification = CustomerContent;
        }
        field(23; "Net Amount"; Decimal)
        {
            Caption = 'Net Amount';
            DataClassification = CustomerContent;
        }
        field(24; "Gross Amount"; Decimal)
        {
            Caption = 'Gross Amount';
            DataClassification = CustomerContent;
        }
        field(25; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
        field(26; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            TableRelation = "POS Unit";
        }
        field(27; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            TableRelation = "Salesperson/Purchaser";
        }
    }

    keys
    {
        key(Key1; "POS Info Code", "POS Entry No.", "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

