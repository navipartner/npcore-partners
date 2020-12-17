table 6150627 "NPR POS Workshift Checkpoint"
{
    Caption = 'POS Workshift Checkpoint';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Workshift Checkpoints";
    LookupPageID = "NPR POS Workshift Checkpoints";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(5; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(6; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(7; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
        }
        field(8; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,X-Report,Z-Report,Transfer,Period Report,,Workshift Close';
            OptionMembers = NA,XREPORT,ZREPORT,TRANSFER,PREPORT,,WORKSHIFT_CLOSE;
        }
        field(9; "Consolidated With Entry No."; Integer)
        {
            Caption = 'Consolidated With Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Debtor Payment (LCY)"; Decimal)
        {
            Caption = 'Debtor Payment (LCY)';
            DataClassification = CustomerContent;
        }
        field(11; "Period Type"; Code[20])
        {
            Caption = 'Period Type';
            DataClassification = CustomerContent;
        }
        field(20; "GL Payment (LCY)"; Decimal)
        {
            Caption = 'GL Payment (LCY)';
            DataClassification = CustomerContent;
        }
        field(25; "Rounding (LCY)"; Decimal)
        {
            Caption = 'Rounding (LCY)';
            DataClassification = CustomerContent;
        }
        field(30; "Credit Item Sales (LCY)"; Decimal)
        {
            Caption = 'Credit Item Sales (LCY)';
            DataClassification = CustomerContent;
        }
        field(35; "Credit Item Quantity Sum"; Decimal)
        {
            Caption = 'Credit Item Quantity Sum';
            DataClassification = CustomerContent;
        }
        field(37; "Credit Net Sales Amount (LCY)"; Decimal)
        {
            Caption = 'Credit Net Sales Amount (LCY)';
            DataClassification = CustomerContent;
            Description = 'TO BE REMOVE';
        }
        field(38; "Credit Sales Count"; Integer)
        {
            Caption = 'Credit Sales Count';
            DataClassification = CustomerContent;
        }
        field(39; "Credit Sales Amount (LCY)"; Decimal)
        {
            Caption = 'Credit Sales Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(40; "Issued Vouchers (LCY)"; Decimal)
        {
            Caption = 'Issued Vouchers (LCY)';
            DataClassification = CustomerContent;
        }
        field(41; "Redeemed Vouchers (LCY)"; Decimal)
        {
            Caption = 'Redeemed Vouchers (LCY)';
            DataClassification = CustomerContent;
        }
        field(50; "Local Currency (LCY)"; Decimal)
        {
            Caption = 'Local Currency (LCY)';
            DataClassification = CustomerContent;
        }
        field(60; "Foreign Currency (LCY)"; Decimal)
        {
            Caption = 'Foreign Currency (LCY)';
            DataClassification = CustomerContent;
        }
        field(70; "EFT (LCY)"; Decimal)
        {
            Caption = 'EFT (LCY)';
            DataClassification = CustomerContent;
        }
        field(80; "Manual Card (LCY)"; Decimal)
        {
            Caption = 'Manual Card (LCY)';
            DataClassification = CustomerContent;
            Description = 'TO BE REMOVE';
        }
        field(90; "Other Credit Card (LCY)"; Decimal)
        {
            Caption = 'Other Credit Card (LCY)';
            DataClassification = CustomerContent;
            Description = 'TO BE REMOVE';
        }
        field(100; "Cash Terminal (LCY)"; Decimal)
        {
            Caption = 'Cash Terminal (LCY)';
            DataClassification = CustomerContent;
            Description = 'TO BE REMOVE';
        }
        field(110; "Redeemed Credit Voucher (LCY)"; Decimal)
        {
            Caption = 'Redeemed Credit Voucher (LCY)';
            DataClassification = CustomerContent;
            Description = 'TO BE REMOVE';
        }
        field(111; "Created Credit Voucher (LCY)"; Decimal)
        {
            Caption = 'Created Credit Voucher (LCY)';
            DataClassification = CustomerContent;
            Description = 'TO BE REMOVE';
        }
        field(120; "Direct Item Sales (LCY)"; Decimal)
        {
            Caption = 'Direct Item Sales (LCY)';
            DataClassification = CustomerContent;
        }
        field(121; "Direct Sales - Staff (LCY)"; Decimal)
        {
            Caption = 'Direct Sales - Staff (LCY)';
            DataClassification = CustomerContent;
        }
        field(122; "Direct Item Net Sales (LCY)"; Decimal)
        {
            Caption = 'Direct Item Net Sales (LCY)';
            DataClassification = CustomerContent;
        }
        field(123; "Direct Item Sales Quantity"; Decimal)
        {
            Caption = 'Direct Item Sales Quantity';
            DataClassification = CustomerContent;
        }
        field(125; "Direct Sales Count"; Integer)
        {
            Caption = 'Direct Sales Count';
            DataClassification = CustomerContent;
        }
        field(127; "Cancelled Sales Count"; Integer)
        {
            Caption = 'Cancelled Sales Count';
            DataClassification = CustomerContent;
        }
        field(130; "Net Turnover (LCY)"; Decimal)
        {
            Caption = 'Net Turnover (LCY)';
            DataClassification = CustomerContent;
        }
        field(131; "Turnover (LCY)"; Decimal)
        {
            Caption = 'Turnover (LCY)';
            DataClassification = CustomerContent;
        }
        field(132; "Direct Turnover (LCY)"; Decimal)
        {
            Caption = 'Direct Turnover (LCY)';
            DataClassification = CustomerContent;
        }
        field(133; "Direct Negative Turnover (LCY)"; Decimal)
        {
            Caption = 'Direct Negative Turnover (LCY)';
            DataClassification = CustomerContent;
        }
        field(134; "Direct Net Turnover (LCY)"; Decimal)
        {
            Caption = 'Direct Net Turnover (LCY)';
            DataClassification = CustomerContent;
        }
        field(140; "Net Cost (LCY)"; Decimal)
        {
            Caption = 'Net Cost (LCY)';
            DataClassification = CustomerContent;
        }
        field(150; "Profit Amount (LCY)"; Decimal)
        {
            Caption = 'Profit Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(155; "Profit %"; Decimal)
        {
            Caption = 'Profit %';
            DataClassification = CustomerContent;
        }
        field(160; "Direct Item Returns (LCY)"; Decimal)
        {
            Caption = 'Direct Item Returns (LCY)';
            DataClassification = CustomerContent;
        }
        field(165; "Direct Item Returns Line Count"; Integer)
        {
            Caption = 'Direct Item Returns Line Count';
            DataClassification = CustomerContent;
        }
        field(166; "Direct Item Returns Quantity"; Decimal)
        {
            Caption = 'Direct Item Returns Quantity';
            DataClassification = CustomerContent;
        }
        field(170; "Credit Real. Sale Amt. (LCY)"; Decimal)
        {
            Caption = 'Credit Real. Sale Amt. (LCY)';
            DataClassification = CustomerContent;
        }
        field(171; "Credit Unreal. Sale Amt. (LCY)"; Decimal)
        {
            Caption = 'Credit Unreal. Sale Amt. (LCY)';
            DataClassification = CustomerContent;
        }
        field(172; "Credit Real. Return Amt. (LCY)"; Decimal)
        {
            Caption = 'Credit Real. Return Amt. (LCY)';
            DataClassification = CustomerContent;
        }
        field(173; "Credit Unreal. Ret. Amt. (LCY)"; Decimal)
        {
            Caption = 'Credit Unreal. Ret. Amt. (LCY)';
            DataClassification = CustomerContent;
        }
        field(180; "Credit Turnover (LCY)"; Decimal)
        {
            Caption = 'Credit Turnover (LCY)';
            DataClassification = CustomerContent;
        }
        field(181; "Credit Net Turnover (LCY)"; Decimal)
        {
            Caption = 'Credit Net Turnover (LCY)';
            DataClassification = CustomerContent;
        }
        field(200; "Total Discount (LCY)"; Decimal)
        {
            Caption = 'Total Discount (LCY)';
            DataClassification = CustomerContent;
        }
        field(201; "Total Net Discount (LCY)"; Decimal)
        {
            Caption = 'Total Net Discount (LCY)';
            DataClassification = CustomerContent;
        }
        field(205; "Total Discount %"; Decimal)
        {
            Caption = 'Total Discount %';
            DataClassification = CustomerContent;
        }
        field(210; "Campaign Discount (LCY)"; Decimal)
        {
            Caption = 'Campaign Discount (LCY)';
            DataClassification = CustomerContent;
        }
        field(215; "Campaign Discount %"; Decimal)
        {
            Caption = 'Campaign Discount %';
            DataClassification = CustomerContent;
        }
        field(220; "Mix Discount (LCY)"; Decimal)
        {
            Caption = 'Mix Discount (LCY)';
            DataClassification = CustomerContent;
        }
        field(225; "Mix Discount %"; Decimal)
        {
            Caption = 'Mix Discount %';
            DataClassification = CustomerContent;
        }
        field(230; "Quantity Discount (LCY)"; Decimal)
        {
            Caption = 'Quantity Discount (LCY)';
            DataClassification = CustomerContent;
        }
        field(235; "Quantity Discount %"; Decimal)
        {
            Caption = 'Quantity Discount %';
            DataClassification = CustomerContent;
        }
        field(240; "Custom Discount (LCY)"; Decimal)
        {
            Caption = 'Custom Discount (LCY)';
            DataClassification = CustomerContent;
        }
        field(245; "Custom Discount %"; Decimal)
        {
            Caption = 'Custom Discount %';
            DataClassification = CustomerContent;
        }
        field(250; "BOM Discount (LCY)"; Decimal)
        {
            Caption = 'BOM Discount (LCY)';
            DataClassification = CustomerContent;
        }
        field(255; "BOM Discount %"; Decimal)
        {
            Caption = 'BOM Discount %';
            DataClassification = CustomerContent;
        }
        field(260; "Customer Discount (LCY)"; Decimal)
        {
            Caption = 'Customer Discount (LCY)';
            DataClassification = CustomerContent;
        }
        field(265; "Customer Discount %"; Decimal)
        {
            Caption = 'Customer Discount %';
            DataClassification = CustomerContent;
        }
        field(270; "Line Discount (LCY)"; Decimal)
        {
            Caption = 'Line Discount (LCY)';
            DataClassification = CustomerContent;
        }
        field(275; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DataClassification = CustomerContent;
        }
        field(300; "Calculated Diff (LCY)"; Decimal)
        {
            Caption = 'Calculated Diff (LCY)';
            DataClassification = CustomerContent;
        }
        field(400; "Direct Item Quantity Sum"; Decimal)
        {
            Caption = 'Direct Item Quantity Sum';
            DataClassification = CustomerContent;
        }
        field(401; "Direct Item Sales Line Count"; Integer)
        {
            Caption = 'Direct Item Sales Line Count';
            DataClassification = CustomerContent;
        }
        field(405; "Receipts Count"; Integer)
        {
            Caption = 'Receipts Count';
            DataClassification = CustomerContent;
        }
        field(410; "Cash Drawer Open Count"; Integer)
        {
            Caption = 'Cash Drawer Open Count';
            DataClassification = CustomerContent;
        }
        field(415; "Receipt Copies Count"; Integer)
        {
            Caption = 'Receipt Copies Count';
            DataClassification = CustomerContent;
        }
        field(420; "Receipt Copies Sales (LCY)"; Decimal)
        {
            Caption = 'Receipt Copies Sales (LCY)';
            DataClassification = CustomerContent;
        }
        field(500; "Bin Transfer Out Amount (LCY)"; Decimal)
        {
            Caption = 'Bin Transfer Out Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(510; "Bin Transfer In Amount (LCY)"; Decimal)
        {
            Caption = 'Bin Transfer In Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(1000; "Opening Cash (LCY)"; Decimal)
        {
            Caption = 'Opening Cash (LCY)';
            DataClassification = CustomerContent;
        }
        field(2120; "Perpetual Dir. Item Sales(LCY)"; Decimal)
        {
            Caption = 'Perpetual Dir. Item Sales(LCY)';
            DataClassification = CustomerContent;
        }
        field(2160; "Perpetual Dir. Item Ret. (LCY)"; Decimal)
        {
            Caption = 'Perpetual Dir. Item Ret. (LCY)';
            DataClassification = CustomerContent;
        }
        field(2170; "Perpetual Dir. Turnover (LCY)"; Decimal)
        {
            Caption = 'Perpetual Dir. Turnover (LCY)';
            DataClassification = CustomerContent;
        }
        field(2180; "Perpetual Dir. Neg. Turn (LCY)"; Decimal)
        {
            Caption = 'Perpetual Dir. Neg. Turn (LCY)';
            DataClassification = CustomerContent;
        }
        field(2190; "Perpetual Rounding Amt. (LCY)"; Decimal)
        {
            Caption = 'Perpetual Rounding Amt. (LCY)';
            DataClassification = CustomerContent;
        }
        field(3002; "POS Unit No. Filter"; Code[10])
        {
            Caption = 'POS Unit No. Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR POS Unit";
        }
        field(3006; "Open Filter"; Boolean)
        {
            Caption = 'Open Filter';
            FieldClass = FlowFilter;
        }
        field(3007; "POS Entry No. Filter"; Integer)
        {
            Caption = 'POS Entry No. Filter';
            FieldClass = FlowFilter;
        }
        field(3008; "Type Filter"; Option)
        {
            Caption = 'Type Filter';
            FieldClass = FlowFilter;
            OptionCaption = ' ,X-Report,Z-Report,Transfer,Period Report,Annual Report';
            OptionMembers = NA,XREPORT,ZREPORT,TRANSFER,PREPORT,YREPORT;
        }
        field(3120; "FF Total Dir. Item Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR POS Workshift Checkpoint"."Direct Item Sales (LCY)" WHERE("POS Unit No." = FIELD("POS Unit No. Filter"),
                                                                                          Type = FIELD("Type Filter"),
                                                                                          "POS Entry No." = FIELD("POS Entry No. Filter"),
                                                                                          Open = FIELD("Open Filter")));
            Caption = 'FF Total Dir. Item Sales (LCY)';
            FieldClass = FlowField;
        }
        field(3160; "FF Total Dir. Item Return(LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR POS Workshift Checkpoint"."Direct Item Returns (LCY)" WHERE("POS Unit No." = FIELD("POS Unit No. Filter"),
                                                                                            Type = FIELD("Type Filter"),
                                                                                            "POS Entry No." = FIELD("POS Entry No. Filter"),
                                                                                            Open = FIELD("Open Filter")));
            Caption = 'FF Total Dir. Item Return (LCY)';
            FieldClass = FlowField;
        }
        field(3170; "FF Total Dir. Turnover (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR POS Workshift Checkpoint"."Direct Turnover (LCY)" WHERE("POS Unit No." = FIELD("POS Unit No. Filter"),
                                                                                        Type = FIELD("Type Filter"),
                                                                                        "POS Entry No." = FIELD("POS Entry No. Filter"),
                                                                                        Open = FIELD("Open Filter")));
            Caption = 'FF Total Dir. Turnover (LCY)';
            FieldClass = FlowField;
        }
        field(3180; "FF Total Dir. Neg. Turn. (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR POS Workshift Checkpoint"."Direct Negative Turnover (LCY)" WHERE("POS Unit No." = FIELD("POS Unit No. Filter"),
                                                                                                 Type = FIELD("Type Filter"),
                                                                                                 "POS Entry No." = FIELD("POS Entry No. Filter"),
                                                                                                 Open = FIELD("Open Filter")));
            Caption = 'FF Total Dir. Neg. Turn. (LCY)';
            FieldClass = FlowField;
        }
        field(3190; "FF Total Rounding Amt. (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR POS Workshift Checkpoint"."Rounding (LCY)" WHERE("POS Unit No." = FIELD("POS Unit No. Filter"),
                                                                                 Type = FIELD("Type Filter"),
                                                                                 "POS Entry No." = FIELD("POS Entry No. Filter"),
                                                                                 Open = FIELD("Open Filter")));
            Caption = 'FF Total Rounding Amt. (LCY)';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Consolidated With Entry No.")
        {
        }
        key(Key3; "POS Unit No.", Open, "Type")
        {
        }
        key(Key4; "POS Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

