page 6059884 "NPR TM Ticket Item Card"
{
    Extensible = False;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "Item Variant";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {

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
                field("NPR Ticket Type"; _AuxItem."TM Ticket Type")
                {
                    Caption = 'Ticket Type';
                    ToolTip = 'Specifies the ticket type that will be used with the item.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    TableRelation = "NPR TM Ticket Type";
                    trigger OnValidate()
                    begin
                        _AuxItem.Validate("TM Ticket Type");
                        _Item.NPR_SetAuxItem(_AuxItem);
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
        }
    }

    trigger OnInit()
    var
        Item: Record "Item";
        ItemVariant: Record "Item Variant";
        AuxItem: Record "NPR Auxiliary Item";
    begin
        AuxItem.SetFilter("TM Ticket Type", '<>%1', '');
        if (not AuxItem.FindSet()) then
            exit;

        repeat
            if (Item.Get(AuxItem."Item No.")) then begin
                ItemVariant.SetFilter("Item No.", '=%1', AuxItem."Item No.");
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
            end;
        until (AuxItem.Next() = 0);

        if (not Rec.FindFirst()) then;
    end;

    trigger OnModifyRecord(): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        _AuxItem.TestField("TM Ticket Type");
        _Item.NPR_SaveAuxItem();

        if (Rec."Code" <> '') then
            if (ItemVariant.Get(Rec."Item No.", Rec."Code")) then begin
                ItemVariant.TransferFields(Rec, false);
                ItemVariant.Modify();
            end;

    end;

    trigger OnClosePage()
    begin
        _Item.NPR_SaveAuxItem();
    end;

    trigger OnAfterGetRecord()
    begin
        _Item.Get(Rec."Item No.");
        _Item.NPR_GetAuxItem(_AuxItem);
    end;

    var
        _AuxItem: Record "NPR Auxiliary Item";
        _Item: Record "Item";
        _TicketPaymentType: Option DIRECT,PREPAID,POSTPAID;
}