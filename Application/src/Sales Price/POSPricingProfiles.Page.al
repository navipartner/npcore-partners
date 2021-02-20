page 6150648 "NPR POS Pricing Profiles"
{
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Pricing Profile";
    Caption = 'POS Pricing Profiles';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Customer Disc. Group"; Rec."Customer Disc. Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Discount Group field';
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Price Group field';
                }
                field("Item Price Codeunit ID"; Rec."Item Price Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Price Codeunit ID field';
                }
                field("Item Price Codeunit Name"; Rec."Item Price Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Price Codeunit Name field';
                }
                field("Item Price Function"; Rec."Item Price Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Price Function field';
                }
            }
        }
    }
}