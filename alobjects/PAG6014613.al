page 6014613 "Retail Campaign Item Subform"
{
    // NPR5.38.01/JKL /20180206  CASE 299436 Object created - Retail Campaign
    // NPR5.41/JKL /20180419 CASE 299278  added campaign profit calc + units pr. parcel + unit purchase price
    // TM1.39/TSA /20181102 CASE 334585 A control of type 'FlowFilter' is not allowed in a parent control of type 'Repeater'

    Caption = 'Retail Campaign Items';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Retail Campaign Items";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Disc. Type";"Disc. Type")
                {
                }
                field("Disc. Code";"Disc. Code")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field("Campaign Unit Price";"Campaign Unit Price")
                {
                }
                field("Unit Cost";"Unit Cost")
                {
                    Caption = 'Unit Cost';
                }
                field("Campaign Unit Cost";"Campaign Unit Cost")
                {
                }
                field("Unit Purchase Price";"Unit Purchase Price")
                {
                }
                field(Status;Status)
                {
                }
                field("Starting Date";"Starting Date")
                {
                }
                field("Ending Date";"Ending Date")
                {
                }
                field("Discount %";"Discount %")
                {
                }
                field("Discount Amount";"Discount Amount")
                {
                }
                field("Unit Price Incl. VAT";"Unit Price Incl. VAT")
                {
                }
                field("Mix Discount Type";"Mix Discount Type")
                {
                }
                field("Mix Type";"Mix Type")
                {
                }
                field("Item Discount %";"Item Discount %")
                {
                }
                field("Item Discount Qty.";"Item Discount Qty.")
                {
                }
                field("Distribution Item";"Distribution Item")
                {
                    Visible = false;
                }
                field("Vendor No.";"Vendor No.")
                {
                }
                field("Vendor Item No.";"Vendor Item No.")
                {
                }
                field("Units per Parcel";"Units per Parcel")
                {
                }
                field(Inventory;Inventory)
                {
                }
                field("Quantity On Purchase Order";"Quantity On Purchase Order")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field("Page no. in advert";"Page no. in advert")
                {
                }
                field("Priority 2";"Priority 2")
                {
                }
                field(Photo;Photo)
                {
                }
                field("Cross-Reference No.";"Cross-Reference No.")
                {
                    Visible = false;
                }
                field(Quantity;Quantity)
                {
                    Visible = false;
                }
                field("Description 2";"Description 2")
                {
                    Visible = false;
                }
                field("Disc. Grouping Type";"Disc. Grouping Type")
                {
                    Visible = false;
                }
                field(Priority;Priority)
                {
                    Visible = false;
                }
                field(Profit;Profit)
                {
                    Visible = true;
                }
                field(Comment;Comment)
                {
                    Visible = false;
                }
                field("Item Group";"Item Group")
                {
                    Visible = false;
                }
                field(Turnover;Turnover)
                {
                    Visible = false;
                }
                field("Quantity Sold";"Quantity Sold")
                {
                    Visible = false;
                }
                field("Internet Special Id";"Internet Special Id")
                {
                    Visible = false;
                }
                field("Campaign Profit";"Campaign Profit")
                {
                }
                field("Last Date Modified";"Last Date Modified")
                {
                    Visible = false;
                }
                field("Starting Time";"Starting Time")
                {
                    Visible = false;
                }
                field("Ending Time";"Ending Time")
                {
                    Visible = false;
                }
                field("Comment 2";"Comment 2")
                {
                }
            }
        }
    }

    actions
    {
    }

    procedure ShowCampaignItems(var RetailCampaignHeader: Record "Retail Campaign Header")
    begin
        CreateDiscountItems(RetailCampaignHeader);
        CurrPage.Update(false);
    end;
}

