page 6184482 "NPR Pepper EFT Trx Subtype"
{
    // NPR5.30/BR  /20170113  CASE 263458 Object Created
    // NPR5.46/MMV /20181006 CASE 290734 EFT Framework refactored

    Caption = 'Pepper EFT Transaction Subtypes';
    PageType = List;
    SourceTable = "NPR Pepper EFT Trx Subtype";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Integration Type Code"; "Integration Type Code")
                {
                    ApplicationArea = All;
                }
                field("Transaction Type Code"; "Transaction Type Code")
                {
                    ApplicationArea = All;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
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

