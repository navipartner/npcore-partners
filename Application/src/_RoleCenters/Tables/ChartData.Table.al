table 6059832 "NPR Chart Data"
{
    Access = Internal;
    Caption = 'Chart Data';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Tracker Entry No."; Integer)
        {
            Caption = 'Tracker Entry No.';
            DataClassification = SystemMetadata;
            TableRelation = "NPR Chart Data Update Tracker";
        }
        field(2; "Key"; Text[250])
        {
            Caption = 'Key';
            DataClassification = SystemMetadata;
        }
        field(3; Val; Text[250])
        {
            Caption = 'Value';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Tracker Entry No.", "Key")
        {
            Clustered = true;
        }
    }
}