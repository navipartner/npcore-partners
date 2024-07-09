table 6151430 "NPR Magento Item Attr."
{
    Caption = 'Magento Item Attribute';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Magento Item Attr.";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(5; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(10; "Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Attribute Set";
        }
        field(15; "Attribute ID"; Integer)
        {
            Caption = 'Attribute ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Attribute";
        }
        field(1000; "Attribute Description"; Text[50])
        {
            CalcFormula = Lookup("NPR Magento Attribute".Description WHERE("Attribute ID" = FIELD("Attribute ID")));
            Caption = 'Attribute';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; Selected; Boolean)
        {
            CalcFormula = Max("NPR Magento Item Attr. Value".Selected WHERE("Attribute ID" = FIELD("Attribute ID"),
                                                                             "Item No." = FIELD("Item No."),
                                                                             "Variant Code" = FIELD("Variant Code")));
            Caption = 'Selected';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; "Attribute Group ID"; Integer)
        {
            CalcFormula = Lookup("NPR Magento Attr. Set Value"."Attribute Group ID" WHERE("Attribute Set ID" = FIELD("Attribute Set ID"),
                                                                                           "Attribute ID" = FIELD("Attribute ID")));
            Caption = 'Attribute Group ID';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
    }

    keys
    {
        key(Key1; "Attribute Set ID", "Attribute ID", "Item No.", "Variant Code")
        {
        }
        key(key2; "Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(Key3; SystemRowVersion)
        {
        }
#ENDIF
    }
}
