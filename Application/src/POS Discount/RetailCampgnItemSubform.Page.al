page 6014613 "NPR Retail Campgn.Item Subform"
{
    // NPR5.38.01/JKL /20180206  CASE 299436 Object created - Retail Campaign
    // NPR5.41/JKL /20180419 CASE 299278  added campaign profit calc + units pr. parcel + unit purchase price
    // TM1.39/TSA /20181102 CASE 334585 A control of type 'FlowFilter' is not allowed in a parent control of type 'Repeater'

    Caption = 'Retail Campaign Items';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Retail Campaign Items";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Disc. Type"; Rec."Disc. Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disc. Type field';
                }
                field("Disc. Code"; Rec."Disc. Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disc. Code field';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Campaign Unit Price"; Rec."Campaign Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Price field';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    Caption = 'Unit Cost';
                    ToolTip = 'Specifies the value of the Unit Cost field';
                }
                field("Campaign Unit Cost"; Rec."Campaign Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Cost field';
                }
                field("Unit Purchase Price"; Rec."Unit Purchase Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Purchase Price field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closing Date field';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount % field';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Amount field';
                }
                field("Unit Price Incl. VAT"; Rec."Unit Price Incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                }
                field("Mix Discount Type"; Rec."Mix Discount Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Type field';
                }
                field("Mix Type"; Rec."Mix Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mix Type field';
                }
                field("Item Discount %"; Rec."Item Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Discount % field';
                }
                field("Item Discount Qty."; Rec."Item Discount Qty.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Discount Quantity field';
                }
                field("Distribution Item"; Rec."Distribution Item")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Distributionitem field';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Item No. field';
                }
                field("Units per Parcel"; Rec."Units per Parcel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Units per Parcel field';
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory Quantity field';
                }
                field("Quantity On Purchase Order"; Rec."Quantity On Purchase Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity in Purchase Order field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Page no. in advert"; Rec."Page no. in advert")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Page no. in advert field';
                }
                field("Priority 2"; Rec."Priority 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Priority 2 field';
                }
                field(Photo; Rec.Photo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Photo field';
                }
                field("Cross-Reference No."; Rec."Cross-Reference No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Cross-Reference No. field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field("Disc. Grouping Type"; Rec."Disc. Grouping Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Disc. Grouping Type field';
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Priority field';
                }
                field(Profit; Rec.Profit)
                {
                    ApplicationArea = All;
                    Visible = true;
                    ToolTip = 'Specifies the value of the Revenue % field';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Comment field';
                }
                field("Item Group"; Rec."Item Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Group field';
                }
                field(Turnover; Rec.Turnover)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Turnover field';
                }
                field("Quantity Sold"; Rec."Quantity Sold")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sold Quantity field';
                }
                field("Internet Special Id"; Rec."Internet Special Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Internet Special ID field';
                }
                field("Campaign Profit"; Rec."Campaign Profit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Campaign Profit field';
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Date Modified field';
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Closing Time field';
                }
                field("Comment 2"; Rec."Comment 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Comments field';
                }
            }
        }
    }

    actions
    {
    }

    procedure ShowCampaignItems(var RetailCampaignHeader: Record "NPR Retail Campaign Header")
    begin
        Rec.CreateDiscountItems(RetailCampaignHeader);
        CurrPage.Update(false);
    end;
}

