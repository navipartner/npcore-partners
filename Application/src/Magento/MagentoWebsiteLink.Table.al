table 6151403 "NPR Magento Website Link"
{
    Access = Internal;
    Caption = 'Magento Website Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Website Code"; Code[32])
        {
            Caption = 'Website Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Magento Website";
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(10; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(100; "Website Name"; Text[250])
        {
            CalcFormula = Lookup("NPR Magento Website".Name WHERE(Code = FIELD("Website Code")));
            Caption = 'Website Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Website Code", "Item No.", "Variant Code")
        {
        }
        key(Key2; "Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(Key4; SystemRowVersion)
        {
        }
#ENDIF
    }
}
