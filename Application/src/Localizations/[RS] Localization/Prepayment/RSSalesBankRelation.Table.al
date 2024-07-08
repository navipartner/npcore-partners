table 6060036 "NPR RS Sales Bank Relation"
{
    Caption = 'RS Sales Bank Relation';
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sales Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Document No.';
        }
        field(2; "Bank Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Bank Document No.';
        }
        field(3; "Bank Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Bank Entry No.';
        }
    }

    keys
    {
        key(Key1; "Sales Document No.", "Bank Document No.")
        {
            Clustered = true;
        }
    }
}