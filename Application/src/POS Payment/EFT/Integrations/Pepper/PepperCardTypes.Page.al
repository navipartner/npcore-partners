page 6184485 "NPR Pepper Card Types"
{
    Extensible = False;
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Types';
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/pepper_card_types/';
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

                    ToolTip = 'Specifies the code value associated with the Pepper Card Type';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the Pepper Card Type';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Type POS"; Rec."Payment Type POS")
                {

                    ToolTip = 'Specifies the payment type for POS transactions related to the Pepper Card Type';
                    ApplicationArea = NPRRetail;
                }
                field("Card Type Group Code"; Rec."Card Type Group Code")
                {

                    ToolTip = 'Specifies the code of the card type group to which the Pepper Card Type belongs';
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

                ToolTip = 'Displays the list of fees associated with the Pepper Card Type';
                ApplicationArea = NPRRetail;
            }
        }
    }
}