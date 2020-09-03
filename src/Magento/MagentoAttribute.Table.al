table 6151426 "NPR Magento Attribute"
{
    // MAG1.00/MHA /20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MHA /20150115  CASE 199932 Field changes:
    //                                    - Deleted Field 4 Type
    //                                    - Deleted Field 100 "Group ID"
    //                                    - Renamed Field 20 "Type Of Choice" to Type
    // MAG1.04/MHA /20150206  CASE 199932 Added forced Type for Configurable Attribute and updated OnDelete
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.09/MHA /20180104  CASE 301054 Removed unused and blank text constant TxtAttributeCode
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object
    // MAG2.19/LS  /2019020  CASE 344251 Added field 15 Visible

    Caption = 'Magento Attribute';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Attr. List";
    LookupPageID = "NPR Magento Attr. List";

    fields
    {
        field(2; "Attribute ID"; Integer)
        {
            Caption = 'Attribute ID';
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; Filterable; Boolean)
        {
            Caption = 'Filterable';
            DataClassification = CustomerContent;
        }
        field(11; Position; Integer)
        {
            Caption = 'Position';
            DataClassification = CustomerContent;
        }
        field(15; Visible; Boolean)
        {
            Caption = 'Visible';
            DataClassification = CustomerContent;
        }
        field(20; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            InitValue = Multiple;
            OptionCaption = ',Single,Multiple,Text Area (single)';
            OptionMembers = ,Single,Multiple,"Text Area (single)";
        }
        field(30; "Used by Attribute Set"; Integer)
        {
            CalcFormula = Count ("NPR Magento Attr. Set Value" WHERE("Attribute ID" = FIELD("Attribute ID")));
            Caption = 'Used by Attribute Set';
            Editable = false;
            FieldClass = FlowField;
        }
        field(35; "Show Option Images Is Frontend"; Boolean)
        {
            Caption = 'Show Option Images Is Frontend';
            DataClassification = CustomerContent;
        }
        field(40; "Use in Product Listing"; Boolean)
        {
            Caption = 'Use in Product Listing';
            DataClassification = CustomerContent;
        }
        field(50; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(500; "Custom ID"; Boolean)
        {
            Caption = 'Custom ID';
            DataClassification = CustomerContent;
        }
        field(1000; "Used by Items"; Integer)
        {
            CalcFormula = Count ("NPR Magento Item Attr." WHERE("Attribute ID" = FIELD("Attribute ID")));
            Caption = 'Used by Items';
            Description = 'MAG2.00';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Attribute ID")
        {
        }
        key(Key2; Position)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ItemAttributeValue: Record "NPR Magento Item Attr. Value";
        AttributeLabel: Record "NPR Magento Attr. Label";
        AttributeSetValue: Record "NPR Magento Attr. Set Value";
    begin
        CalcFields("Used by Attribute Set", "Used by Items");

        if ("Used by Attribute Set" <> 0) or ("Used by Items" <> 0) then
            if not Confirm(ConfimDeleteUsedAttribute, false) then Error('');

        //-MAG1.04
        AttributeLabel.SetRange("Attribute ID", "Attribute ID");
        AttributeLabel.DeleteAll(true);

        AttributeSetValue.SetRange("Attribute ID", "Attribute ID");
        AttributeSetValue.DeleteAll(true);
        ;

        ItemAttributeValue.SetRange("Attribute ID", "Attribute ID");
        ItemAttributeValue.DeleteAll(true);
        //+MAG1.04
    end;

    trigger OnInsert()
    begin
        TestField(Description);

        //-MAG2.00
        //IF Configurable THEN
        //  Type := Type::Single
        //+MAG2.00
    end;

    trigger OnModify()
    begin
        TestField(Description);
    end;

    var
        ConfimDeleteUsedAttribute: Label 'Warning. This property is used by products. Do you wish to delete alle occurences of the property?';
        Err001: Label 'This setup can not be changed because it has already been applied to items.';
}

