page 6151427 "NPR Magento Custom Opt.Subform"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object
    // MAG2.21/BHR/20190508 CASE 338087 Field 100 Price Excl. VAT

    AutoSplitKey = true;
    Caption = 'Magento Custom Option Subform';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Custom Optn. Value";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Price; Price)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price field';
                }
                field("Price Type"; "Price Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Type field';
                }
                field("Sales Type"; "Sales Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Type field';
                }
                field("Sales No."; "Sales No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales No. field';
                }
                field("Price Includes VAT"; "Price Includes VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                }
            }
        }
    }

    actions
    {
    }

    procedure SetVisible(Visible: Boolean)
    begin
        //CurrPage.VISIBLE(Visible);
    end;
}

