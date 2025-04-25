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
        field(6; "EFT Transaction No."; Integer)
        {
            Caption = 'EFT Transaction No.';
            DataClassification = CustomerContent;
        }
        field(7; "Add. Info. Request"; Enum "NPR MM Add. Info. Request")
        {
            Caption = 'Add. Info. Request';
            DataClassification = CustomerContent;
        }
        field(8; "Data Collection Step"; Enum "NPR Data Collect Step")
        {
            Caption = 'Data Collection Step';
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
