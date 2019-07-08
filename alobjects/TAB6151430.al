table 6151430 "Magento Item Attribute"
{
    // MAG1.00/MH/20150201  CASE 199932 Refactored Object from Web Integration.
    // MAG1.04/MH/20150206  CASE 199932 Table Changes:
    //                                 - Added field 1010 Selected
    //                                 - Added field 300 Enabled
    //                                 - Changed field 200 Configurable from flowfield to normal
    // MAG1.21/MHA/20151120 CASE 227734 Field 300 Enabled deleted
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object
    // MAG2.18/JDH /20181210 CASE 334163 Added Caption to field Attribute Group ID

    Caption = 'Magento Item Attribute';
    LookupPageID = "Magento Item Attributes";

    fields
    {
        field(1;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(5;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
        }
        field(10;"Attribute Set ID";Integer)
        {
            Caption = 'Attribute Set ID';
            TableRelation = "Magento Attribute Set";
        }
        field(15;"Attribute ID";Integer)
        {
            Caption = 'Attribute ID';
            TableRelation = "Magento Attribute";
        }
        field(1000;"Attribute Description";Text[50])
        {
            CalcFormula = Lookup("Magento Attribute".Description WHERE ("Attribute ID"=FIELD("Attribute ID")));
            Caption = 'Attribute';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010;Selected;Boolean)
        {
            CalcFormula = Max("Magento Item Attribute Value".Selected WHERE ("Attribute ID"=FIELD("Attribute ID"),
                                                                             "Item No."=FIELD("Item No."),
                                                                             "Variant Code"=FIELD("Variant Code")));
            Caption = 'Selected';
            Description = 'MAG1.04';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020;"Attribute Group ID";Integer)
        {
            CalcFormula = Lookup("Magento Attribute Set Value"."Attribute Group ID" WHERE ("Attribute Set ID"=FIELD("Attribute Set ID"),
                                                                                           "Attribute ID"=FIELD("Attribute ID")));
            Caption = 'Attribute Group ID';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Attribute Set ID","Attribute ID","Item No.","Variant Code")
        {
        }
    }

    fieldgroups
    {
    }
}

