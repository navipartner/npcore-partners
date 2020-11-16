table 6151171 "NPR NpGp POS Info POS Entry"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'POS Info POS Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpGp POS Info POS Entry";
    LookupPageID = "NPR NpGp POS Info POS Entry";

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(5; "POS Info Code"; Code[20])
        {
            Caption = 'POS Info Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Info";
        }
        field(10; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(15; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;
        }
        field(20; "POS Info"; Text[250])
        {
            Caption = 'POS Info';
            DataClassification = CustomerContent;
        }
        field(25; "No."; Code[30])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(30; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(35; Price; Decimal)
        {
            Caption = 'Price';
            DataClassification = CustomerContent;
        }
        field(40; "Net Amount"; Decimal)
        {
            Caption = 'Net Amount';
            DataClassification = CustomerContent;
        }
        field(45; "Gross Amount"; Decimal)
        {
            Caption = 'Gross Amount';
            DataClassification = CustomerContent;
        }
        field(50; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Entry No.", "POS Info Code", "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

