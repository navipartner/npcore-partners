table 6060152 "NPR Event Web Sales Setup"
{
    // NPR5.48/TJ  /20190124 CASE 263728 New object

    Caption = 'Event Web Sales Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Event Web Sales Setup";
    LookupPageID = "NPR Event Web Sales Setup";

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Item,G/L Account';
            OptionMembers = Item,"G/L Account";
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Item)) Item."No."
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"."No.";
        }
        field(10; "Event No."; Code[20])
        {
            Caption = 'Event No.';
            DataClassification = CustomerContent;
            TableRelation = Job."No." WHERE("NPR Event" = CONST(true));
        }
    }

    keys
    {
        key(Key1; Type, "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

