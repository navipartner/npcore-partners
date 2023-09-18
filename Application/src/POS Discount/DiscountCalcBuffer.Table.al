table 6060029 "NPR Discount Calc. Buffer"
{
    Caption = 'Discount Calc Buffer';
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
        field(10; "Discount Code"; Code[20])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;

        }
        field(20; "Discount Line No."; Integer)
        {
            Caption = 'Discount Line No.';
            DataClassification = CustomerContent;
        }
        field(30; "Disc. Grouping Type"; Enum "NPR Disc. Grouping Type")
        {
            Caption = 'Disc. Grouping Type';
            DataClassification = CustomerContent;
        }
        field(40; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }

        field(50; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(60; "Discount Record ID"; Recordid)
        {
            Caption = 'Discount Record ID';
            DataClassification = CustomerContent;
        }
        field(70; "Sales Register No."; Code[10])
        {
            Caption = 'Sales Register No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Unit";
        }

        field(80; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(90; "Sales Date"; Date)
        {
            Caption = 'Sales Date';
            DataClassification = CustomerContent;
        }
        field(100; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;
        }

        field(110; "Sales Record ID"; RecordID)
        {
            Caption = 'Sales Record ID';
            DataClassification = CustomerContent;
        }
        field(120; "Sales Quantity"; Decimal)
        {
            Caption = 'Sales Quantity';
            DataClassification = CustomerContent;
        }
        field(130; "Actual Discount Amount"; Decimal)
        {
            Caption = 'Actual Discount Amount';
            DataClassification = CustomerContent;
        }
        field(140; "Actual Item Qty."; Decimal)
        {
            Caption = 'Actual Item Qty.';
            DataClassification = CustomerContent;
        }
        field(150; "Not Discounted Lines Exist"; Boolean)
        {
            Caption = 'Not Discounted Lines Exist';
            DataClassification = CustomerContent;
        }

        field(160; "Not Discounted Lines Quantity"; Decimal)
        {
            Caption = 'Not Discounted Lines Quantity';
            DataClassification = CustomerContent;
        }

        field(170; Recalculate; Boolean)
        {
            Caption = 'Recalculate';
            DataClassification = CustomerContent;
        }
        field(180; "Discount. Min. Quantity"; Decimal)
        {
            Caption = 'Discount. Min. Quantity';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }

        key(Key2; "Sales Record ID", "Discount Record ID")
        {
        }

        key(Key3; "Discount Code")
        {
        }
        key(Key4; "Recalculate", "Actual Discount Amount", "Actual Item Qty.")
        {
        }
        key(Key5; "Actual Discount Amount", "Actual Item Qty.")
        {
        }
        key(Key6; "Actual Discount Amount", "Actual Item Qty.", "Discount. Min. Quantity", "Discount Code")
        {
        }


    }
}