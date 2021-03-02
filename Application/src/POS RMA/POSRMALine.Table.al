table 6150639 "NPR POS RMA Line"
{
    // NPR5.49/TSA /20190319 CASE 342090 Initial Version

    Caption = 'POS RMA Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Return Ticket No."; Code[20])
        {
            Caption = 'Return Ticket No.';
            DataClassification = CustomerContent;
        }
        field(15; "Return Line No."; Integer)
        {
            Caption = 'Return Line No.';
            DataClassification = CustomerContent;
        }
        field(20; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(30; "Returned Item No."; Code[20])
        {
            Caption = 'Returned Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(40; "Returned Quantity"; Decimal)
        {
            Caption = 'Returned Quantity';
            DataClassification = CustomerContent;
        }
        field(1000; "FF Total Qty Sold"; Decimal)
        {
            CalcFormula = Sum("NPR POS Sales Line".Quantity WHERE("Document No." = FIELD("Sales Ticket No."),
                                                           Type = CONST(Item),
                                                           "No." = FIELD("Returned Item No."),
                                                           "Line No." = FIELD("Line No. Filter")));
            Caption = 'FF Total Qty Sold';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "FF Total Qty Returned"; Decimal)
        {
            CalcFormula = Sum("NPR POS RMA Line"."Returned Quantity" WHERE("Sales Ticket No." = FIELD("Sales Ticket No."),
                                                                        "Returned Item No." = FIELD("Returned Item No."),
                                                                        "Return Line No." = FIELD("Line No. Filter")));
            Caption = 'FF Total Qty Returned';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1100; "Line No. Filter"; Integer)
        {
            Caption = 'Line No. Filter';
            FieldClass = FlowFilter;
        }
        field(6608; "Return Reason Code"; Code[10])
        {
            Caption = 'Return Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Return Reason";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "POS Entry No.")
        {
        }
        key(Key3; "Sales Ticket No.", "Returned Item No.")
        {
        }
        key(Key4; "Return Ticket No.")
        {
        }
    }

    fieldgroups
    {
    }
}

