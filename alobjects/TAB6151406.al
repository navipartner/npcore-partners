table 6151406 "Magento VAT Product Group"
{
    // MAG1.01/MH/20150116  CASE 199932 Object Created - Maps NAV VAT Product Posting Group to Magento Product Tax Class.
    // MAG1.05/20150223  CASE 206395 Added TableRelation to field 6059810 "Magento Tax Class"
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object
    // MAG2.18/MHA /20190314  CASE 348660 Increased field 1 "VAT Product Posting Group" from 10 to 20 in NAV2018 and newer

    Caption = 'Magento VAT Product Group';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "VAT Product Posting Group"; Code[20])
        {
            Caption = 'VAT Product Posting Group';
            DataClassification = CustomerContent;
            Description = 'MAG2.18';
            NotBlank = true;
            TableRelation = "VAT Product Posting Group";
        }
        field(2; Description; Text[50])
        {
            CalcFormula = Lookup ("VAT Product Posting Group".Description WHERE(Code = FIELD("VAT Product Posting Group")));
            Caption = 'Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6059810; "Magento Tax Class"; Text[250])
        {
            Caption = 'Magento Tax Class';
            DataClassification = CustomerContent;
            Description = 'MAG1.05';
            TableRelation = "Magento Tax Class" WHERE(Type = CONST(Item));
        }
    }

    keys
    {
        key(Key1; "VAT Product Posting Group")
        {
        }
    }

    fieldgroups
    {
    }
}

