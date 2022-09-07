page 6059888 "NPR TM Ticket Item List"
{
    Extensible = False;
    PageType = List;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    UsageCategory = Lists;
    SourceTable = "Item Variant";
    SourceTableTemporary = true;
    Caption = 'Ticket Item List';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                Editable = false;
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Code"; Rec."Code")
                {
                    Caption = 'Variant Code';
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }

                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of Item Description field.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("TM Ticket Type"; _AuxItem."TM Ticket Type")
                {
                    ToolTip = 'Specifies the value of the Ticket Type field.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
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
            action(Edit)
            {
                ToolTip = 'This action will open the Ticket Item Card.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                RunObject = page "NPR TM Ticket Item Card";
                RunPageLink = "Item No." = field("Item No."), "Code" = field("Code");
                Image = Item;
            }
            Action(CreatePrepaidTickets)
            {
                ToolTip = 'Create a set of tickets for which payment has already been handled. (F.ex. free tickets.) ';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Create Prepaid Tickets';
                Scope = Repeater;
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
            Action(CreatePostpaidTickets)
            {
                ToolTip = 'Create a set of tickets that can be invoiced after ticket has been used.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Scope = Repeater;
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
    }

    var
        _AuxItem: Record "NPR Auxiliary Item";
        _TicketPaymentType: Option DIRECT,PREPAID,POSTPAID;

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
                    Rec.Insert();
                end;
            end;
        until (AuxItem.Next() = 0);

        if (not Rec.FindFirst()) then;
    end;

    trigger OnOpenPage()
    begin

    end;

    trigger OnAfterGetRecord()
    var
        Item: Record "Item";
    begin
        Clear(_AuxItem);
        if (Item.Get(Rec."Item No.")) then
            Item.NPR_GetAuxItem(_AuxItem);
    end;
}