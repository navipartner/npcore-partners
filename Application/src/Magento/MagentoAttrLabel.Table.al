table 6151427 "NPR Magento Attr. Label"
{
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

    trigger OnDelete()
    var
        ItemAttributeValue: Record "NPR Magento Item Attr. Value";
    begin
        ItemAttributeValue.SetRange("Attribute ID", "Attribute ID");
        ItemAttributeValue.SetRange("Attribute Label Line No.", "Line No.");
        ItemAttributeValue.DeleteAll(true);
    end;

    var
        NaviConnectFunctions: Codeunit "NPR Magento Functions";
}
