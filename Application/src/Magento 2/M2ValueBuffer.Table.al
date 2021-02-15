table 6151443 "NPR M2 Value Buffer"
{
    Caption = 'M2 Value Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
        field(5; "Label"; Text[250])
        {
            Caption = 'Label';
            DataClassification = CustomerContent;
        }
        field(10; Position; Integer)
        {
            Caption = 'Position';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Value)
        {
        }
        key(Key2; Position)
        {
        }
    }
}