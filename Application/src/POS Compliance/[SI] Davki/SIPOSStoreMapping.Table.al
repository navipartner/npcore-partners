table 6150692 "NPR SI POS Store Mapping"
{
    Access = Internal;
    Caption = 'SI POS Store Mapping';
    DataClassification = CustomerContent;
    LookupPageId = "NPR SI POS Store Mapping";
    DrillDownPageId = "NPR SI POS Store Mapping";

    fields
    {
        field(1; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(2; Registered; Boolean)
        {
            Caption = 'Registered';
            DataClassification = CustomerContent;
        }
        field(3; "Cadastral Number"; Integer)
        {
            Caption = 'Cadastral Number';
            DataClassification = CustomerContent;
        }
        field(4; "Building Number"; Integer)
        {
            Caption = 'Building Number';
            DataClassification = CustomerContent;
        }
        field(5; "Building Section Number"; Integer)
        {
            Caption = 'Building Section Number';
            DataClassification = CustomerContent;
        }
        field(6; "Validity Date"; Date)
        {
            Caption = 'Validity Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Store Code")
        {
            Clustered = true;
        }
    }
}