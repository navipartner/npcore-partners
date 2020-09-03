table 6151427 "NPR Magento Attr. Label"
{
    // MAG1.01/MH/20150201  CASE 199932 Refactored Object from Web Integration
    // MAG1.04/MH/20150216  CASE 199932 Updated OnDelete
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Magento Attribute Label';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Attr. Labels";
    LookupPageID = "NPR Magento Attr. Labels";

    fields
    {
        field(2; "Attribute ID"; Integer)
        {
            Caption = 'Attribute ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Attribute";
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; Value; Text[100])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SpecChoices: Record "NPR Magento Attr. Label";
            begin
            end;
        }
        field(6; Image; Text[200])
        {
            Caption = 'Image';
            DataClassification = CustomerContent;
        }
        field(9; "Sorting"; Integer)
        {
            Caption = 'Sorting';
            DataClassification = CustomerContent;
        }
        field(100; "Text Field"; BLOB)
        {
            Caption = 'Text Field';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                RecRef: RecordRef;
                FieldRef: FieldRef;
            begin
                RecRef.GetTable(Rec);
                FieldRef := RecRef.Field(FieldNo("Text Field"));
                NaviConnectFunctions.NaviEditorEditBlob(FieldRef);
                RecRef.Modify(true);
            end;
        }
    }

    keys
    {
        key(Key1; "Attribute ID", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ItemAttributeValue: Record "NPR Magento Item Attr. Value";
    begin
        //-MAG1.04
        ItemAttributeValue.SetRange("Attribute ID", "Attribute ID");
        ItemAttributeValue.SetRange("Attribute Label Line No.", "Line No.");
        ItemAttributeValue.DeleteAll(true);
        //+MAG1.04
    end;

    var
        NaviConnectFunctions: Codeunit "NPR Magento Functions";
}

