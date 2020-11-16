query 6151383 "NPR CS Item Journal Items"
{
    // NPR5.55/JAKUBV/20200807  CASE 405675 Transport NPR5.55 - 31 July 2020

    Caption = 'CS Item Journal Items';

    elements
    {
        dataitem(Item_Journal_Line; "Item Journal Line")
        {
            filter(Journal_Template_Name; "Journal Template Name")
            {
            }
            filter(Journal_Batch_Name; "Journal Batch Name")
            {
            }
            column(Item_No; "Item No.")
            {
            }
            column(Variant_Code; "Variant Code")
            {
            }
            column(Sum_Qty_Calculated; "Qty. (Calculated)")
            {
                Method = Sum;
            }
        }
    }
}

