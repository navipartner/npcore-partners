page 6014611 "NPR Retail Campaign"
{
    // NPR5.38.01/MHA /20171220  CASE 299436 Object created - Retail Campaign
    // NPR5.38.01/JKL /20180105  CASE 299436 Added action Create Planning Items - Retail Campaign Ùfield Distribution Group + requested delivery date
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // MAG2.26/MHA /20200507  CASE 401235 Added field 6151414 "Magento Category Id"

    Caption = 'Retail Campaign';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Retail Campaign Header";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Code"; Rec.Code)
                    {

                        ToolTip = 'Specifies the value of the Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Description; Rec.Description)
                    {

                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Magento Category Id"; Rec."Magento Category Id")
                    {

                        Visible = MagentoEnabled;
                        ToolTip = 'Specifies the value of the Magento Category Id field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014410)
                {
                    ShowCaption = false;
                    field("Sales Amount"; RetailCampaignCalcMgt.CalcSalesAmount(Rec.Code, 0))
                    {

                        Caption = 'Sales Amount';
                        ToolTip = 'Specifies the value of the Sales Amount field';
                        ApplicationArea = NPRRetail;

                        trigger OnDrillDown()
                        begin
                            RetailCampaignCalcMgt.DrilldownItemEntries(Rec.Code, 0);
                        end;
                    }
                    field("Cost Amount"; RetailCampaignCalcMgt.CalcCostAmount(Rec.Code, 0))
                    {

                        Caption = 'Cost Amount';
                        ToolTip = 'Specifies the value of the Cost Amount field';
                        ApplicationArea = NPRRetail;

                        trigger OnDrillDown()
                        begin
                            RetailCampaignCalcMgt.DrilldownItemEntries(Rec.Code, 0);
                        end;
                    }
                    field(Profit; RetailCampaignCalcMgt.CalcProfit(Rec.Code, 0))
                    {

                        Caption = 'Profit';
                        ToolTip = 'Specifies the value of the Profit field';
                        ApplicationArea = NPRRetail;

                        trigger OnDrillDown()
                        begin
                            RetailCampaignCalcMgt.DrilldownItemEntries(Rec.Code, 0);
                        end;
                    }
                    field("Profit %"; RetailCampaignCalcMgt.CalcProfitPct(Rec.Code, 0))
                    {

                        Caption = 'Profit %';
                        ToolTip = 'Specifies the value of the Profit % field';
                        ApplicationArea = NPRRetail;

                        trigger OnDrillDown()
                        begin
                            RetailCampaignCalcMgt.DrilldownItemEntries(Rec.Code, 0);
                        end;
                    }
                }
            }
            part(Control6014404; "NPR Retail Campaign Subform")
            {
                SubPageLink = "Campaign Code" = FIELD(Code);
                UpdatePropagation = Both;
                ApplicationArea = NPRRetail;

            }
            part(RetailItems; "NPR Retail Campgn.Item Subform")
            {
                SubPageLink = "Retail Campaign Code" = FIELD(Code);
                ApplicationArea = NPRRetail;

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
                PromotedCategory = Process;
                PromotedOnly = true;

                ToolTip = 'Executes the Planning Items action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ItemHierarchyMgmt: Codeunit "NPR Item Hierarchy Mgmt.";
                    ItemHierarchy: Record "NPR Item Hierarchy";
                begin
                    //-NPR5.48 [299436]
                    ItemHierarchyMgmt.CreateItemHierachyFromRetailCampaign(Rec);
                    if ItemHierarchy.Get(Rec.Code) then
                        PAGE.Run(6151051, ItemHierarchy);
                    //+NPR5.48 [299436]
                end;
            }
            action("View Planning Items")
            {
                Caption = 'View Planning Items';
                Image = ItemLines;
                RunObject = Page "NPR Item Hierarchy Card";
                RunPageLink = "Hierarchy Code" = FIELD(Code);

                ToolTip = 'Executes the View Planning Items action';
                ApplicationArea = NPRRetail;
            }
            action("View Demand Lines")
            {
                Caption = 'View Demand Lines';
                Image = ItemAvailability;
                Promoted = false;
                RunObject = Page "NPR Retail Repl. Demand Lines";
                RunPageLink = "Item Hierachy" = FIELD(Code),
                              "Distribution Group" = FIELD("Distribution Group");

                ToolTip = 'Executes the View Demand Lines action';
                ApplicationArea = NPRRetail;
            }
            action("View Distribution Lines")
            {
                Caption = 'View Distribution Lines';
                Image = ItemAvailbyLoc;
                Promoted = false;
                RunObject = Page "NPR Distribution Lines";
                RunPageLink = "Item Hiearachy" = FIELD(Code);

                ToolTip = 'Executes the View Distribution Lines action';
                ApplicationArea = NPRRetail;
            }
            action("Distribution Setup")
            {
                Caption = 'Distribution Setup';
                Image = SetupList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Distribution Setup";
                RunPageLink = "Item Hiearachy" = FIELD(Code);

                ToolTip = 'Executes the Distribution Setup action';
                ApplicationArea = NPRRetail;
            }
        }
        area(reporting)
        {
            action("Campaign Items")
            {
                Caption = 'Campaign Items';
                Image = Campaign;
                RunObject = Report "NPR Retail Campaign Items";

                ToolTip = 'Executes the Campaign Items action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPage.RetailItems.PAGE.ShowCampaignItems(Rec);
    end;

    trigger OnOpenPage()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        //-MAG2.26 [401235]
        MagentoEnabled := MagentoSetup.Get() and MagentoSetup."Magento Enabled";
        //+MAG2.26 [401235]
    end;

    var
        RetailCampaignCalcMgt: Codeunit "NPR Retail Campaign Calc. Mgt.";
        MagentoEnabled: Boolean;
}

