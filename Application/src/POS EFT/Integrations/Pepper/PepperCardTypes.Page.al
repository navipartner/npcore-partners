page 6184485 "NPR Pepper Card Types"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Types';
    PageType = List;
    SourceTable = "NPR Pepper Card Type";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field("Payment Type POS"; Rec."Payment Type POS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Type POS field';
                }
                field("Card Type Group Code"; Rec."Card Type Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Type Group Code field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Fees)
            {
                Caption = 'Fees';
                Image = InsertStartingFee;
                RunObject = Page "NPR Pepper Card Type Fees";
                RunPageLink = "Card Type Code" = FIELD(Code);
                RunPageView = SORTING("Card Type Code", "Minimum Amount")
                              ORDER(Ascending);
                ApplicationArea = All;
                ToolTip = 'Executes the Fees action';
            }
        }
    }
}

