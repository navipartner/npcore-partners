page 6184482 "NPR Pepper EFT Trx Subtype"
{
    // NPR5.30/BR  /20170113  CASE 263458 Object Created
    // NPR5.46/MMV /20181006 CASE 290734 EFT Framework refactored

    Caption = 'Pepper EFT Transaction Subtypes';
    PageType = List;
    SourceTable = "NPR Pepper EFT Trx Subtype";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Integration Type Code"; Rec."Integration Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Integration Type Code field';
                }
                field("Transaction Type Code"; Rec."Transaction Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Type Code field';
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
            }
        }
    }

    actions
    {
    }
}

