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
                field("Transaction Type Code"; Rec."Transaction Type Code")
                {

                    ToolTip = 'Specifies the value of the Transaction Type Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Transaction Subtype Code"; Rec."Transaction Subtype Code")
                {

                    ToolTip = 'Specifies the value of the Transaction Subtype Code field';
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
                field(Successful; Rec.Successful)
                {

                    ToolTip = 'Specifies the value of the Successful field';
                    ApplicationArea = NPRRetail;
                }
                field("Long Description"; Rec."Long Description")
                {

                    ToolTip = 'Specifies the value of the Long Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Open Terminal and Retry"; Rec."Open Terminal and Retry")
                {

                    ToolTip = 'Specifies the value of the Open Terminal and Retry field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

