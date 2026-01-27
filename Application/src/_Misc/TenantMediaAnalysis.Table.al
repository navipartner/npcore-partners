table 6151279 "NPR Tenant Media Analysis"
{
    Access = Internal;
    Caption = 'Tenant Media Analysis';
    DataClassification = SystemMetadata;
    Extensible = false;
    TableType = Temporary;

    fields
    {
        field(1; "Object ID"; Integer)
        {
            Caption = 'Object ID';
            DataClassification = SystemMetadata;
        }
        field(2; "Object Name"; Text[250])
        {
            Caption = 'Object Name';
            DataClassification = SystemMetadata;
        }
        field(3; "Object Caption"; Text[250])
        {
            Caption = 'Object Caption';
            DataClassification = SystemMetadata;
        }
        field(4; "Media Fields Value Count"; Integer)
        {
            Caption = 'Media Fields Value Count';
            DataClassification = SystemMetadata;
        }
        field(5; "Media Fields Size"; BigInteger)
        {
            Caption = 'Media Fields Size (Bytes)';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Object ID")
        {
            Clustered = true;
        }
    }
}
