table 6150964 "NPR MM Add. Info. Request"
{
    Caption = 'Additional Information Request Data';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Source Record"; RecordId)
        {
            Caption = 'Source Record';
            DataClassification = CustomerContent;
        }
        field(2; "Source Table"; Integer)
        {
            Caption = 'Source Table';
            DataClassification = CustomerContent;
        }
        field(3; "Login Hint"; Text[100])
        {
            Caption = 'Login Hint';
            DataClassification = CustomerContent;
        }
        field(4; "Scope"; Text[100])
        {
            Caption = 'Scope';
            DataClassification = CustomerContent;
        }
        field(5; "Environment"; Enum "NPR MM Add. Info. Req. Config.")
        {
            Caption = 'Environment';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Source Record")
        {
        }
    }
}
