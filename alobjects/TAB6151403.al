table 6151403 "Magento Website Link"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MH/20150113  CASE 199932 Changed Table Structure
    // MAG1.07/MH/20150309  CASE 208131 Updated captions
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Magento Website Link';

    fields
    {
        field(1;"Website Code";Code[32])
        {
            Caption = 'Website Code';
            Description = 'MAG1.01';
            NotBlank = true;
            TableRelation = "Magento Website";
        }
        field(3;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            Description = 'MAG1.07';
            TableRelation = Item;
        }
        field(10;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(100;"Website Name";Text[250])
        {
            CalcFormula = Lookup("Magento Website".Name WHERE (Code=FIELD("Website Code")));
            Caption = 'Website Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Website Code","Item No.","Variant Code")
        {
        }
    }

    fieldgroups
    {
    }
}

