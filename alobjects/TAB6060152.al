table 6060152 "Event Web Sales Setup"
{
    // NPR5.48/TJ  /20190124 CASE 263728 New object

    Caption = 'Event Web Sales Setup';
    DrillDownPageID = "Event Web Sales Setup";
    LookupPageID = "Event Web Sales Setup";

    fields
    {
        field(1;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item,G/L Account';
            OptionMembers = Item,"G/L Account";
        }
        field(2;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST(Item)) Item."No."
                            ELSE IF (Type=CONST("G/L Account")) "G/L Account"."No.";
        }
        field(10;"Event No.";Code[20])
        {
            Caption = 'Event No.';
            TableRelation = Job."No." WHERE (Event=CONST(true));
        }
    }

    keys
    {
        key(Key1;Type,"No.")
        {
        }
    }

    fieldgroups
    {
    }
}

