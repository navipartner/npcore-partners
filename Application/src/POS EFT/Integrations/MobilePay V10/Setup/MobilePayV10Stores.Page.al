page 6014435 "NPR MobilePayV10 Stores"
{
    PageType = List;
    SourceTable = "NPR MobilePayV10 Store";
    SourceTableTemporary = true;
    Editable = false;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Caption = 'MobilePayV10 Stores';


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Store ID"; Rec."Store ID")
                {

                    ToolTip = 'Specifies the value of the Store ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Name"; Rec."Store Name")
                {

                    ToolTip = 'Specifies the value of the Store Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Store City"; Rec."Store City")
                {

                    ToolTip = 'Specifies the value of the Store City field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Street"; Rec."Store Street")
                {

                    ToolTip = 'Specifies the value of the Store Street field';
                    ApplicationArea = NPRRetail;
                }
                field("Brand Name"; Rec."Brand Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Brand Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Merchant Brand Id"; Rec."Merchant Brand Id")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Merchant Brand Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Merchant Location Id"; Rec."Merchant Location Id")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Merchant Location Id field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}