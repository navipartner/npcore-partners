table 6014633 "NPR Background Package Import"
{
    DataClassification = CustomerContent;
    Access = Internal;
    TableType = Temporary;

    fields
    {
        field(1; "Package Name"; Text[250])
        {
            Caption = 'Package Name';
            DataClassification = CustomerContent;
        }
        field(10; "Adjust Table Names"; Boolean)
        {
            Caption = 'Adjust Table Names';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Package Name")
        {
            Clustered = true;
        }
    }
}