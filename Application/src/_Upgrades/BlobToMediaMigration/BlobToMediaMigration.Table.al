table 6014579 "NPR Blob To Media Migration"
{
    DataClassification = SystemMetadata;
    Caption = 'Blob To Media Migration';

    fields
    {
        field(1; "Table No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table No.';
        }
        field(2; Id; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Id';
        }
        field(3; Ordinal; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Ordinal';
        }
        field(4; "Error"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Error';
        }
    }

    keys
    {
        key(Key1; "Table No.", Id)
        {
            Clustered = true;
        }
        key(Key2; "Table No.", SystemCreatedAt)
        {
        }
        key(Key3; "Table No.", Ordinal)
        {
        }
    }
}