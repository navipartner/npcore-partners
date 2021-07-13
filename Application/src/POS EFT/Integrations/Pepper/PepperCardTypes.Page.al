page 6184485 "NPR Pepper Card Types"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Types';
    PageType = List;
    SourceTable = "NPR Pepper Card Type";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field("Payment Type POS"; Rec."Payment Type POS")
                {

                    ToolTip = 'Specifies the value of the Payment Type POS field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Type Group Code"; Rec."Card Type Group Code")
                {

                    ToolTip = 'Specifies the value of the Card Type Group Code field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Fees action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

