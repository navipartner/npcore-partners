page 6150728 "NPR POS Pricing Profile Card"
{
    Caption = 'POS Pricing Profile';
    PageType = Card;
    SourceTable = "NPR POS Pricing Profile";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
