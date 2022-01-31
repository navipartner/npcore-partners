page 6014613 "NPR Retail Campgn.Item Subform"
{
    Extensible = False;
    // NPR5.38.01/JKL /20180206  CASE 299436 Object created - Retail Campaign
    // NPR5.41/JKL /20180419 CASE 299278  added campaign profit calc + units pr. parcel + unit purchase price
    // TM1.39/TSA /20181102 CASE 334585 A control of type 'FlowFilter' is not allowed in a parent control of type 'Repeater'

    Caption = 'Retail Campaign Items';
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
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

                    ToolTip = 'Specifies the value of the Disc. Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Disc. Code"; Rec."Disc. Code")
                {

                    ToolTip = 'Specifies the value of the Disc. Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Unit Price"; Rec."Campaign Unit Price")
                {

                    ToolTip = 'Specifies the value of the Period Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {

                    Caption = 'Unit Cost';
                    ToolTip = 'Specifies the value of the Unit Cost field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Unit Cost"; Rec."Campaign Unit Cost")
                {

                    ToolTip = 'Specifies the value of the Period Cost field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Purchase Price"; Rec."Unit Purchase Price")
                {

                    ToolTip = 'Specifies the value of the Unit Purchase Price field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {

                    ToolTip = 'Specifies the value of the Closing Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount %"; Rec."Discount %")
                {

                    ToolTip = 'Specifies the value of the Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies the value of the Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price Incl. VAT"; Rec."Unit Price Incl. VAT")
                {

                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Mix Discount Type"; Rec."Mix Discount Type")
                {

                    ToolTip = 'Specifies the value of the Discount Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Mix Type"; Rec."Mix Type")
                {

                    ToolTip = 'Specifies the value of the Mix Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Discount %"; Rec."Item Discount %")
                {

                    ToolTip = 'Specifies the value of the Item Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Discount Qty."; Rec."Item Discount Qty.")
                {

                    ToolTip = 'Specifies the value of the Item Discount Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Distribution Item"; Rec."Distribution Item")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Distributionitem field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor No."; Rec."Vendor No.")
                {

                    ToolTip = 'Specifies the value of the Vendor No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {

                    ToolTip = 'Specifies the value of the Vendor Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Units per Parcel"; Rec."Units per Parcel")
                {

                    ToolTip = 'Specifies the value of the Units per Parcel field';
                    ApplicationArea = NPRRetail;
                }
                field(Inventory; Rec.Inventory)
                {

                    ToolTip = 'Specifies the value of the Inventory Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity On Purchase Order"; Rec."Quantity On Purchase Order")
                {

                    ToolTip = 'Specifies the value of the Quantity in Purchase Order field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Page no. in advert"; Rec."Page no. in advert")
                {

                    ToolTip = 'Specifies the value of the Page no. in advert field';
                    ApplicationArea = NPRRetail;
                }
                field("Priority 2"; Rec."Priority 2")
                {

                    ToolTip = 'Specifies the value of the Priority 2 field';
                    ApplicationArea = NPRRetail;
                }
                field(Photo; Rec.Photo)
                {

                    ToolTip = 'Specifies the value of the Photo field';
                    ApplicationArea = NPRRetail;
                }
                field("Cross-Reference No."; Rec."Cross-Reference No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Cross-Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Disc. Grouping Type"; Rec."Disc. Grouping Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Disc. Grouping Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Priority field';
                    ApplicationArea = NPRRetail;
                }
                field(Profit; Rec.Profit)
                {

                    Visible = true;
                    ToolTip = 'Specifies the value of the Revenue % field';
                    ApplicationArea = NPRRetail;
                }
                field(Comment; Rec.Comment)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Comment field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Group"; Rec."Item Group")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Group field';
                    ApplicationArea = NPRRetail;
                }
                field(Turnover; Rec.Turnover)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Turnover field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity Sold"; Rec."Quantity Sold")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Sold Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Internet Special Id"; Rec."Internet Special Id")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Internet Special ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Profit"; Rec."Campaign Profit")
                {

                    ToolTip = 'Specifies the value of the Campaign Profit field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Date Modified field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."Starting Time")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."Ending Time")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Closing Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Comment 2"; Rec."Comment 2")
                {

                    ToolTip = 'Specifies the value of the Comments field';
                    ApplicationArea = NPRRetail;
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

