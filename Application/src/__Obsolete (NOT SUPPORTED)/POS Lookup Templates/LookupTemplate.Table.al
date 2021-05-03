table 6014626 "NPR Lookup Template"
{
    Caption = 'Lookup Template';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(11; Class; Text[30])
        {
            Caption = 'Class';
            DataClassification = CustomerContent;
        }
        field(12; "Value Field No."; Integer)
        {
            Caption = 'Value Field No.';
            DataClassification = CustomerContent;
        }
        field(14; "Preemptive Push"; Boolean)
        {
            Caption = 'Preemptive Push';
            DataClassification = CustomerContent;
        }
        field(15; "Sort By Field No."; Integer)
        {
            Caption = 'Sort By Field No.';
            DataClassification = CustomerContent;
        }
        field(16; "Sorting Order"; Option)
        {
            Caption = 'Sorting Order';
            OptionCaption = 'Ascending,Descending';
            OptionMembers = "Ascending","Descending";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table No.")
        {
        }
    }

    fieldgroups
    {
    }
}

