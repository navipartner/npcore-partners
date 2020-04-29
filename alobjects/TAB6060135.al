table 6060135 "MM Membership Admission Setup"
{
    Caption = 'Membership Admission Setup';

    fields
    {
        field(1;"Membership  Code";Code[20])
        {
            Caption = 'Membership  Code';
            TableRelation = "MM Membership Setup";
        }
        field(2;"Admission Code";Code[20])
        {
            Caption = 'Admission Code';
            TableRelation = "TM Admission";
        }
        field(3;"Ticket No. Type";Option)
        {
            Caption = 'Ticket No. Type';
            OptionCaption = ' ,Item,Item Cross-Reference,Alternative No.';
            OptionMembers = NA,ITEM,ITEM_CROSS_REF,ALTERNATIVE_NUMBER;
        }
        field(4;"Ticket No.";Code[50])
        {
            Caption = 'Ticket No.';
            TableRelation = IF ("Ticket No. Type"=CONST(ITEM)) Item WHERE ("No."=FIELD("Ticket No."))
                            ELSE IF ("Ticket No. Type"=CONST(ITEM_CROSS_REF)) "Item Cross Reference"."Cross-Reference No." WHERE ("Cross-Reference No."=FIELD("Ticket No."))
                            ELSE IF ("Ticket No. Type"=CONST(ALTERNATIVE_NUMBER)) "Alternative No."."Alt. No." WHERE ("Alt. No."=FIELD("Ticket No."));
        }
        field(10;"Cardinality Type";Option)
        {
            Caption = 'Cardinality Type';
            OptionCaption = 'Unlimited,Limited';
            OptionMembers = UNLIMITED,LIMITED;
        }
        field(11;"Max Cardinality";Integer)
        {
            Caption = 'Max Cardinality';
        }
        field(20;Description;Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Membership  Code","Admission Code","Ticket No. Type","Ticket No.")
        {
        }
    }

    fieldgroups
    {
    }
}

