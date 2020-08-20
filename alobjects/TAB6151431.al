table 6151431 "Magento Item Attribute Value"
{
    // MAG1.01/MH/20150201  CASE 199932 Refactored Object from Web Integration
    // MAG1.04/MH/20150206  CASE 199932 Tables changes:
    //                                 - Added field 10 Attribute Set ID
    //                                 - Added field 200 Configurable
    //                                 - Added field 300 Enabled
    //                                 - Added field 1000 Attribute Description
    // MAG1.14/MH/20150429  CASE 212526 Changed parameters for LookupPicture() to PictureType, PictureName
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object and field 17

    Caption = 'Magento Item Attribute Value';
    DataClassification = CustomerContent;

    fields
    {
        field(2; "Attribute ID"; Integer)
        {
            Caption = 'Attribute ID';
            DataClassification = CustomerContent;
            TableRelation = "Magento Attribute";
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            InitValue = Multiple;
            OptionCaption = ',Single,Multiple,Text Area (single)';
            OptionMembers = ,Single,Multiple,"Text Area (single)";
        }
        field(5; "Attribute Label Line No."; Integer)
        {
            Caption = 'Value Line No.';
            DataClassification = CustomerContent;
        }
        field(6; Picture; Text[200])
        {
            Caption = 'Image';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                PictureName: Text;
            begin
                //-MAG1.14
                //PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Attribute",MAXSTRLEN(Picture));
                PictureName := MagentoFunctions.LookupPicture(MagentoFunctions."PictureType.Attribute", Picture);
                //+MAG1.14
                if PictureName <> '' then
                    Picture := PictureName;
            end;
        }
        field(10; "Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            DataClassification = CustomerContent;
            Description = 'MAG1.04';
            TableRelation = "Magento Attribute Set";
        }
        field(13; Selected; Boolean)
        {
            Caption = 'Selected';
            DataClassification = CustomerContent;
        }
        field(16; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(17; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(100; "Long Value"; BLOB)
        {
            Caption = 'Long Value';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                RecRef: RecordRef;
                FieldRef: FieldRef;
            begin
                RecRef.GetTable(Rec);
                FieldRef := RecRef.Field(FieldNo("Long Value"));
                MagentoFunctions.NaviEditorEditBlob(FieldRef);
                RecRef.Modify(true);
            end;
        }
        field(110; Value; Text[100])
        {
            CalcFormula = Lookup ("Magento Attribute Label".Value WHERE("Attribute ID" = FIELD("Attribute ID"),
                                                                        "Line No." = FIELD("Attribute Label Line No.")));
            Caption = 'Value';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1000; "Attribute Description"; Text[50])
        {
            CalcFormula = Lookup ("Magento Attribute".Description WHERE("Attribute ID" = FIELD("Attribute ID")));
            Caption = 'Attribute';
            Description = 'MAG1.04';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Attribute ID", "Item No.", "Variant Code", "Attribute Label Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Description: Label 'Long Value';
        MagentoFunctions: Codeunit "Magento Functions";
}

