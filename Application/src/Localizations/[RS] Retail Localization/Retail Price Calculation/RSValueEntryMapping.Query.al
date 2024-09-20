query 6014481 "NPR RS Value Entry Mapping"
{
    Access = Internal;
    QueryType = Normal;
    Caption = 'RS Value Entry Mapping';

    elements
    {
        dataitem(RS_Ret_Value_Entry_Mapp; "NPR RS Ret. Value Entry Mapp.")
        {
            filter(Filter_COGS_Correction; "COGS Correction") { }
            filter(Filter_Standard_Correction; "Standard Correction") { }
            filter(Filter_Retail_Calculation; "Retail Calculation") { }

            column(Entry_No_; "Entry No.") { }

            dataitem(Value_Entry; "Value Entry")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Entry No." = RS_Ret_Value_Entry_Mapp."Entry No.";
                DataItemTableFilter = "Item Ledger Entry Type" = Filter(Sale);

                filter(Filter_Item_No; "Item No.") { }
                filter(Filter_Posting_Date; "Posting Date") { }
                filter(Filter_Global_Dimension_1_Code; "Global Dimension 1 Code") { }
                filter(Filter_Global_Dimension_2_Code; "Global Dimension 2 Code") { }
                filter(Filter_Location_Code; "Location Code") { }

                column(Sales_Amount_Actual; "Sales Amount (Actual)") { }
                column(Invoiced_Quantity; "Invoiced Quantity") { }
                column(Cost_Amount_Actual; "Cost Amount (Actual)") { }
            }
        }
    }
}