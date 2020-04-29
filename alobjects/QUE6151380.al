query 6151380 "CS Stock-Takes Data"
{
    // NPR5.51/JAKUBV/20190904  CASE 365659 Transport NPR5.51 - 3 September 2019
    // NPR5.52/CLVA/20190916  CASE 368484 added filter Stock_Take_Id

    Caption = 'CS Stock-Takes Data';

    elements
    {
        dataitem(CS_Stock_Takes_Data;"CS Stock-Takes Data")
        {
            filter(Worksheet_Name;"Worksheet Name")
            {
            }
            filter(Stock_Take_Config_Code;"Stock-Take Config Code")
            {
            }
            filter(Item_No;"Item No.")
            {
                ColumnFilter = Item_No=FILTER(<>'');
            }
            filter(Transferred_To_Worksheet;"Transferred To Worksheet")
            {
            }
            filter(Stock_Take_Id;"Stock-Take Id")
            {
            }
            column(ItemNo;"Item No.")
            {
                Caption = 'ItemNo';
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

