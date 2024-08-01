table 6150822 "NPR RS EI Allowed UOM"
{
    Access = Internal;
    Caption = 'RS EI Allowed Unit of Measures';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS EI Allowed UOM";
    LookupPageId = "NPR RS EI Allowed UOM";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[10])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "Configuration Date"; Date)
        {
            Caption = 'Configuration Date';
                      DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, Name) { }
    }
}