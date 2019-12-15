table 6151443 "M2 Value Buffer"
{
    // MAG2.20/MHA /20190425  CASE 320423 Object created - Buffer used with M2 GET Apis

    Caption = 'M2 Value Buffer';

    fields
    {
        field(1;Value;Text[250])
        {
            Caption = 'Value';
        }
        field(5;Label;Text[250])
        {
            Caption = 'Label';
        }
        field(10;Position;Integer)
        {
            Caption = 'Position';
        }
    }

    keys
    {
        key(Key1;Value)
        {
        }
        key(Key2;Position)
        {
        }
    }

    fieldgroups
    {
    }
}

