table 6151408 "NPR Magento Tax Class"
{
    // MAG1.05/MHA /20150223  CASE 206395 Object created
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.03/MHA /20170324  CASE 266871 Added field 517 "Customer Config. Template Code"

    Caption = 'Magento Tax Class';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Item,Customer';
            OptionMembers = Item,Customer;
        }
        field(517; "Customer Config. Template Code"; Code[10])
        {
            Caption = 'Customer Config. Template Code';
            DataClassification = CustomerContent;
            Description = 'MAG2.03';
            TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(18));
        }
    }

    keys
    {
        key(Key1; Name, Type)
        {
        }
    }

    fieldgroups
    {
    }
}

