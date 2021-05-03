table 6060064 "NPR EAN Prefix per Country"
{
    Caption = 'EAN Prefix per Country';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; Prefix; Code[10])
        {
            Caption = 'Prefix';
            DataClassification = CustomerContent;
        }
        field(20; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}

