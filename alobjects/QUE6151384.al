query 6151384 "CS RFID Document Items"
{
    // NPR5.55/JAKUBV/20200807  CASE 405675 Transport NPR5.55 - 31 July 2020


    elements
    {
        dataitem(CS_Rfid_Lines;"CS Rfid Lines")
        {
            filter(Id;Id)
            {
            }
            filter(Tag_Shipped;"Tag Shipped")
            {
            }
            column(Item_No;"Item No.")
            {
            }
            column(Variant_Code;"Variant Code")
            {
            }
            column(Count_)
            {
                Method = Count;
            }
        }
    }
}

