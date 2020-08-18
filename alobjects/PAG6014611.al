page 6014611 "Retail Campaign"
{
    // NPR5.38.01/MHA /20171220  CASE 299436 Object created - Retail Campaign
    // NPR5.38.01/JKL /20180105  CASE 299436 Added action Create Planning Items - Retail Campaign Ùfield Distribution Group + requested delivery date
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // MAG2.26/MHA /20200507  CASE 401235 Added field 6151414 "Magento Category Id"

    Caption = 'Retail Campaign';
    PageType = Card;
    SourceTable = "Retail Campaign Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Code";Code)
                    {
                    }
                    field(Description;Description)
                    {
                    }
                    field("Magento Category Id";"Magento Category Id")
                    {
                        Visible = MagentoEnabled;
                    }
                }
                group(Control6014410)
                {
                    ShowCaption = false;
                    field("Sales Amount";RetailCampaignCalcMgt.CalcSalesAmount(Code,0))
                    {
                        Caption = 'Sales Amount';

                        trigger OnDrillDown()
                        begin
                            RetailCampaignCalcMgt.DrilldownItemEntries(Code,0);
                        end;
                    }
                    field("Cost Amount";RetailCampaignCalcMgt.CalcCostAmount(Code,0))
                    {
                        Caption = 'Cost Amount';

                        trigger OnDrillDown()
                        begin
                            RetailCampaignCalcMgt.DrilldownItemEntries(Code,0);
                        end;
                    }
                    field(Profit;RetailCampaignCalcMgt.CalcProfit(Code,0))
                    {
                        Caption = 'Profit';

                        trigger OnDrillDown()
                        begin
                            RetailCampaignCalcMgt.DrilldownItemEntries(Code,0);
                        end;
                    }
                    field("Profit %";RetailCampaignCalcMgt.CalcProfitPct(Code,0))
                    {
                        Caption = 'Profit %';

                        trigger OnDrillDown()
                        begin
                            RetailCampaignCalcMgt.DrilldownItemEntries(Code,0);
                        end;
                    }
                }
            }
            part(Control6014404;"Retail Campaign Subform")
            {
                SubPageLink = "Campaign Code"=FIELD(Code);
                UpdatePropagation = Both;
            }
            part(RetailItems;"Retail Campaign Item Subform")
            {
                SubPageLink = "Retail Campaign Code"=FIELD(Code);
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Planning Items")
            {
                Caption = 'Planning Items';
                Image = ItemLines;
                Promoted = true;

                trigger OnAction()
                var
                    ItemHierarchyMgmt: Codeunit "Item Hierarchy Mgmt.";
                    ItemHierarchy: Record "Item Hierarchy";
                begin
                    //-NPR5.48 [299436]
                    ItemHierarchyMgmt.CreateItemHierachyFromRetailCampaign(Rec);
                    if ItemHierarchy.Get(Rec.Code) then
                      PAGE.Run(6151051,ItemHierarchy);
                    //+NPR5.48 [299436]
                end;
            }
            action("View Planning Items")
            {
                Caption = 'View Planning Items';
                Image = ItemLines;
                RunObject = Page "Item Hierarchy Card";
                RunPageLink = "Hierarchy Code"=FIELD(Code);
            }
            action("View Demand Lines")
            {
                Caption = 'View Demand Lines';
                Image = ItemAvailability;
                Promoted = false;
                RunObject = Page "Retail Repl. Demand Lines";
                RunPageLink = "Item Hierachy"=FIELD(Code),
                              "Distribution Group"=FIELD("Distribution Group");
            }
            action("View Distribution Lines")
            {
                Caption = 'View Distribution Lines';
                Image = ItemAvailbyLoc;
                Promoted = false;
                RunObject = Page "Distribution Lines";
                RunPageLink = "Item Hiearachy"=FIELD(Code);
            }
            action("Distribution Setup")
            {
                Caption = 'Distribution Setup';
                Image = SetupList;
                Promoted = true;
                RunObject = Page "Distribution Setup";
                RunPageLink = "Item Hiearachy"=FIELD(Code);
            }
        }
        area(reporting)
        {
            action("Campaign Items")
            {
                Caption = 'Campaign Items';
                Image = Campaign;
                RunObject = Report "Retail Campaign Items";
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPage.RetailItems.PAGE.ShowCampaignItems(Rec);
    end;

    trigger OnOpenPage()
    var
        MagentoSetup: Record "Magento Setup";
    begin
        //-MAG2.26 [401235]
        MagentoEnabled := MagentoSetup.Get and MagentoSetup."Magento Enabled";
        //+MAG2.26 [401235]
    end;

    var
        RetailCampaignCalcMgt: Codeunit "Retail Campaign Calc. Mgt.";
        MagentoEnabled: Boolean;
}

