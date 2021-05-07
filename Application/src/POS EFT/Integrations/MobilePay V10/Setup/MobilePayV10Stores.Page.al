page 6014435 "NPR MobilePayV10 Stores"
{
    PageType = List;
    SourceTable = "NPR MobilePayV10 Store";
    SourceTableTemporary = true;
    Editable = false;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Store ID"; Rec."Store ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store ID field';
                }
                field("Store Name"; Rec."Store Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Name field';
                }
                field("Store City"; Rec."Store City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store City field';
                }
                field("Store Street"; Rec."Store Street")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Street field';
                }
                field("Brand Name"; Rec."Brand Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Brand Name field';
                }
                field("Merchant Brand Id"; Rec."Merchant Brand Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Merchant Brand Id field';
                }
                field("Merchant Location Id"; Rec."Merchant Location Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Merchant Location Id field';
                }
            }
        }
    }
}