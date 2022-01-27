table 6151408 "NPR Magento Tax Class"
{
    Access = Internal;
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
        field(2; Type; Enum "NPR Magento Tax Class Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(517; "Customer Config. Template Code"; Code[10])
        {
            Caption = 'Customer Config. Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Config. Template Header".Code WHERE("Table ID" = CONST(18));
        }
    }

    keys
    {
        key(Key1; Name, Type)
        {
        }
    }
}
