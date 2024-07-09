table 6151417 "NPR Magento Product Relation"
{
    Access = Internal;

    Caption = 'Magento Product Relation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Relation Type"; Enum "NPR Mag. Prod. Relation Type")
        {
            BlankZero = true;
            Caption = 'Relation Type';
            DataClassification = CustomerContent;
            InitValue = Relation;
        }
        field(2; "From Item No."; Code[20])
        {
            Caption = 'From Item No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Item WHERE("NPR Magento Item" = CONST(true));
        }
        field(3; "To Item No."; Code[20])
        {
            Caption = 'To Item No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Item WHERE("NPR Magento Item" = CONST(true));
        }
        field(4; Position; Integer)
        {
            Caption = 'Position';
            DataClassification = CustomerContent;
        }
        field(10; "To Item Description"; Text[100])
        {
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("To Item No.")));
            Caption = 'Description';
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
        key(Key1; "Relation Type", "From Item No.", "To Item No.")
        {
        }
        key(Key2; "Replication Counter")
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
