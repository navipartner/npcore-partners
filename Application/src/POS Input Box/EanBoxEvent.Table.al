table 6060106 "NPR Ean Box Event"
{
    Access = Internal;

    Caption = 'Ean Box Event';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Input Box Events";
    LookupPageID = "NPR POS Input Box Events";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Module Name"; Text[50])
        {
            Caption = 'Module Name';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Action Code"; Code[20])
        {
            Caption = 'Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action";

            trigger OnValidate()
            begin
            end;
        }
        field(20; "Action Description"; Text[250])
        {
            CalcFormula = Lookup("NPR POS Action".Description WHERE(Code = FIELD("Action Code")));
            Caption = 'Action Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "POS View"; Option)
        {
            Caption = 'POS View';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale';
            OptionMembers = Sale;
        }
        field(35; "Event Codeunit"; Integer)
        {
            Caption = 'Event Codeunit';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

