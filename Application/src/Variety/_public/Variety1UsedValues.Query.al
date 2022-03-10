query 6059970 "NPR Variety 1 Used Values"
{
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
            column("Count")
            {
                Method = Count;
            }
        }
    }
}

