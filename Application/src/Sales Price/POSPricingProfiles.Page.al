page 6150648 "NPR POS Pricing Profiles"
{
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Pricing Profile";
    Caption = 'POS Pricing Profiles';
    Editable = false;
    CardPageID = "NPR POS Pricing Profile Card";
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Disc. Group"; Rec."Customer Disc. Group")
                {

                    ToolTip = 'Specifies the value of the Customer Discount Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {

                    ToolTip = 'Specifies the value of the Customer Price Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Price Codeunit ID"; Rec."Item Price Codeunit ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Price Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Price Codeunit Name"; Rec."Item Price Codeunit Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Price Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Price Function"; Rec."Item Price Function")
                {

                    ToolTip = 'Specifies the value of the Item Price Function field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}