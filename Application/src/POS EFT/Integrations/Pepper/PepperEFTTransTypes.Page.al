page 6184488 "NPR Pepper EFT Trans. Types"
{
    Extensible = False;
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.28/BR/20161124  CASE 255137 Added field "Suppress Receipt Print"
    // NPR5.30/BR  /20170113  CASE 263458 Renamed Object from Pepper to EFT, added Field Integration Type
    // NPR5.46/MMV /20181006 CASE 290734 EFT Framework refactored

    Caption = 'Pepper EFT Transaction Types';
    PageType = List;
    SourceTable = "NPR Pepper EFT Trx Type";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Integration Type"; Rec."Integration Type")
                {

                    ToolTip = 'Specifies the value of the Integration Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Type"; Rec."Processing Type")
                {

                    ToolTip = 'Specifies the value of the Processing Type field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Timeout (Seconds)"; Rec."POS Timeout (Seconds)")
                {

                    ToolTip = 'Specifies the value of the POS Timeout (Seconds) field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Test Modes"; Rec."Allow Test Modes")
                {

                    ToolTip = 'Specifies the value of the Allow Test Modes field';
                    ApplicationArea = NPRRetail;
                }
                field("Suppress Receipt Print"; Rec."Suppress Receipt Print")
                {

                    ToolTip = 'Specifies the value of the Suppress Receipt Print field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Result Codes action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

