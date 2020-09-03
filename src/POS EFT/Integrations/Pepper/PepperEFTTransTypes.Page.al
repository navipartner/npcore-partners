page 6184488 "NPR Pepper EFT Trans. Types"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.28/BR/20161124  CASE 255137 Added field "Suppress Receipt Print"
    // NPR5.30/BR  /20170113  CASE 263458 Renamed Object from Pepper to EFT, added Field Integration Type
    // NPR5.46/MMV /20181006 CASE 290734 EFT Framework refactored

    Caption = 'Pepper EFT Transaction Types';
    PageType = List;
    SourceTable = "NPR Pepper EFT Trx Type";
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
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Processing Type"; "Processing Type")
                {
                    ApplicationArea = All;
                }
                field("POS Timeout (Seconds)"; "POS Timeout (Seconds)")
                {
                    ApplicationArea = All;
                }
                field("Allow Test Modes"; "Allow Test Modes")
                {
                    ApplicationArea = All;
                }
                field("Suppress Receipt Print"; "Suppress Receipt Print")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Result Codes")
            {
                Caption = 'Result Codes';
                Image = ServiceCode;
                RunObject = Page "NPR Pepper EFT Result Codes";
                RunPageLink = "Transaction Type Code" = FIELD(Code);
                RunPageView = SORTING("Transaction Type Code")
                              ORDER(Ascending);
            }
        }
    }
}

