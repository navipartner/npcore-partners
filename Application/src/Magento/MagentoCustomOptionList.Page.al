page 6151426 "NPR Magento Custom Option List"
{
    Caption = 'Custom Options';
    CardPageID = "NPR Magento Custom Option Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Magento Custom Option";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Required; Rec.Required)
                {

                    ToolTip = 'Specifies the value of the Required field';
                    ApplicationArea = NPRRetail;
                }
                field("Max Length"; Rec."Max Length")
                {

                    ToolTip = 'Specifies the value of the Max Length field';
                    ApplicationArea = NPRRetail;
                }
                field(Position; Rec.Position)
                {

                    ToolTip = 'Specifies the value of the Position field';
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
                field("No. Series"; Rec."No. Series")
                {

                    ToolTip = 'Specifies the value of the No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Count"; Rec."Item Count")
                {

                    ToolTip = 'Specifies the value of the Item Count field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}