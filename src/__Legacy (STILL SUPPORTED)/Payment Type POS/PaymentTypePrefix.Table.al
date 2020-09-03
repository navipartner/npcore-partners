table 6014428 "NPR Payment Type - Prefix"
{
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.40/JDH /20180405 CASE        Added field Global Dimension 2. in 2018 Changing of global dimensions will crash, if GD1 and GD2 is not present together

    Caption = 'Prefix-Payment Type';
    LookupPageID = "NPR Credit Card Prefix";

    fields
    {
        field(1; "Payment Type"; Code[10])
        {
            Caption = 'Payment Type';
            TableRelation = "NPR Payment Type POS"."No.";
        }
        field(2; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            TableRelation = IF ("Payment Type" = CONST('<>''')) "NPR Register"."Register No.";
        }
        field(3; Prefix; Code[20])
        {
            Caption = 'Prefix';
        }
        field(4; Status; Option)
        {
            CalcFormula = Lookup ("NPR Payment Type POS".Status WHERE("No." = FIELD("Payment Type")));
            Caption = 'Status';
            FieldClass = FlowField;
            OptionCaption = ' ,Active,Passive';
            OptionMembers = " ",Aktiv,Passiv;
        }
        field(5; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(6; Weight; Decimal)
        {
            Caption = 'Weight';
        }
        field(7; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(8; "Bill y/n"; Boolean)
        {
            Caption = 'Bill y/n';
        }
        field(20; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
    }

    keys
    {
        key(Key1; "Payment Type", Prefix, "Register No.", Weight, "Global Dimension 1 Code")
        {
        }
        key(Key2; Prefix)
        {
        }
        key(Key3; Weight)
        {
        }
    }

    fieldgroups
    {
    }
}

