query 6059972 "NPR Variety 3 Used Values"
{
    Access = Internal;
    // NPR5.31/NPKNAV/20170502  CASE 271133 Transport NPR5.31 - 2 May 2017

    Caption = 'Variety 3 Used Values';

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
            column(Variety_3; "NPR Variety 3")
            {
            }
            column(Variety_3_Table; "NPR Variety 3 Table")
            {
            }
            column(Variety_3_Value; "NPR Variety 3 Value")
            {
            }
            column("Count")
            {
                Method = Count;
            }
        }
    }
}

