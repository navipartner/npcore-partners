query 6151378 "NPR CS Total Items by Loc."
{
    // NPR5.50/CLVA/20190304  CASE 332844 Object created

    Caption = 'CS Total Items by Locations';

    elements
    {
        dataitem(Item; Item)
        {
            filter(Location_Filter; "Location Filter")
            {
            }
            column(Sum_Inventory; Inventory)
            {
                Method = Sum;
            }
        }
    }
}

