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
                field("Store ID"; "Store ID")
                {
                    ApplicationArea = All;
                }
                field("Store Name"; "Store Name")
                {
                    ApplicationArea = All;
                }
                field("Store City"; "Store City")
                {
                    ApplicationArea = All;
                }
                field("Store Street"; "Store Street")
                {
                    ApplicationArea = All;
                }
                field("Brand Name"; "Brand Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Merchant Brand Id"; "Merchant Brand Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Merchant Location Id"; "Merchant Location Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }
}