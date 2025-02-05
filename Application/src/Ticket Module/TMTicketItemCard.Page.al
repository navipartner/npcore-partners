page 6059884 "NPR TM Ticket Item Card"
{
    Extensible = False;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "Item Variant";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Process,Report,History,Manage';
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
    Caption = 'Ticket Item Card';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Ticket Item';

                field("No."; Rec."Item No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Code"; Rec."Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }

                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    trigger OnValidate()
                    begin
                        if (Rec.Code = '') then begin
                            _Item.Description := Rec.Description;
                            _Item.Modify();
                        end;
                    end;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ToolTip = 'Specifies a description 2 of the item.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    trigger OnValidate()
                    begin
                        if (Rec.Code = '') then begin
                            _Item."Description 2" := Rec."Description 2";
                            _Item.Modify();
                        end;
                    end;
                }
                field("Unit Price"; _Item."Unit Price")
                {
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    trigger OnValidate()
                    begin
                        _Item.Modify();
                    end;
                }
                field("Price Includes VAT"; _Item."Price Includes VAT")
                {
                    ToolTip = 'Specifies if the Unit Price and Line Amount fields on sales document lines for this item should be shown with or without VAT.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    trigger OnValidate()
                    begin
                        _Item.Modify();
                    end;
                }
                field("NPR Ticket Type"; _Item."NPR Ticket Type")
                {
                    Caption = 'Ticket Type';
                    ToolTip = 'Specifies the ticket type that will be used with the item.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    TableRelation = "NPR TM Ticket Type";
                    trigger OnValidate()
                    begin
                        _Item.Modify();
                    end;
                }
                field(POSAdmitAction; _Item."NPR POS Admit Action")
                {
                    ToolTip = 'Specifies if tickets will be printed and admitted in the Print & Admit POS Action.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    trigger OnValidate()
                    begin
                        _Item.Modify();
                    end;
                }

            }
            part(TicketBom; "NPR TM Ticket BOM Part")
            {
                Caption = 'Ticket Bill-of-Material';
                SubPageLink = "Item No." = field("Item No."), "Variant Code" = field("Code");
                UpdatePropagation = Both;
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            Action("Create Prepaid Tickets")
            {
                ToolTip = 'Create a set of tickets for which payment has already been handled. (F.ex. free tickets.) ';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Create Prepaid Tickets';
                Image = PrepaymentInvoice;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    TicketBomPage: Page "NPR TM Ticket BOM";
                begin
                    TicketBomPage.MakeTickets(_TicketPaymentType::PREPAID, Rec."Item No.", Rec.Code);
                end;
            }
            Action("Create Postpaid Tickets")
            {
                ToolTip = 'Create a set of tickets that can be invoiced after ticket has been used.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Create Postpaid Tickets';
                Image = Invoice;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    TicketBomPage: Page "NPR TM Ticket BOM";
                begin
                    TicketBomPage.MakeTickets(_TicketPaymentType::POSTPAID, Rec."Item No.", Rec.Code);
                end;
            }
            Action(CreateTourTickets)
            {
                ToolTip = 'Create a tickets that is suitable for tours.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Scope = Repeater;
                Caption = 'Create Tour Ticket';
                Image = CustomerGroup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    TicketBomPage: Page "NPR TM Ticket BOM";
                begin
                    TicketBomPage.MakeTourTicket(Rec."Item No.", Rec.Code);
                end;
            }
            Action(ResynchronizeMagento)
            {
                ToolTip = 'This action will emit data related to this ticket item to synchronize external systems.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Scope = Repeater;
                Caption = 'Synchronize Ticket Data';
                Image = RefreshText;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    ResyncTicket: Codeunit "NPR TM TicketToDataLog";
                begin
                    ResyncTicket.DeepRefreshItem(Rec."Item No.");
                end;
            }
        }
        area(Creation)
        {
            action(TicketWizard)
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Create all required setup for a ticket from a single page.';
                Caption = 'Ticket Wizard';
                Image = Action;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    TicketWizardMgr: Codeunit "NPR TM Ticket Wizard";
                begin
                    TicketWizardMgr.Run();
                end;
            }
        }
        area(Navigation)
        {
            Action(NavigateIssuedTickets)
            {
                ToolTip = 'Navigate to Issued Tickets';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Issued Tickets';
                Image = Navigate;
                RunObject = Page "NPR TM Ticket List";
                RunPageLink = "Item No." = field("Item No.");
            }
            Action(NavigateTicketType)
            {
                ToolTip = 'Navigate to Ticket Type';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Types';
                Image = Category;
                RunObject = Page "NPR TM Ticket Type";
            }
            Action(NavigateItems)
            {
                ToolTip = 'Navigate to Item Card.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Item';
                Image = ItemLines;
                RunObject = Page "Item Card";
                RunPageLink = "No." = field("Item No.");
            }
            Action(NavigateDefaultAdmission)
            {
                ToolTip = 'Navigate to Default Admission per POS Unit';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Default Admission per POS Unit';
                Image = Default;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "NPR TM POS Default Admission";
                RunPageLink = "Item No." = field("Item No."), "Variant Code" = field("Code"), "Station Type" = const(POS_UNIT);
            }
        }
    }

    trigger OnInit()
    var
        Item: Record "Item";
        ItemVariant: Record "Item Variant";
    begin
        Item.SetFilter("NPR Ticket Type", '<>%1', '');
        if (not Item.FindSet()) then
            exit;

        repeat
            ItemVariant.SetFilter("Item No.", '=%1', Item."No.");
            if (ItemVariant.FindSet()) then begin
                repeat
                    Rec.TransferFields(ItemVariant, true);
                    Rec.Insert();
                until (ItemVariant.Next() = 0);
            end else begin
                Clear(Rec);
                Rec."Item No." := Item."No.";
                Rec.Description := Item.Description;
                Rec."Description 2" := Item."Description 2";
                Rec.Insert();
            end;
        until (Item.Next() = 0);

        if (not Rec.FindFirst()) then;
    end;

    trigger OnModifyRecord(): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        if (Rec."Code" <> '') then
            if (ItemVariant.Get(Rec."Item No.", Rec."Code")) then begin
                ItemVariant.TransferFields(Rec, false);
                ItemVariant.Modify();
            end;

    end;

    trigger OnAfterGetRecord()
    begin
        _Item.Get(Rec."Item No.");
    end;

    var
        _Item: Record "Item";
        _TicketPaymentType: Option DIRECT,PREPAID,POSTPAID;
}