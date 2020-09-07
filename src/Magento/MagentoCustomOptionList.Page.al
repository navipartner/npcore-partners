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

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field(Required; Required)
                {
                    ApplicationArea = All;
                }
                field("Max Length"; "Max Length")
                {
                    ApplicationArea = All;
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                }
                field(Price; Price)
                {
                    ApplicationArea = All;
                }
                field("Price Type"; "Price Type")
                {
                    ApplicationArea = All;
                }
                field("Sales Type"; "Sales Type")
                {
                    ApplicationArea = All;
                }
                field("Sales No."; "Sales No.")
                {
                    ApplicationArea = All;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                }
                field("Item Count"; "Item Count")
                {
                    ApplicationArea = All;
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
                ApplicationArea=All;
            }
        }
    }
}

