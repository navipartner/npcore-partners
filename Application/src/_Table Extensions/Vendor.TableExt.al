tableextension 6014424 "NPR Vendor" extends Vendor
{
    fields
    {
        field(6014400; "NPR Sales (LCY)"; Decimal)
        {
            CalcFormula = Sum("Value Entry"."Sales Amount (Actual)" WHERE("Item Ledger Entry Type" = CONST(Sale),
                                                                           "NPR Vendor No." = FIELD("No."),
                                                                           "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                           "Posting Date" = FIELD("Date Filter"),
                                                                           "NPR Item Group No." = FIELD("NPR Item Group Filter"),
                                                                           "Salespers./Purch. Code" = FIELD("NPR Salesperson Filter")));
            Caption = 'Sales (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014401; "NPR COGS (LCY)"; Decimal)
        {
            CalcFormula = - Sum("Value Entry"."Cost Amount (Actual)" WHERE("Item Ledger Entry Type" = CONST(Sale),
                                                                           "NPR Vendor No." = FIELD("No."),
                                                                           "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                           "Posting Date" = FIELD("Date Filter"),
                                                                           "NPR Item Group No." = FIELD("NPR Item Group Filter"),
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
        }
        field(6014403; "NPR Item Group Filter"; Code[10])
        {
            Caption = 'Item Group Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "NPR Item Group";
        }
        field(6014404; "NPR Sales (Qty.)"; Decimal)
        {
            CalcFormula = - Sum("Value Entry"."Invoiced Quantity" WHERE("Item Ledger Entry Type" = CONST(Sale),
                                                                        "NPR Vendor No." = FIELD("No."),
                                                                        "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                        "Posting Date" = FIELD("Date Filter"),
                                                                        "NPR Item Group No." = FIELD("NPR Item Group Filter"),
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
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE("NPR Vendor No." = FIELD("No."),
                                                                          "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                          "Posting Date" = FIELD("Date Filter"),
                                                                          "NPR Item Group No." = FIELD("NPR Item Group Filter"),
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
        }
        field(6014408; "NPR Purchase Value (LCY)"; Decimal)
        {
            CalcFormula = - Sum("Value Entry"."Purchase Amount (Actual)" WHERE("NPR Vendor No." = FIELD("No."),
                                                                               "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                               "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                               "Posting Date" = FIELD("Date Filter"),
                                                                               "NPR Item Group No." = FIELD("NPR Item Group Filter"),
                                                                               "Item Ledger Entry Type" = CONST(Purchase)));
            Caption = 'Purchase Value (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014409; "NPR Change-to No."; Code[20])
        {
            Caption = 'Change-to No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            Caption = 'Document Processing';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
    }
}

