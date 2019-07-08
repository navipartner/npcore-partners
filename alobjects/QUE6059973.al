query 6059973 "Variety 4 Used Values"
{
    // NPR5.31/NPKNAV/20170502  CASE 271133 Transport NPR5.31 - 2 May 2017

    Caption = 'Variety 4 Used Values';

    elements
    {
        dataitem(Item_Variant;"Item Variant")
        {
            filter(Item_No_Filter;"Item No.")
            {
            }
            filter(Blocked;Blocked)
            {
            }
            column(Item_No;"Item No.")
            {
            }
            column(Variety_4;"Variety 4")
            {
            }
            column(Variety_4_Table;"Variety 4 Table")
            {
            }
            column(Variety_4_Value;"Variety 4 Value")
            {
            }
            column("Count")
            {
                Method = Count;
            }
        }
    }
}

