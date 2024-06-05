table 6150879 "NPR POS Entry Waiter Pad Link"
{
    Access = Internal;
    Caption = 'POS Entry - Waiter Pad Link';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Entry Waiter Pad Links";
    LookupPageID = "NPR POS Entry Waiter Pad Links";

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(2; "POS Entry Sales Line No."; Integer)
        {
            Caption = 'POS Entry Sales Line No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry Sales Line"."Line No." WHERE("POS Entry No." = FIELD("POS Entry No."));
        }
        field(3; "Waiter Pad No."; Code[20])
        {
            Caption = 'Waiter Pad No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Waiter Pad";
        }
        field(4; "Waiter Pad Line No."; Integer)
        {
            Caption = 'Waiter Pad Line No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Waiter Pad Line"."Line No." WHERE("Waiter Pad No." = FIELD("Waiter Pad No."));
        }
    }
    keys
    {
        key(PK; "POS Entry No.", "POS Entry Sales Line No.", "Waiter Pad No.", "Waiter Pad Line No.")
        {
            Clustered = true;
        }
        key(byWaiterPad; "Waiter Pad No.", "Waiter Pad Line No.") { }
    }
}