query 6151382 "CS Rfid Lines"
{
    // NPR5.55/JAKUBV/20200807  CASE 379709-01 Transport NPR5.55 - 31 July 2020


    elements
    {
        dataitem(CS_Rfid_Lines;"CS Rfid Lines")
        {
            filter(Id;Id)
            {
            }
            filter(Item_No_Filter;"Item No.")
            {
            }
            filter(Match_Filter;Match)
            {
            }
            column(Item_No;"Item No.")
            {
            }
            column(Variant_Code;"Variant Code")
            {
            }
            column(Item_Description;"Item Description")
            {
            }
            column(Variant_Description;"Variant Description")
            {
            }
            column(Match;Match)
            {
            }
            column(Count_)
            {
                Method = Count;
            }
        }
    }
}

