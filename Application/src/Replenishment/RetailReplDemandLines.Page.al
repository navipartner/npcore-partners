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
                field(Confirmed; Rec.Confirmed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Confirmed field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Demanded Quantity"; Rec."Demanded Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Due Date field';
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory field';
                }
                field("Qty. on Purch. Order"; Rec."Qty. on Purch. Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. on Purch. Order field';
                }
                field("Qty. on Sales Order"; Rec."Qty. on Sales Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. on Sales Order field';
                }
                field("Reordering Policy"; Rec."Reordering Policy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reordering Policy field';
                }
                field("Needed Quantity"; Rec."Needed Quantity")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Needed Quantity field';
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
                field(Photo; Rec.Photo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Photo field';
                }
                field("Page no. in advert"; Rec."Page no. in advert")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Page no. in advert field';
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Priority field';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. per Unit of Measure field';
                }
                field("Campaign Unit Price"; Rec."Campaign Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Price field';
                }
                field("Campaign Unit Cost"; Rec."Campaign Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Cost field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Demand Type"; Rec."Demand Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Demand Type field';
                }
                field("Demand Date"; Rec."Demand Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Demand Date field';
                }
                field("Demand Quantity"; Rec."Demand Quantity")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Demand Quantity field';
                }
                field("Units per Parcel"; Rec."Units per Parcel")
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
                    DistributionSetup.Reset();
                    DistributionSetup.SetFilter("Item Hiearachy", Rec.GetFilter("Item Hierachy"));
                    PAGE.RunModal(6151062, DistributionSetup);
                end;
            }
            action("Requisition Wortksheet")
            {
                Caption = 'Requisition Journal';
                Image = CalculatePlan;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "Req. Worksheet";
                ApplicationArea = All;
                ToolTip = 'Executes the Requisition Journal action';
            }
            action("Confirm All")
            {
                Caption = 'Confirm All';
                Image = Confirm;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Confirm All action';

                trigger OnAction()
                begin
                    Rec.ModifyAll(Confirmed, true, true);
                    CurrPage.Update();
                end;
            }
            action("DeConfirm All")
            {
                Caption = 'DeConfirm All';
                ApplicationArea = All;
                ToolTip = 'Executes the DeConfirm All action';
                Image = Cancel;

                trigger OnAction()
                begin
                    Rec.ModifyAll(Confirmed, false, true);
                    CurrPage.Update();
                end;
            }
            action("Create Retail Campaign Orders")
            {
                Caption = 'Create Retail Campaign Orders';
                ApplicationArea = All;
                ToolTip = 'Executes the Create Retail Campaign Orders action';
                Image = Order;

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

