table 6060165 "NPR Event Exc.Int.Summ. Buffer"
{
    Access = Internal;
    Caption = 'Event Exc. Int. Summary Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Parent Entry No."; Integer)
        {
            Caption = 'Parent Entry No.';
            DataClassification = CustomerContent;
        }
        field(11; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
        }
        field(20; "Exchange Item"; Text[50])
        {
            Caption = 'Exchange Item';
            DataClassification = CustomerContent;
        }
        field(30; "E-mail Account"; Text[250])
        {
            Caption = 'E-mail Account';
            DataClassification = CustomerContent;
        }
        field(40; Source; Text[250])
        {
            Caption = 'Source';
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

