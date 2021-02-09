page 6151426 "NPR Magento Custom Option List"
{
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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Required; Rec.Required)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Required field';
                }
                field("Max Length"; Rec."Max Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max Length field';
                }
                field(Position; Rec.Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
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
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field("Item Count"; Rec."Item Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Count field';
                }
            }
        }
    }
}