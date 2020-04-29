table 6059995 "RSS Reader Activity"
{
    // NPR5.25/TS/20160510  CASE 233762 Added Published At as secondary key

    Caption = 'RSS Reader Activity';

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(2;Link;Text[250])
        {
            Caption = 'Link';
        }
        field(10;Title;Text[250])
        {
            Caption = 'Title';
        }
        field(20;"Published At";DateTime)
        {
            Caption = 'Published At';
        }
    }

    keys
    {
        key(Key1;"Code",Link)
        {
        }
        key(Key2;"Published At")
        {
        }
    }

    fieldgroups
    {
    }
}

