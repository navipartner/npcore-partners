table 6150823 "NPR RS EI UOM Mapping"
{
    Access = Internal;
    Caption = 'RS E-Invoice UOM Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS EI UOM Mapping";
    LookupPageId = "NPR RS EI UOM Mapping";

    fields
    {
        field(1; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
        }
        field(2; "RS EI UOM Code"; Code[10])
        {
            Caption = 'UOM Code';
            DataClassification = CustomerContent;
        }
        field(3; "RS EI UOM Name"; Text[10])
        {
            Caption = 'UOM Name';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Unit of Measure")
        {
            Clustered = true;
        }
    }
}