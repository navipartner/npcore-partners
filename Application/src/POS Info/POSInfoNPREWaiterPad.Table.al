table 6150648 "NPR POS Info NPRE Waiter Pad"
{
    Access = Internal;
    // NPR5.53/ALPO/20191122 CASE 376538 POS Info - Waiter Pad integration: save sale pos info and restore it, when waiter pad lines are moved back to a sale

    Caption = 'POS Info Waiter Pad';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Waiter Pad No."; Code[20])
        {
            Caption = 'Waiter Pad No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Waiter Pad";
        }
        field(2; "Waiter Pad Line No."; Integer)
        {
            Caption = 'Waiter Pad Line No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Waiter Pad Line"."Line No." WHERE("Waiter Pad No." = FIELD("Waiter Pad No."));
        }
        field(3; "POS Info Code"; Code[20])
        {
            Caption = 'POS Info Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Info";
        }
        field(10; "POS Info"; Text[250])
        {
            Caption = 'POS Info';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Waiter Pad No.", "Waiter Pad Line No.", "POS Info Code")
        {
        }
    }

    fieldgroups
    {
    }
}

