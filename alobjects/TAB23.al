tableextension 70000024 tableextension70000024 extends Vendor 
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                        Added Fields 6014400..6060050
    // 
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Added Field 6014415 "Document Processing" for defining Print action on Purch. Doc. Posting.
    // NPR70.00.03.00/MH/20150216  CASE 204110 Removed NaviShop References (WS).
    // NPR4.14/RMT/20150824 CASE 221274 - Added TDC lookup option
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    fields
    {
        field(6014400;"Sales (LCY)";Decimal)
        {
            CalcFormula = Sum("Value Entry"."Sales Amount (Actual)" WHERE ("Item Ledger Entry Type"=CONST(Sale),
                                                                           "Vendor No."=FIELD("No."),
                                                                           "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                           "Posting Date"=FIELD("Date Filter"),
                                                                           "Item Group No."=FIELD("Item Group Filter"),
                                                                           "Salespers./Purch. Code"=FIELD("Salesperson Filter")));
            Caption = 'Sales (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014401;"COGS (LCY)";Decimal)
        {
            CalcFormula = -Sum("Value Entry"."Cost Amount (Actual)" WHERE ("Item Ledger Entry Type"=CONST(Sale),
                                                                           "Vendor No."=FIELD("No."),
                                                                           "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                           "Posting Date"=FIELD("Date Filter"),
                                                                           "Item Group No."=FIELD("Item Group Filter"),
                                                                           "Salespers./Purch. Code"=FIELD("Salesperson Filter")));
            Caption = 'COGS (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014402;Auto;Boolean)
        {
            Caption = 'Auto';
            Description = 'NPR7.100.000';
        }
        field(6014403;"Item Group Filter";Code[10])
        {
            Caption = 'Item Group Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "Item Group";
        }
        field(6014404;"Sales (Qty.)";Decimal)
        {
            CalcFormula = -Sum("Value Entry"."Invoiced Quantity" WHERE ("Vendor No."=FIELD("No."),
                                                                        "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                        "Posting Date"=FIELD("Date Filter"),
                                                                        "Item Group No."=FIELD("Item Group Filter"),
                                                                        "Salespers./Purch. Code"=FIELD("Salesperson Filter")));
            Caption = 'Sales (Qty.)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014405;"Salesperson Filter";Code[10])
        {
            Caption = 'Salesperson Filter';
            Description = 'NPR7.100.000';
            FieldClass = FlowFilter;
            TableRelation = "Salesperson/Purchaser";
        }
        field(6014406;Stock;Decimal)
        {
            CalcFormula = Sum("Value Entry"."Cost Amount (Actual)" WHERE ("Vendor No."=FIELD("No."),
                                                                          "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                          "Posting Date"=FIELD("Date Filter"),
                                                                          "Item Group No."=FIELD("Item Group Filter"),
                                                                          "Salespers./Purch. Code"=FIELD("Salesperson Filter")));
            Caption = 'Stock';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014407;"Primary key length";Integer)
        {
            Caption = 'Primary Key Length';
            Description = 'NPR7.100.000';
        }
        field(6014408;"Purchase Value (LCY)";Decimal)
        {
            CalcFormula = -Sum("Value Entry"."Purchase Amount (Actual)" WHERE ("Vendor No."=FIELD("No."),
                                                                               "Global Dimension 1 Code"=FIELD("Global Dimension 1 Filter"),
                                                                               "Global Dimension 2 Code"=FIELD("Global Dimension 2 Filter"),
                                                                               "Posting Date"=FIELD("Date Filter"),
                                                                               "Item Group No."=FIELD("Item Group Filter"),
                                                                               "Item Ledger Entry Type"=CONST(Purchase)));
            Caption = 'Purchase Value (LCY)';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014409;"Change-to No.";Code[20])
        {
            Caption = 'Change-to No.';
            Description = 'NPR7.100.000';
        }
        field(6014415;"Document Processing";Option)
        {
            Caption = 'Document Processing';
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
    }
}

