query 6059972 "NPR Variety 3 Used Values"
{
    Caption = 'Variety 3 Used Values';

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

