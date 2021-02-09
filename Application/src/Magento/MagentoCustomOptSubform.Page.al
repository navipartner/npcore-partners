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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Price; Rec.Price)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price field';
                }
                field("Price Type"; Rec."Price Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Type field';
                }
                field("Sales Type"; Rec."Sales Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Type field';
                }
                field("Sales No."; Rec."Sales No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales No. field';
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                }
            }
        }
    }
}