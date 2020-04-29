query 6014611 "Retail Campaign Item Entries"
{
    // NPR5.38.01/MHA /20171221  CASE 299436 Object created - Retail Campaign

    Caption = 'Retail Campaign Item Entries';

    elements
    {
        dataitem(Retail_Campaign_Header;"Retail Campaign Header")
        {
            filter("Code";"Code")
            {
            }
            dataitem(Retail_Campaign_Line;"Retail Campaign Line")
            {
                DataItemLink = "Campaign Code"=Retail_Campaign_Header.Code;
                SqlJoinType = InnerJoin;
                filter(Line_No;"Line No.")
                {
                }
                dataitem(Item_Ledger_Entry;"Item Ledger Entry")
                {
                    DataItemLink = "Discount Type"=Retail_Campaign_Line.Type,"Discount Code"=Retail_Campaign_Line.Code;
                    SqlJoinType = InnerJoin;
                    column(Entry_No;"Entry No.")
                    {
                    }
                }
            }
        }
    }
}

