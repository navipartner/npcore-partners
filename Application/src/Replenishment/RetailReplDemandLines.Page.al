page 6151070 "NPR Retail Repl. Demand Lines"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module
    // NPR5.39/JKL /20180222 CASE 299436  added units per parcel
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Action

    Caption = 'Retail Repl. Demand Lines';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Retail Repl. Demand Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Confirmed; Confirmed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Confirmed field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Demanded Quantity"; "Demanded Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Due Date field';
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory field';
                }
                field("Qty. on Purch. Order"; "Qty. on Purch. Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. on Purch. Order field';
                }
                field("Qty. on Sales Order"; "Qty. on Sales Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. on Sales Order field';
                }
                field("Reordering Policy"; "Reordering Policy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reordering Policy field';
                }
                field("Needed Quantity"; "Needed Quantity")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Needed Quantity field';
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Item No. field';
                }
                field(Photo; Photo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Photo field';
                }
                field("Page no. in advert"; "Page no. in advert")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Page no. in advert field';
                }
                field(Priority; Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Priority field';
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. per Unit of Measure field';
                }
                field("Campaign Unit Price"; "Campaign Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Price field';
                }
                field("Campaign Unit Cost"; "Campaign Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Cost field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Demand Type"; "Demand Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Demand Type field';
                }
                field("Demand Date"; "Demand Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Demand Date field';
                }
                field("Demand Quantity"; "Demand Quantity")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Demand Quantity field';
                }
                field("Units per Parcel"; "Units per Parcel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Units per Parcel field';
                }
            }
        }
        area(factboxes)
        {
            part(Control6014416; "Item Invoicing FactBox")
            {
                SubPageLink = "No." = FIELD("Item No."),
                              "Location Filter" = FIELD("Location Code");
                Visible = true;
                ApplicationArea = All;
            }
            part(Control6014415; "Item Replenishment FactBox")
            {
                SubPageLink = "No." = FIELD("Item No."),
                              "Location Filter" = FIELD("Location Code");
                Visible = false;
                ApplicationArea = All;
            }
            part(Control6014414; "Item Planning FactBox")
            {
                SubPageLink = "No." = FIELD("Item No."),
                              "Location Filter" = FIELD("Location Code");
                Visible = true;
                ApplicationArea = All;
            }
            part(Control6014413; "Item Warehouse FactBox")
            {
                SubPageLink = "No." = FIELD("Item No."),
                              "Location Filter" = FIELD("Location Code");
                Visible = false;
                ApplicationArea = All;
            }
            part(Control6014412; "NPR Purchase Price Factbox")
            {
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Vendor No." = FIELD("Vendor No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Retail Replenishment Setup")
            {
                Caption = 'Retail Replenishment Setup';
                Image = Setup;
                RunObject = Page "NPR Retail Replenishment Setup";
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Replenishment Setup action';
            }
            action("Distribution Setup")
            {
                Caption = 'Distribution Setup';
                Image = Setup;
                ApplicationArea = All;
                ToolTip = 'Executes the Distribution Setup action';

                trigger OnAction()
                var
                    DistributionSetup: Record "NPR Distribution Setup";
                begin
                    DistributionSetup.Reset;
                    DistributionSetup.SetFilter("Item Hiearachy", GetFilter("Item Hierachy"));
                    PAGE.RunModal(6151062, DistributionSetup);
                end;
            }
            action("Requisition Wortksheet")
            {
                Caption = 'Requisition Journal';
                Image = CalculatePlan;
                Promoted = true;
                RunObject = Page "Req. Worksheet";
                ApplicationArea = All;
                ToolTip = 'Executes the Requisition Journal action';
            }
            action("Confirm All")
            {
                Caption = 'Confirm All';
                Image = Confirm;
                Promoted = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Confirm All action';

                trigger OnAction()
                begin
                    ModifyAll(Confirmed, true, true);
                    CurrPage.Update;
                end;
            }
            action("DeConfirm All")
            {
                Caption = 'DeConfirm All';
                ApplicationArea = All;
                ToolTip = 'Executes the DeConfirm All action';

                trigger OnAction()
                begin
                    ModifyAll(Confirmed, false, true);
                    CurrPage.Update;
                end;
            }
            action("Create Retail Campaign Orders")
            {
                Caption = 'Create Retail Campaign Orders';
                ApplicationArea = All;
                ToolTip = 'Executes the Create Retail Campaign Orders action';

                trigger OnAction()
                var
                    RetailReplenishmentMgmt: Codeunit "NPR Retail Replenish. Mgt.";
                begin
                    RetailReplenishmentMgmt.CreateCampaignPurchOrdersDirectFromDemand(Rec);
                end;
            }
        }
    }
}

