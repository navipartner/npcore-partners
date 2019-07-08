page 6184504 "EFT Adyen Payment Type Setup"
{
    // NPR5.49/MMV /20190401 CASE 345188 Created object
    // NPR5.49/MMV /20190410 CASE 347476 Added field 7
    // NPR5.50/MMV /20190430 CASE 352465 Added field 8

    Caption = 'EFT Adyen Payment Type Setup';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "EFT Adyen Payment Type Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("API Key";"API Key")
                {
                }
                field(Environment;Environment)
                {
                }
                field("Transaction Condition";"Transaction Condition")
                {
                }
                field("Create Recurring Contract";"Create Recurring Contract")
                {
                }
                field("Acquire Card First";"Acquire Card First")
                {
                }
                field("Log Level";"Log Level")
                {
                }
                field("Silent Discount Allowed";"Silent Discount Allowed")
                {
                }
            }
        }
    }

    actions
    {
    }
}

