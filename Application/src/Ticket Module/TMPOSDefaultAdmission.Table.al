table 6014548 "NPR TM POS Default Admission"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'TM POS Default Admission';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
            Caption = 'Item No.';

        }
        field(2; "Variant Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
            Caption = 'Variant Code';
        }
        field(3; "Admission Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
            Caption = 'Admission Code';
        }
        field(5; "Station Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Station Type';
            OptionMembers = POS_UNIT,SCANNER_STATION;
            OptionCaption = 'POS Unit,Scanner Station';
        }
        field(6; "Station Identifier"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = if ("Station Type" = const(POS_UNIT)) "NPR POS Unit";
            Caption = 'POS Unit No.';
        }

        field(7; "Activation Method"; Option)
        {
            Caption = 'Default Activation Method';
            OptionMembers = ALWAYS,ON_SCAN,ON_SALES;
            OptionCaption = 'Always,Only when admitting,Only on sales';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Admission Code", "Station Type", "Station Identifier")
        {
            Clustered = true;
        }
    }

}
