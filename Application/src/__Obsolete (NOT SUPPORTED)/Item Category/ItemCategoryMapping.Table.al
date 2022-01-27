table 6060062 "NPR Item Category Mapping"
{
    Access = Internal;
    Caption = 'Item Category Mapping';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Item Group is obsolete.';

    fields
    {
        field(10; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Item Category";
        }
        field(20; "Item Group"; Code[10])
        {
            Caption = 'Item Group';
            DataClassification = CustomerContent;
            NotBlank = true;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using Item Category instead.';
        }
        field(30; "Item Material"; Code[20])
        {
            Caption = 'Item Material';
            DataClassification = CustomerContent;
        }
        field(40; "Item Material Density"; Code[20])
        {
            Caption = 'Item Material Density';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Item Category Code", "Item Material", "Item Material Density")
        {
        }
    }

    fieldgroups
    {
    }
}

