page 6151427 "NPR Magento Custom Opt.Subform"
{
    AutoSplitKey = true;
    Caption = 'Magento Custom Option Subform';
    PageType = ListPart;
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
                    ApplicationArea = NPRMagento;
                }
                field(Price; Rec.Price)
                {

                    ToolTip = 'Specifies the value of the Price field';
                    ApplicationArea = NPRMagento;
                }
                field("Price Type"; Rec."Price Type")
                {

                    ToolTip = 'Specifies the value of the Price Type field';
                    ApplicationArea = NPRMagento;
                }
                field("Sales Type"; Rec."Sales Type")
                {

                    ToolTip = 'Specifies the value of the Sales Type field';
                    ApplicationArea = NPRMagento;
                }
                field("Sales No."; Rec."Sales No.")
                {

                    ToolTip = 'Specifies the value of the Sales No. field';
                    ApplicationArea = NPRMagento;
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
                {

                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }
}
