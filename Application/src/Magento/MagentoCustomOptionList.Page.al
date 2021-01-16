page 6151426 "NPR Magento Custom Option List"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Action "Card"
    // MAG2.18/BHR /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Custom Options';
    CardPageID = "NPR Magento Custom Option Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Magento Custom Option";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Required; Required)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Required field';
                }
                field("Max Length"; "Max Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max Length field';
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
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
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field("Item Count"; "Item Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Count field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Card)
            {
                Caption = 'Card';
                Image = Card;
                ApplicationArea = All;
                ToolTip = 'Executes the Card action';
            }
        }
    }
}

