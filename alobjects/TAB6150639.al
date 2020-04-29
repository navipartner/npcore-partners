table 6150639 "POS RMA Line"
{
    // NPR5.49/TSA /20190319 CASE 342090 Initial Version

    Caption = 'POS RMA Line';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2;"POS Entry No.";Integer)
        {
            Caption = 'POS Entry No.';
        }
        field(10;"Return Ticket No.";Code[20])
        {
            Caption = 'Return Ticket No.';
        }
        field(15;"Return Line No.";Integer)
        {
            Caption = 'Return Line No.';
        }
        field(20;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
        }
        field(30;"Returned Item No.";Code[20])
        {
            Caption = 'Returned Item No.';
            TableRelation = Item;
        }
        field(40;"Returned Quantity";Decimal)
        {
            Caption = 'Returned Quantity';
        }
        field(1000;"FF Total Qty Sold";Decimal)
        {
            CalcFormula = Sum("Audit Roll".Quantity WHERE ("Sales Ticket No."=FIELD("Sales Ticket No."),
                                                           "Sale Type"=CONST(Sale),
                                                           Type=CONST(Item),
                                                           "No."=FIELD("Returned Item No."),
                                                           "Line No."=FIELD("Line No. Filter")));
            Caption = 'FF Total Qty Sold';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010;"FF Total Qty Returned";Decimal)
        {
            CalcFormula = Sum("POS RMA Line"."Returned Quantity" WHERE ("Sales Ticket No."=FIELD("Sales Ticket No."),
                                                                        "Returned Item No."=FIELD("Returned Item No."),
                                                                        "Return Line No."=FIELD("Line No. Filter")));
            Caption = 'FF Total Qty Returned';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1100;"Line No. Filter";Integer)
        {
            Caption = 'Line No. Filter';
            FieldClass = FlowFilter;
        }
        field(6608;"Return Reason Code";Code[10])
        {
            Caption = 'Return Reason Code';
            TableRelation = "Return Reason";
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"POS Entry No.")
        {
        }
        key(Key3;"Sales Ticket No.","Returned Item No.")
        {
        }
        key(Key4;"Return Ticket No.")
        {
        }
    }

    fieldgroups
    {
    }
}

