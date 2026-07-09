table 6059962 "NPR MM Member Change Log"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Member Change Log';

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Member Entry No."; Integer)
        {
            Caption = 'Member Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member"."Entry No.";
        }
        field(20; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
        }
        field(30; "Old Value"; Text[250])
        {
            Caption = 'Old Value';
            DataClassification = CustomerContent;
        }
        field(40; "New Value"; Text[250])
        {
            Caption = 'New Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Member Entry No.")
        {
        }
    }
}
