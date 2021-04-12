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
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Integration Type"; Rec."Integration Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Integration Type field';
                }
                field("Transaction Type Code"; Rec."Transaction Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Type Code field';
                }
                field("Transaction Subtype Code"; Rec."Transaction Subtype Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Subtype Code field';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Successful; Rec.Successful)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Successful field';
                }
                field("Long Description"; Rec."Long Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Long Description field';
                }
                field("Open Terminal and Retry"; Rec."Open Terminal and Retry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open Terminal and Retry field';
                }
            }
        }
    }

    actions
    {
    }
}

