table 6151558 "NPR NpXml Field Val. Buffer"
{
    Caption = 'NpXml Field Value Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Field Value"; Text[250])
        {
            Caption = 'Field Value';
            DataClassification = CustomerContent;
        }
        field(100; Description; Text[250])
        {
            Caption = 'Description';
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

