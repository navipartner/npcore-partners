page 6151072 "Purchase Price Factbox"
{
    // NPR5.39/JKL /20180212 CASE 299436

    Caption = 'Purchase Prices';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Purchase Price";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Minimum Quantity";"Minimum Quantity")
                {
                }
                field("Direct Unit Cost";"Direct Unit Cost")
                {
                }
                field("Starting Date";"Starting Date")
                {
                }
                field("Ending Date";"Ending Date")
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

