query 6059973 "NPR Variety 4 Used Values"
{
    Caption = 'Variety 4 Used Values';

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

