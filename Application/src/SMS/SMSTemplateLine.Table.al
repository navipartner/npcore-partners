table 6059941 "NPR SMS Template Line"
{
    Access = Internal;
    Caption = 'SMS Template Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Code"; Code[10])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "SMS Text"; Text[250])
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Template Code", "Line No.")
        {
        }
    }

}

