table 6150786 "NPR Execution Order On Sale"
{
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Sequence No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Codeunit ID"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Error Msg"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Sequence No.")
        {
            Clustered = true;
        }
    }
}