table 6060135 "NPR MM Members. Admis. Setup"
{
    Caption = 'Membership Admission Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Membership  Code"; Code[20])
        {
            Caption = 'Membership  Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";
        }
        field(2; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
        }
        field(3; "Ticket No. Type"; Option)
        {
            Caption = 'Ticket No. Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Item,Item Reference,Not Used';
            OptionMembers = NA,ITEM,ITEM_CROSS_REF,ALTERNATIVE_NUMBER;
        }
        field(4; "Ticket No."; Code[50])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Ticket No. Type" = CONST(ITEM)) Item WHERE("No." = FIELD("Ticket No."))
            ELSE
            IF ("Ticket No. Type" = CONST(ITEM_CROSS_REF)) "Item Reference"."Reference No." WHERE("Reference No." = FIELD("Ticket No."));
        }
        field(10; "Cardinality Type"; Option)
        {
            Caption = 'Cardinality Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Unlimited,Limited';
            OptionMembers = UNLIMITED,LIMITED;
        }
        field(11; "Max Cardinality"; Integer)
        {
            Caption = 'Max Cardinality';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Membership  Code", "Admission Code", "Ticket No. Type", "Ticket No.")
        {
        }
    }

    fieldgroups
    {
    }
}

