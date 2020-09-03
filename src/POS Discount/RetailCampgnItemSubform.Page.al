page 6014613 "NPR Retail Campgn.Item Subform"
{
    // NPR5.38.01/JKL /20180206  CASE 299436 Object created - Retail Campaign
    // NPR5.41/JKL /20180419 CASE 299278  added campaign profit calc + units pr. parcel + unit purchase price
    // TM1.39/TSA /20181102 CASE 334585 A control of type 'FlowFilter' is not allowed in a parent control of type 'Repeater'

    Caption = 'Retail Campaign Items';
    Editable = false;
    PageType = ListPart;
    SourceTable = "NPR Retail Campaign Items";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Disc. Type"; "Disc. Type")
                {
                    ApplicationArea = All;
                }
                field("Disc. Code"; "Disc. Code")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Campaign Unit Price"; "Campaign Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                    Caption = 'Unit Cost';
                }
                field("Campaign Unit Cost"; "Campaign Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Unit Purchase Price"; "Unit Purchase Price")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                }
                field("Discount %"; "Discount %")
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Unit Price Incl. VAT"; "Unit Price Incl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Mix Discount Type"; "Mix Discount Type")
                {
                    ApplicationArea = All;
                }
                field("Mix Type"; "Mix Type")
                {
                    ApplicationArea = All;
                }
                field("Item Discount %"; "Item Discount %")
                {
                    ApplicationArea = All;
                }
                field("Item Discount Qty."; "Item Discount Qty.")
                {
                    ApplicationArea = All;
                }
                field("Distribution Item"; "Distribution Item")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = All;
                }
                field("Units per Parcel"; "Units per Parcel")
                {
                    ApplicationArea = All;
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                }
                field("Quantity On Purchase Order"; "Quantity On Purchase Order")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Page no. in advert"; "Page no. in advert")
                {
                    ApplicationArea = All;
                }
                field("Priority 2"; "Priority 2")
                {
                    ApplicationArea = All;
                }
                field(Photo; Photo)
                {
                    ApplicationArea = All;
                }
                field("Cross-Reference No."; "Cross-Reference No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Disc. Grouping Type"; "Disc. Grouping Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Priority; Priority)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Profit; Profit)
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item Group"; "Item Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Turnover; Turnover)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Quantity Sold"; "Quantity Sold")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Internet Special Id"; "Internet Special Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Campaign Profit"; "Campaign Profit")
                {
                    ApplicationArea = All;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Comment 2"; "Comment 2")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    procedure ShowCampaignItems(var RetailCampaignHeader: Record "NPR Retail Campaign Header")
    begin
        CreateDiscountItems(RetailCampaignHeader);
        CurrPage.Update(false);
    end;
}

