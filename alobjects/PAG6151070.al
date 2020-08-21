page 6151070 "Retail Repl. Demand Lines"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module
    // NPR5.39/JKL /20180222 CASE 299436  added units per parcel
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Action

    Caption = 'Retail Repl. Demand Lines';
    PageType = List;
    SourceTable = "Retai Repl. Demand Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Confirmed; Confirmed)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
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
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Demanded Quantity"; "Demanded Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = All;
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                }
                field("Qty. on Purch. Order"; "Qty. on Purch. Order")
                {
                    ApplicationArea = All;
                }
                field("Qty. on Sales Order"; "Qty. on Sales Order")
                {
                    ApplicationArea = All;
                }
                field("Reordering Policy"; "Reordering Policy")
                {
                    ApplicationArea = All;
                }
                field("Needed Quantity"; "Needed Quantity")
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
                field(Photo; Photo)
                {
                    ApplicationArea = All;
                }
                field("Page no. in advert"; "Page no. in advert")
                {
                    ApplicationArea = All;
                }
                field(Priority; Priority)
                {
                    ApplicationArea = All;
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Campaign Unit Price"; "Campaign Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Campaign Unit Cost"; "Campaign Unit Cost")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Demand Type"; "Demand Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Demand Date"; "Demand Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Demand Quantity"; "Demand Quantity")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Units per Parcel"; "Units per Parcel")
                {
                    ApplicationArea = All;
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
            }
            part(Control6014415; "Item Replenishment FactBox")
            {
                SubPageLink = "No." = FIELD("Item No."),
                              "Location Filter" = FIELD("Location Code");
                Visible = false;
            }
            part(Control6014414; "Item Planning FactBox")
            {
                SubPageLink = "No." = FIELD("Item No."),
                              "Location Filter" = FIELD("Location Code");
                Visible = true;
            }
            part(Control6014413; "Item Warehouse FactBox")
            {
                SubPageLink = "No." = FIELD("Item No."),
                              "Location Filter" = FIELD("Location Code");
                Visible = false;
            }
            part(Control6014412; "Purchase Price Factbox")
            {
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Vendor No." = FIELD("Vendor No.");
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
                RunObject = Page "Retail Replenisment Setup";
            }
            action("Distribution Setup")
            {
                Caption = 'Distribution Setup';
                Image = Setup;

                trigger OnAction()
                var
                    DistributionSetup: Record "Distribution Setup";
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
            }
            action("Confirm All")
            {
                Caption = 'Confirm All';
                Image = Confirm;
                Promoted = true;

                trigger OnAction()
                begin
                    ModifyAll(Confirmed, true, true);
                    CurrPage.Update;
                end;
            }
            action("DeConfirm All")
            {
                Caption = 'DeConfirm All';

                trigger OnAction()
                begin
                    ModifyAll(Confirmed, false, true);
                    CurrPage.Update;
                end;
            }
            action("Create Retail Campaign Orders")
            {
                Caption = 'Create Retail Campaign Orders';

                trigger OnAction()
                var
                    RetailReplenishmentMgmt: Codeunit "Retail Replenishment Mgmt";
                begin
                    RetailReplenishmentMgmt.CreateCampaignPurchOrdersDirectFromDemand(Rec);
                end;
            }
        }
    }
}

