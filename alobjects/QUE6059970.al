query 6059970 "Variety 1 Used Values"
{
    // NPR5.31/NPKNAV/20170502  CASE 271133 Transport NPR5.31 - 2 May 2017

    Caption = 'Variety 1 Used Values';

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
            column(Variety_1;"Variety 1")
            {
            }
            column(Variety_1_Table;"Variety 1 Table")
            {
            }
            column(Variety_1_Value;"Variety 1 Value")
            {
            }
            column("Count")
            {
                Method = Count;
            }
        }
    }
}

