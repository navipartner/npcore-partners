table 6151281 "NPR Tenant Media Field Detail"
{
    Access = Internal;
    Caption = 'Tenant Media Field Detail';
    DataClassification = SystemMetadata;
    Extensible = false;
    TableType = Temporary;
    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = SystemMetadata;
        }
        field(2; "Field Name"; Text[250])
        {
            Caption = 'Field Name';
            DataClassification = SystemMetadata;
        }
        field(3; "Field Size"; BigInteger)
        {
            Caption = 'Field Size (Bytes)';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(Key1; "Table ID", "Field Name")
        {
            Clustered = true;
        }
    }
}
