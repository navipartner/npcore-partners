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
                field("Minimum Quantity"; "Minimum Quantity")
                {
                    ApplicationArea = All;
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

