table 6059879 "NPR Total Disc Ben Item Buffer"
{
    DataClassification = CustomerContent;
    Access = Internal;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Total Discount Code"; Code[20])
        {
            Caption = 'Total Discount Code';
            TableRelation = "NPR Total Discount Header".Code;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(3; "Total Discount Step"; Decimal)
        {
            Caption = 'Total Discount Step';
            DataClassification = CustomerContent;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
            ValidateTableRelation = false;
        }

        field(5; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(7; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit Of Measure".Code WHERE("Item No." = FIELD("Item No."));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(8; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }

        field(9; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; ItemID; Guid)
        {
            Caption = 'ItemID';
            DataClassification = CustomerContent;
        }
        field(11; "Benefit List Code"; Code[20])
        {
            Caption = 'Benefit List Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Benefit List Header".Code;
            ValidateTableRelation = false;
        }
        field(12; "No Input Needed"; Boolean)
        {
            Caption = 'No Input Needed';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }

        key(Key2; "No Input Needed")
        {
        }

        key(Key3; "Benefit List Code")
        {
        }
        key(Key4; "Benefit List Code", "No Input Needed")
        {
        }

    }


}