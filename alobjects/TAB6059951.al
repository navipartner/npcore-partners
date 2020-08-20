table 6059951 "Display Content"
{
    // NPR5.29/CLVA/20170118 CASE 256153 Changed field "Content Lines" to FlowField

    Caption = 'Display Content';
    DataClassification = CustomerContent;
    DrillDownPageID = "Display Content";
    LookupPageID = "Display Content";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(11; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Image,Video,Html';
            OptionMembers = Image,Video,Html;
        }
        field(12; "Content Lines"; Integer)
        {
            CalcFormula = Count ("Display Content Lines" WHERE("Content Code" = FIELD(Code)));
            Caption = 'Content Lines';
            FieldClass = FlowField;
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

