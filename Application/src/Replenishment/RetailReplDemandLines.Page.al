page 6151070 "NPR Retail Repl. Demand Lines"
{
    Extensible = False;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module
    // NPR5.39/JKL /20180222 CASE 299436  added units per parcel
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Action

    Caption = 'Retail Repl. Demand Lines';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Retail Repl. Demand Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Confirmed; Rec.Confirmed)
                {

                    ToolTip = 'Specifies the value of the Confirmed field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Demanded Quantity"; Rec."Demanded Quantity")
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {

                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Due Date"; Rec."Due Date")
                {

                    ToolTip = 'Specifies the value of the Due Date field';
                    ApplicationArea = NPRRetail;
                }
                field(Inventory; Rec.Inventory)
                {

                    ToolTip = 'Specifies the value of the Inventory field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. on Purch. Order"; Rec."Qty. on Purch. Order")
                {

                    ToolTip = 'Specifies the value of the Qty. on Purch. Order field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. on Sales Order"; Rec."Qty. on Sales Order")
                {

                    ToolTip = 'Specifies the value of the Qty. on Sales Order field';
                    ApplicationArea = NPRRetail;
                }
                field("Reordering Policy"; Rec."Reordering Policy")
                {

                    ToolTip = 'Specifies the value of the Reordering Policy field';
                    ApplicationArea = NPRRetail;
                }
                field("Needed Quantity"; Rec."Needed Quantity")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Needed Quantity field';
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
                field(Photo; Rec.Photo)
                {

                    ToolTip = 'Specifies the value of the Photo field';
                    ApplicationArea = NPRRetail;
                }
                field("Page no. in advert"; Rec."Page no. in advert")
                {

                    ToolTip = 'Specifies the value of the Page no. in advert field';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {

                    ToolTip = 'Specifies the value of the Priority field';
                    ApplicationArea = NPRRetail;
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {

                    ToolTip = 'Specifies the value of the Qty. per Unit of Measure field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Unit Price"; Rec."Campaign Unit Price")
                {

                    ToolTip = 'Specifies the value of the Period Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Campaign Unit Cost"; Rec."Campaign Unit Cost")
                {

                    ToolTip = 'Specifies the value of the Period Cost field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Demand Type"; Rec."Demand Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Demand Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Demand Date"; Rec."Demand Date")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Demand Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Demand Quantity"; Rec."Demand Quantity")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Demand Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Units per Parcel"; Rec."Units per Parcel")
                {

                    ToolTip = 'Specifies the value of the Units per Parcel field';
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;

            }
            part(Control6014415; "Item Replenishment FactBox")
            {
                SubPageLink = "No." = FIELD("Item No."),
                              "Location Filter" = FIELD("Location Code");
                Visible = false;
                ApplicationArea = NPRRetail;

            }
            part(Control6014414; "Item Planning FactBox")
            {
                SubPageLink = "No." = FIELD("Item No."),
                              "Location Filter" = FIELD("Location Code");
                Visible = true;
                ApplicationArea = NPRRetail;

            }
            part(Control6014413; "Item Warehouse FactBox")
            {
                SubPageLink = "No." = FIELD("Item No."),
                              "Location Filter" = FIELD("Location Code");
                Visible = false;
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Retail Replenishment Setup action';
                ApplicationArea = NPRRetail;
            }
            action("Distribution Setup")
            {
                Caption = 'Distribution Setup';
                Image = Setup;

                ToolTip = 'Executes the Distribution Setup action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Requisition Journal action';
                ApplicationArea = NPRRetail;
            }
            action("Confirm All")
            {
                Caption = 'Confirm All';
                Image = Confirm;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                ToolTip = 'Executes the Confirm All action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ModifyAll(Confirmed, true, true);
                    CurrPage.Update();
                end;
            }
            action("DeConfirm All")
            {
                Caption = 'DeConfirm All';

                ToolTip = 'Executes the DeConfirm All action';
                Image = Cancel;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ModifyAll(Confirmed, false, true);
                    CurrPage.Update();
                end;
            }
            action("Create Retail Campaign Orders")
            {
                Caption = 'Create Retail Campaign Orders';

                ToolTip = 'Executes the Create Retail Campaign Orders action';
                Image = Order;
                ApplicationArea = NPRRetail;

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

