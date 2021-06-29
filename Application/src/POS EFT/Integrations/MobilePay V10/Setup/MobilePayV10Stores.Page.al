page 6014619 "NPR MobilePayV10 Stores"
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
                }
                field("Store Name"; Rec."Store Name")
                {
                    ApplicationArea = All;
                }
                field("Store City"; Rec."Store City")
                {
                    ApplicationArea = All;
                }
                field("Store Street"; Rec."Store Street")
                {
                    ApplicationArea = All;
                }
                field("Brand Name"; Rec."Brand Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Merchant Brand Id"; Rec."Merchant Brand Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Merchant Location Id"; Rec."Merchant Location Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }
}