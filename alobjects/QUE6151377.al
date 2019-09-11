query 6151377 "CS Refill Sections"
{
    // NPR5.50/JAKUBV/20190603  CASE 247747-01 Transport NPR5.50 - 3 June 2019
    // NPR5.51/CLVA  /20190902  CASE 365659 Added captions

    Caption = 'CS Refill Sections';

    elements
    {
        dataitem(CS_Refill_Data;"CS Refill Data")
        {
            filter(Stock_Take_Id;"Stock-Take Id")
            {
            }
            column(Item_No;"Item No.")
            {
            }
            column(Item_Description;"Item Description")
            {
            }
            column(Item_Group_Code;"Item Group Code")
            {
            }
            column(Refilled;Refilled)
            {
            }
            column(Count_)
            {
                Method = Count;
            }
        }
    }
}

