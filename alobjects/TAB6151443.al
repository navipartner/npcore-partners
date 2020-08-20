table 6151443 "M2 Value Buffer"
{
    // MAG2.20/MHA /20190425  CASE 320423 Object created - Buffer used with M2 GET Apis

    Caption = 'M2 Value Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
        field(5; Label; Text[250])
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

    fieldgroups
    {
    }
}

