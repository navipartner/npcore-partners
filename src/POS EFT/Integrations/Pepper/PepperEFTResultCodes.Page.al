page 6184489 "NPR Pepper EFT Result Codes"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.28/BR/20161128  CASE 259563 Added field for "Open Terminal and Retry"
    // NPR5.30/BR  /20170113  CASE 263458 Renamed Object from Pepper to EFT, added Fields Integration Type and Transaction Subtype
    // NPR5.46/MMV /20181006 CASE 290734 EFT Framework refactored

    Caption = 'Pepper EFT Result Codes';
    PageType = List;
    SourceTable = "NPR Pepper EFT Result Code";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Integration Type"; "Integration Type")
                {
                    ApplicationArea = All;
                }
                field("Transaction Type Code"; "Transaction Type Code")
                {
                    ApplicationArea = All;
                }
                field("Transaction Subtype Code"; "Transaction Subtype Code")
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
                field(Successful; Successful)
                {
                    ApplicationArea = All;
                }
                field("Long Description"; "Long Description")
                {
                    ApplicationArea = All;
                }
                field("Open Terminal and Retry"; "Open Terminal and Retry")
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

