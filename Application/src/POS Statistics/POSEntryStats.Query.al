query 6014479 "NPR POS Entry Stats"
{
    Access = Internal;
    Caption = 'POS Entry Stats';
    QueryType = Normal;
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(NPRPOSEntry; "NPR POS Entry")
        {
            column(Entry_No; "Entry No.") { }
            column(POS_Store_Code; "POS Store Code") { }
            column(POS_Unit_No; "POS Unit No.") { }
            column(Salesperson_Code; "Salesperson Code") { }
            column(Responsibility_Center; "Responsibility Center") { }
            column(Document_No; "Document No.") { }
            column(Entry_Date; "Entry Date") { }
            column(Posting_Date; "Posting Date") { }
            column(Entry_Type; "Entry Type") { }
            column(Customer_No; "Customer No.") { }
            column(Reason_Code; "Reason Code") { }
            column(Amount_Excl_Tax; "Amount Excl. Tax") { }
            column(Tax_Amount; "Tax Amount") { }
            column(Amount_Incl_Tax; "Amount Incl. Tax") { }
            column(Payment_Amount; "Payment Amount") { }
            column(Ending_Time; "Ending Time") { }
            column(SystemCreatedAt; SystemCreatedAt) { }

            dataitem(NPRPOSEntrySalesLine; "NPR POS Entry Sales Line")
            {
                DataItemLink = "POS Entry No." = NPRPOSEntry."Entry No.";
                SqlJoinType = LeftOuterJoin;
                column(Line_No; "Line No.") { }
                column(Type; Type) { }
                column(No; "No.") { }
                column(Variant_Code; "Variant Code") { }
                column(Location_Code; "Location Code") { }
                column(Quantity; Quantity) { }
                column(Unit_of_Measure_Code; "Unit of Measure Code") { }
                column(Quantity_Base; "Quantity (Base)") { }
                column(Unit_Price; "Unit Price") { }
                column(Unit_Cost_LCY; "Unit Cost (LCY)") { }
                column(VAT_Percent; "VAT %") { }
                column(Line_Discount_Percent; "Line Discount %") { }
                column(Line_Dsc_Amt_Excl_VAT_LCY; "Line Dsc. Amt. Excl. VAT (LCY)") { }
                column(Line_Dsc_Amt_Incl_VAT_LCY; "Line Dsc. Amt. Incl. VAT (LCY)") { }
                column(Amount_Excl_VAT_LCY; "Amount Excl. VAT (LCY)") { }
                column(Amount_Incl_VAT_LCY; "Amount Incl. VAT (LCY)") { }
                column(Sales_Line_Shortcut_Dimension_1_Code; "Shortcut Dimension 1 Code") { }
                column(Sales_Line_Shortcut_Dimension_2_Code; "Shortcut Dimension 2 Code") { }
                column(VAT_Calculation_Type; "VAT Calculation Type") { }
                column(Return_Reason_Code; "Return Reason Code") { }
            }
        }
    }
}
