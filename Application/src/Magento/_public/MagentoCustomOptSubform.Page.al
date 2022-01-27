page 6151427 "NPR Magento Custom Opt.Subform"
{
    AutoSplitKey = true;
    Caption = 'Magento Custom Option Subform';
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Custom Optn. Value";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Price; Rec.Price)
                {

                    ToolTip = 'Specifies the value of the Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Price Type"; Rec."Price Type")
                {

                    ToolTip = 'Specifies the value of the Price Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Type"; Rec."Sales Type")
                {

                    ToolTip = 'Specifies the value of the Sales Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales No."; Rec."Sales No.")
                {

                    ToolTip = 'Specifies the value of the Sales No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
                {

                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
