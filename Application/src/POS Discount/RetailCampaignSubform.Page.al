page 6014612 "NPR Retail Campaign Subform"
{
    // NPR5.38.01/MHA /20171220  CASE 299436 Object created - Retail Campaign

    AutoSplitKey = true;
    Caption = 'Discounts';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Retail Campaign Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Type field';
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Sales Amount"; RetailCampaignCalcMgt.CalcSalesAmount("Campaign Code", "Line No."))
                {
                    ApplicationArea = All;
                    Caption = 'Sales Amount';
                    ToolTip = 'Specifies the value of the Sales Amount field';

                    trigger OnDrillDown()
                    begin
                        RetailCampaignCalcMgt.DrilldownItemEntries("Campaign Code", "Line No.");
                    end;
                }
                field("Cost Amount"; RetailCampaignCalcMgt.CalcCostAmount("Campaign Code", "Line No."))
                {
                    ApplicationArea = All;
                    Caption = 'Cost Amount';
                    ToolTip = 'Specifies the value of the Cost Amount field';

                    trigger OnDrillDown()
                    begin
                        RetailCampaignCalcMgt.DrilldownItemEntries("Campaign Code", "Line No.");
                    end;
                }
                field(Profit; RetailCampaignCalcMgt.CalcProfit("Campaign Code", "Line No."))
                {
                    ApplicationArea = All;
                    Caption = 'Profit';
                    ToolTip = 'Specifies the value of the Profit field';

                    trigger OnDrillDown()
                    begin
                        RetailCampaignCalcMgt.DrilldownItemEntries("Campaign Code", "Line No.");
                    end;
                }
                field("Profit %"; RetailCampaignCalcMgt.CalcProfitPct("Campaign Code", "Line No."))
                {
                    ApplicationArea = All;
                    Caption = 'Profit %';
                    ToolTip = 'Specifies the value of the Profit % field';

                    trigger OnDrillDown()
                    begin
                        RetailCampaignCalcMgt.DrilldownItemEntries("Campaign Code", "Line No.");
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CurrPage.Update(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Type := xRec.Type;
    end;

    var
        RetailCampaignHeader: Record "NPR Retail Campaign Header";
        RetailCampaignCalcMgt: Codeunit "NPR Retail Campaign Calc. Mgt.";
}

