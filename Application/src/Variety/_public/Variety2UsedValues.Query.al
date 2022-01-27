query 6059971 "NPR Variety 2 Used Values"
{
    // NPR5.31/NPKNAV/20170502  CASE 271133 Transport NPR5.31 - 2 May 2017

    Caption = 'Variety 2 Used Values';

    elements
    {
        dataitem(Item_Variant; "Item Variant")
        {
            filter(Item_No_Filter; "Item No.")
            {
            }
            filter(Blocked; "NPR Blocked")
            {
            }
            column(Item_No; "Item No.")
            {
            }
            column(Variety_2; "NPR Variety 2")
            {
            }
            column(Variety_2_Table; "NPR Variety 2 Table")
            {
            }
            column(Variety_2_Value; "NPR Variety 2 Value")
            {
            }
            column("Count")
            {
                Method = Count;
            }
        }
    }
}

