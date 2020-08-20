table 6060062 "Item Category Mapping"
{
    // NPR5.39/BR  /20180215  CASE 295322 Object Created
    // NPR5.45/RA  /20180827  CASE 295322 Added field 30 40 and added them to primary key
    // NPR5.48/TJ  /20181115  CASE 330832 Increased Length of field Item Category Code from 10 to 20

    Caption = 'Item Category Mapping';
    DataClassification = CustomerContent;
    DrillDownPageID = "Item Category Mapping";
    LookupPageID = "Item Category Mapping";

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
            TableRelation = "Item Group";
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

