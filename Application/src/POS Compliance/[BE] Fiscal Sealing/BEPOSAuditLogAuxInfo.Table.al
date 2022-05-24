table 6014682 "NPR BE POS Audit Log Aux. Info"
{
    Access = Internal;
    Caption = 'BE POS Audit Log Aux. Info';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(10; "Previous Seal No."; Integer)
        {
            Caption = 'Previous Seal No.';
            DataClassification = CustomerContent;
            MaxValue = 99999999;
        }
        field(20; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(30; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(40; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(50; "Seal Serial No."; Integer)
        {
            Caption = 'Seal Serial No.';
            DataClassification = CustomerContent;
            MaxValue = 99999999;
            MinValue = 1000;
        }
        field(60; "Amount Incl. Tax"; Decimal)
        {
            Caption = 'Amount Incl. Tax';
            DataClassification = CustomerContent;
        }
        field(70; "Seal No."; Integer)
        {
            Caption = 'Seal No.';
            DataClassification = CustomerContent;
            MaxValue = 99999999;
        }
    }

    keys
    {
        key(Key1; "POS Entry No.")
        {
        }
        key(Key2; "POS Unit No.", "Seal Serial No.")
        {
        }
    }
}
