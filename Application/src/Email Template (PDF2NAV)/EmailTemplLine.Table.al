table 6014463 "NPR E-mail Templ. Line"
{
    Caption = 'E-mail Template Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "E-mail Template Code"; Code[20])
        {
            Caption = 'E-mail Template Code';
            TableRelation = "NPR E-mail Template Header";
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Mail Body Line"; Text[250])
        {
            Caption = 'Mail Body Line';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "E-mail Template Code", "Line No.")
        {
        }
    }
}

