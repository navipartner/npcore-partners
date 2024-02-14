query 6059974 "NPR Get Rows - Cross Variety 1"
{
    Access = Internal;
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
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
            filter(Blocked; "NPR Blocked")
            {
            }
#ELSE
            filter(Blocked; Blocked)
            {
            }
#ENDIF
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

