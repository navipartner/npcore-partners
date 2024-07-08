page 6184482 "NPR Pepper EFT Trx Subtype"
{
    Extensible = False;
    // NPR5.30/BR  /20170113  CASE 263458 Object Created
    // NPR5.46/MMV /20181006 CASE 290734 EFT Framework refactored

    Caption = 'Pepper EFT Transaction Subtypes';
    PageType = List;
    SourceTable = "NPR Pepper EFT Trx Subtype";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Integration Type Code"; Rec."Integration Type Code")
                {

                    ToolTip = 'Specifies the value of the Integration Type Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Transaction Type Code"; Rec."Transaction Type Code")
                {

                    ToolTip = 'Specifies the value of the Transaction Type Code field';
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
            }
        }
    }

    actions
    {
    }
}

