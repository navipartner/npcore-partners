tableextension 6014416 "NPR Salesperson/Purchaser" extends "Salesperson/Purchaser"
{
    fields
    {
        field(6014400; "NPR Register Password"; Code[20])
        {
            Caption = 'POS Unit Password';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014402; "NPR Hide Register Imbalance"; Boolean)
        {
            Caption = 'Hide Register Imbalance';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014403; "NPR Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR Aux. Value Entry"."Sales Amount (Actual)"
                            WHERE(
                                "Item Ledger Entry Type" = CONST(Sale),
                                "Salespers./Purch. Code" = FIELD(Code),
                                "Posting Date" = FIELD("Date Filter"),
                                "Item Category Code" = FIELD("NPR Item Category Filter"),
                                "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                "Item No." = FIELD("NPR Item Filter")));
            Caption = 'Sales (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014404; "NPR Discount Amount"; Decimal)
        {
            CalcFormula = - Sum("NPR Aux. Value Entry"."Discount Amount"
                                WHERE(
                                    "Item Ledger Entry Type" = CONST(Sale),
                                    "Salespers./Purch. Code" = FIELD(Code),
                                    "Posting Date" = FIELD("Date Filter"),
                                    "Item Category Code" = FIELD("NPR Item Category Filter"),
                                    "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter")));
            Caption = 'Discount Amount';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014405; "NPR COGS (LCY)"; Decimal)
        {
            CalcFormula = - Sum("NPR Aux. Value Entry"."Cost Amount (Actual)"
                                WHERE(
                                    "Item Ledger Entry Type" = CONST(Sale),
                                    "Salespers./Purch. Code" = FIELD(Code),
                                    "Posting Date" = FIELD("Date Filter"),
                                    "Item Category Code" = FIELD("NPR Item Category Filter"),
                                    "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter")));
            Caption = 'COGS (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014406; "NPR Item Category Filter"; Code[20])
        {
            Caption = 'Item Category Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
        }
        field(6014407; "NPR Sales (Qty.)"; Decimal)
        {
            CalcFormula = - Sum("NPR Aux. Value Entry"."Valued Quantity"
                                WHERE(
                                    "Item Ledger Entry Type" = CONST(Sale),
                                    "Salespers./Purch. Code" = FIELD(Code),
                                    "Posting Date" = FIELD("Date Filter"),
                                    "Item Category Code" = FIELD("NPR Item Category Filter"),
                                    "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                    "Item No." = FIELD("NPR Item Filter")));
            Caption = 'Sales (Qty.)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014408; "NPR Reverse Sales Ticket"; Option)
        {
            Caption = 'Reverse Sales Ticket';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            OptionCaption = 'Yes,No';
            OptionMembers = Yes,No;
            ObsoleteState = Removed;
            ObsoleteReason = 'Won''t be used anymore';
        }
        field(6014410; "NPR Register Filter"; Code[10])
        {
            Caption = 'Register Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "NPR POS Unit";
        }
        field(6014411; "NPR Global Dimension 1 Filter"; Code[20])
        {
            Caption = 'Global Dimension 1 Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(6014412; "NPR Item Group Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR Aux. Value Entry"."Sales Amount (Actual)"
                            WHERE("Item Ledger Entry Type" = CONST(Sale),
                                "Salespers./Purch. Code" = FIELD(Code),
                                "Posting Date" = FIELD("Date Filter"),
                                "Item Category Code" = FIELD("NPR Item Category Filter"),
                                "Global Dimension 1 Code" = FIELD("NPR Global Dimension 1 Filter"),
                                "Group Sale" = CONST(true)));
            Caption = 'Item Group Sales (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014413; "NPR Item Filter"; Code[20])
        {
            Caption = 'Item Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
        }
        field(6014416; "NPR Locked-to Register No."; Code[10])
        {
            Caption = 'Locked-to POS Unit No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014420; "NPR Maximum Cash Returnsale"; Decimal)
        {
            Caption = 'Maximum Cash Returnsale';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014421; "NPR Picture"; BLOB)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
            Description = 'NPR5.26';
            SubType = Bitmap;
        }
        field(6014422; "NPR Supervisor POS"; Boolean)
        {
            Caption = 'Supervisor POS';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
    }
}

