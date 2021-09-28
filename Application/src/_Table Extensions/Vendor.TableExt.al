tableextension 6014424 "NPR Vendor" extends Vendor
{
    fields
    {
        field(6014400; "NPR Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("NPR Aux. Value Entry"."Sales Amount (Actual)"
                            WHERE(
                                "Item Ledger Entry Type" = CONST(Sale),
                                "Vendor No." = FIELD("No."),
                                "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                "Posting Date" = FIELD("Date Filter"),
                                "Item Category Code" = FIELD("NPR Item Category Filter"),
                                "Salespers./Purch. Code" = FIELD("NPR Salesperson Filter")));
            Caption = 'Sales (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014401; "NPR COGS (LCY)"; Decimal)
        {
            CalcFormula = - Sum("NPR Aux. Value Entry"."Cost Amount (Actual)"
                                WHERE(
                                    "Item Ledger Entry Type" = CONST(Sale),
                                    "Vendor No." = FIELD("No."),
                                    "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                    "Posting Date" = FIELD("Date Filter"),
                                    "Item Category Code" = FIELD("NPR Item Category Filter"),
                                    "Salespers./Purch. Code" = FIELD("NPR Salesperson Filter")));
            Caption = 'COGS (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014402; "NPR Auto"; Boolean)
        {
            Caption = 'Auto';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014403; "NPR Item Category Filter"; Code[20])
        {
            Caption = 'Item Group Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "Item Category";
        }
        field(6014404; "NPR Sales (Qty.)"; Decimal)
        {
            CalcFormula = - Sum("NPR Aux. Value Entry"."Invoiced Quantity"
                                WHERE(
                                    "Item Ledger Entry Type" = CONST(Sale),
                                    "Vendor No." = FIELD("No."),
                                    "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                    "Posting Date" = FIELD("Date Filter"),
                                    "Item Category Code" = FIELD("NPR Item Category Filter"),
                                    "Salespers./Purch. Code" = FIELD("NPR Salesperson Filter")));
            Caption = 'Sales (Qty.)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014405; "NPR Salesperson Filter"; Code[20])
        {
            Caption = 'Salesperson Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser";
        }
        field(6014406; "NPR Stock"; Decimal)
        {
            CalcFormula = Sum("NPR Aux. Value Entry"."Cost Amount (Actual)"
                            WHERE(
                                "Vendor No." = FIELD("No."),
                                "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                "Posting Date" = FIELD("Date Filter"),
                                "Item Category Code" = FIELD("NPR Item Category Filter"),
                                "Salespers./Purch. Code" = FIELD("NPR Salesperson Filter")));
            Caption = 'Stock';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014407; "NPR Primary key length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014408; "NPR Purchase Value (LCY)"; Decimal)
        {
            CalcFormula = - Sum("NPR Aux. Value Entry"."Purchase Amount (Actual)"
                                WHERE(
                                    "Vendor No." = FIELD("No."),
                                    "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                    "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                    "Posting Date" = FIELD("Date Filter"),
                                    "Item Category Code" = FIELD("NPR Item Category Filter"),
                                    "Item Ledger Entry Type" = CONST(Purchase)));
            Caption = 'Purchase Value (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014409; "NPR Change-to No."; Code[20])
        {
            Caption = 'Change-to No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Standard field Document Sending Profile is used.';
            Caption = 'Document Processing';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }

        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
        }
    }
}

