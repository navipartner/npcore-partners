page 6184489 "Pepper EFT Result Codes"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.28/BR/20161128  CASE 259563 Added field for "Open Terminal and Retry"
    // NPR5.30/BR  /20170113  CASE 263458 Renamed Object from Pepper to EFT, added Fields Integration Type and Transaction Subtype
    // NPR5.46/MMV /20181006 CASE 290734 EFT Framework refactored

    Caption = 'Pepper EFT Result Codes';
    PageType = List;
    SourceTable = "Pepper EFT Result Code";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Integration Type";"Integration Type")
                {
                }
                field("Transaction Type Code";"Transaction Type Code")
                {
                }
                field("Transaction Subtype Code";"Transaction Subtype Code")
                {
                }
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field(Successful;Successful)
                {
                }
                field("Long Description";"Long Description")
                {
                }
                field("Open Terminal and Retry";"Open Terminal and Retry")
                {
                }
            }
        }
    }

    actions
    {
    }
}

