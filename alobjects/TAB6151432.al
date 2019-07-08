table 6151432 "Magento Customer Group"
{
    // MAG1.05/MH/20150220  CASE 206395 Object created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object and field 1

    Caption = 'Magento Customer Group';
    DrillDownPageID = "Magento Customer Groups";
    LookupPageID = "Magento Customer Groups";

    fields
    {
        field(1;"Code";Text[30])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(6059810;"Magento Tax Class";Text[250])
        {
            Caption = 'Magento Tax Class';
            TableRelation = "Magento Tax Class" WHERE (Type=CONST(Customer));
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

