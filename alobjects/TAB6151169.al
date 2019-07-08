table 6151169 "NpGp Detailed POS Sales Entry"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Global Detailed Pos Sales Entry';
    DrillDownPageID = "NpGp Detailed POS S. Entries";
    LookupPageID = "NpGp Detailed POS S. Entries";

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"POS Entry No.";BigInteger)
        {
            Caption = 'POS Entry No.';
        }
        field(10;"POS Sales Line No.";Integer)
        {
            Caption = 'POS Sales Line No.';
        }
        field(15;"Entry Time";DateTime)
        {
            Caption = 'Entry Time';
        }
        field(20;"Entry Type";Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Initial,Application';
            OptionMembers = Initial,Application;
        }
        field(100;"POS Store Code";Code[10])
        {
            Caption = 'POS Store Code';
            TableRelation = "POS Store";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(105;"POS Unit No.";Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "POS Unit";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(110;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(200;Quantity;Decimal)
        {
            Caption = 'Quantity';
        }
        field(205;Open;Boolean)
        {
            Caption = 'Open';
        }
        field(210;"Remaining Quantity";Decimal)
        {
            Caption = 'Remaining Quantity';
        }
        field(215;Positive;Boolean)
        {
            Caption = 'Positive';
        }
        field(220;"Closed by Entry No.";Boolean)
        {
            Caption = 'Closed by Entry No.';
        }
        field(225;"Applies to Store Code";Code[10])
        {
            Caption = 'Applies to Store Code';
        }
        field(230;"Cross Store Application";Boolean)
        {
            Caption = 'Cross Store Application';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"POS Entry No.","POS Sales Line No.")
        {
        }
        key(Key3;"POS Store Code","POS Unit No.","Document No.")
        {
        }
    }

    fieldgroups
    {
    }
}

