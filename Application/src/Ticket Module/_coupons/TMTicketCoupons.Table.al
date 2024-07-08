table 6150843 "NPR TM TicketCoupons"
{
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; TicketNo; Code[20])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
        }
        field(2; CouponType; Code[20])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";
        }

        field(3; CouponAlias; Code[20])
        {
            Caption = 'Coupon Alias';
            DataClassification = CustomerContent;
        }


        field(15; CouponNo; Code[20])
        {
            Caption = 'Coupon No.';
            DataClassification = CustomerContent;
        }

        field(20; CouponReferenceNo; Text[50])
        {
            Caption = 'Coupon Reference No.';
            DataClassification = CustomerContent;
        }


        field(200; Open; Boolean)
        {
            CalcFormula = Max("NPR NpDc Coupon Entry".Open WHERE("Coupon No." = FIELD(CouponNo)));
            Caption = 'Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(201; RemainingQuantity; Decimal)
        {
            CalcFormula = Sum("NPR NpDc Coupon Entry"."Remaining Quantity" WHERE("Coupon No." = FIELD(CouponNo)));
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(202; InUseQuantity; Integer)
        {
            CalcFormula = Count("NPR NpDc SaleLinePOS Coupon" WHERE(Type = CONST(Coupon),
                                                                   "Coupon No." = FIELD(CouponNo)));
            Caption = 'In-use Quantity (POS)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(203; CouponIssued; Boolean)
        {
            CalcFormula = Exist("NPR NpDc Coupon Entry" WHERE("Coupon No." = FIELD(CouponNo),
                                                              "Entry Type" = const("Issue Coupon")));
            Caption = 'Coupon Issued';
            Editable = false;
            FieldClass = FlowField;
        }
        field(204; IssueDate; Date)
        {
            CalcFormula = min("NPR NpDc Coupon Entry"."Posting Date" where("Coupon No." = field(CouponNo),
                                                              "Entry Type" = const("Issue Coupon")));
            Caption = 'Issue Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(205; "In-use Quantity (Web)"; Integer)
        {
            CalcFormula = Count("NPR NpDc Ext. Coupon Reserv." WHERE("Coupon No." = FIELD(CouponNo)));
            Caption = 'In-use Quantity (Web)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(210; Archived; Boolean)
        {
            CalcFormula = Exist("NPR NpDc Arch. Coupon" WHERE("Reference No." = FIELD(CouponReferenceNo)));
            Caption = 'Archived';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; TicketNo, CouponType, CouponAlias)
        {
            Clustered = true;
        }

        key(key2; CouponNo) { }
        key(key3; CouponReferenceNo) { }

    }
}