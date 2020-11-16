query 6059975 "NPR Get Rows - Cross Variety 2"
{
    // NPR5.31/NPKNAV/20170502  CASE 271133 Transport NPR5.31 - 2 May 2017
    // NPR5.36/NPKNAV/20171003  CASE 285733 Transport NPR5.36 - 3 October 2017

    Caption = 'Variety 1 Used Values';

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
            column(Variety_1; "NPR Variety 1")
            {
            }
            column(Variety_1_Table; "NPR Variety 1 Table")
            {
            }
            column(Variety_1_Value; "NPR Variety 1 Value")
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
            column(Variety_4; "NPR Variety 4")
            {
            }
            column(Variety_4_Table; "NPR Variety 4 Table")
            {
            }
            column(Variety_4_Value; "NPR Variety 4 Value")
            {
            }
            column("Count")
            {
                Method = Count;
            }
        }
    }
}

