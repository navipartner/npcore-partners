report 6014616 "NPR Retail Campaign Items"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Retail Campaign Items.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Retail Campaign Items';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Retail Campaign Header"; "NPR Retail Campaign Header")
        {
            column(RetailCampaignHeaderCode; "Retail Campaign Header".Code)
            {
            }
            column(RetailCampaignHeaderDescription; "Retail Campaign Header".Description)
            {
            }
            dataitem("Retail Campaign Items"; "NPR Retail Campaign Items")
            {
                DataItemLink = "Retail Campaign Code" = FIELD(Code);
                RequestFilterFields = "Vendor No.";
                column(RetailCampaignItemsLineNo; "Retail Campaign Items"."Line No.")
                {
                }
                column(RetailCampaignItemsRetailCampaignCode; "Retail Campaign Items"."Retail Campaign Code")
                {
                }
                column(RetailCampaignItemsItemNo; "Retail Campaign Items"."Item No.")
                {
                }
                column(RetailCampaignItemsDescription; "Retail Campaign Items".Description)
                {
                }
                column(RetailCampaignItemsStartingDate; "Retail Campaign Items"."Starting Date")
                {
                }
                column(RetailCampaignItemsEndingDate; "Retail Campaign Items"."Ending Date")
                {
                }
                column(RetailCampaignItemsDiscountPct; "Retail Campaign Items"."Discount %")
                {
                }
                column(RetailCampaignItemsCampaignUnitCost; "Retail Campaign Items"."Campaign Unit Cost")
                {
                }
                column(RetailCampaignItemsUnitCostPurchase; "Retail Campaign Items"."Unit Cost")
                {
                }
                column(RetailCampaignItemsUnitPrice; "Retail Campaign Items"."Unit Price")
                {
                }
                column(RetailCampaignItemsVendorItemNo; "Retail Campaign Items"."Vendor Item No.")
                {
                }
                column(RetailCampaignItemsVendorNo; "Retail Campaign Items"."Vendor No.")
                {
                }
                dataitem("Retail Comment"; "NPR Retail Comment")
                {
                    DataItemLink = "No." = FIELD("Disc. Code"), "No. 2" = FIELD("Item No.");
                    DataItemTableView = SORTING("Table ID", "No.", "No. 2", Option, "Option 2", Integer, "Integer 2", "Line No.") WHERE("Table ID" = CONST(6014414));
                    column(RetailCommentComment; "Retail Comment".Comment)
                    {
                    }
                }

                trigger OnPreDataItem()
                begin
                    "Retail Campaign Items".CreateDiscountItems("Retail Campaign Header");
                end;
            }
        }
    }

}

