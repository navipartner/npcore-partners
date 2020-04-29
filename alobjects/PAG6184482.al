page 6184482 "Pepper EFT Transaction Subtype"
{
    // NPR5.30/BR  /20170113  CASE 263458 Object Created
    // NPR5.46/MMV /20181006 CASE 290734 EFT Framework refactored

    Caption = 'Pepper EFT Transaction Subtypes';
    PageType = List;
    SourceTable = "Pepper EFT Transaction Subtype";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Integration Type Code";"Integration Type Code")
                {
                }
                field("Transaction Type Code";"Transaction Type Code")
                {
                }
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
    }
}

