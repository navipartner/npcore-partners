table 6151431 "NPR Magento Item Attr. Value"
{
    Caption = 'Magento Item Attribute Value';
    DataClassification = CustomerContent;

    fields
    {
        field(2; "Attribute ID"; Integer)
        {
            Caption = 'Attribute ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Attribute";
        }
        field(3; Type; Enum "NPR Magento Item Attr. Value")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            InitValue = Multiple;
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
                PictureName := MagentoFunctions.LookupPicture(Enum::"NPR Magento Picture Type"::Customer, Picture);
                if PictureName <> '' then
                    Picture := PictureName;
            end;
        }
        field(10; "Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Attribute Set";
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
            CalcFormula = Lookup("NPR Magento Attr. Label".Value WHERE("Attribute ID" = FIELD("Attribute ID"),
                                                                        "Line No." = FIELD("Attribute Label Line No.")));
            Caption = 'Value';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1000; "Attribute Description"; Text[50])
        {
            CalcFormula = Lookup("NPR Magento Attribute".Description WHERE("Attribute ID" = FIELD("Attribute ID")));
            Caption = 'Attribute';
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

    var
        MagentoFunctions: Codeunit "NPR Magento Functions";
}