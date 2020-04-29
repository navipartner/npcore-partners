query 6151374 "CS Stock-Take Summarize"
{
    // NPR5.47/NPKNAV/20181026  CASE 318296 Transport NPR5.47 - 26 October 2018
    // NPR5.48/JDH /20181109 CASE 334163 Missing Object Caption Added

    Caption = 'CS Stock-Take Summarize';

    elements
    {
        dataitem(CS_Stock_Take_Handling;"CS Stock-Take Handling")
        {
            filter(Id;Id)
            {
            }
            filter(Handled;Handled)
            {
            }
            filter(Transferred_to_Worksheet;"Transferred to Worksheet")
            {
            }
            column(Stock_Take_Config_Code;"Stock-Take Config Code")
            {
            }
            column(Worksheet_Name;"Worksheet Name")
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
            column(Count_)
            {
                Method = Count;
            }
        }
    }
}

