query 6151381 "CS Item Journal"
{
    // NPR5.51/JAKUBV/20190904  CASE 365659 Transport NPR5.51 - 3 September 2019

    Caption = 'CS Item Journal';

    elements
    {
        dataitem(Item_Journal_Line;"Item Journal Line")
        {
            filter(Journal_Template_Name;"Journal Template Name")
            {
            }
            filter(Journal_Batch_Name;"Journal Batch Name")
            {
            }
            column(Sum_Qty_Calculated;"Qty. (Calculated)")
            {
                Method = Sum;
            }
        }
    }
}

