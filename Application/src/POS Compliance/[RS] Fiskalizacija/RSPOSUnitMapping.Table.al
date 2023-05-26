table 6059819 "NPR RS POS Unit Mapping"
{
    Access = Internal;
    Caption = 'RS POS Unit Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS POS Unit Mapping";
    LookupPageId = "NPR RS POS Unit Mapping";

    fields
    {
        field(1; "POS Unit Code"; Code[10])
        {
            Caption = 'POS Unit Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(3; "POS Unit Name"; Text[50])
        {
            CalcFormula = lookup("NPR POS Unit".Name where("No." = field("POS Unit Code")));
            Caption = 'POS Unit Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "RS Sandbox PIN"; Integer)
        {
            Caption = 'Sandbox PIN';
            DataClassification = CustomerContent;
        }
        field(10; "RS Sandbox JID"; Code[15])
        {
            Caption = 'Sandbox JID';
            DataClassification = CustomerContent;
        }
        field(15; "RS Sandbox Token"; Guid)
        {
            Caption = 'Sandbox Token';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Unit Code")
        {
            Clustered = true;
        }
    }
}