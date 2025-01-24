page 6059888 "NPR TM Ticket Item List"
{
    Extensible = False;
    PageType = List;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    UsageCategory = Lists;
    SourceTable = "Item Variant";
    SourceTableTemporary = true;
    Caption = 'Ticket Item List';
    PromotedActionCategories = 'New,Process,Report,History,Manage';
    Editable = false;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                Editable = false;
                Caption = 'Item Information';
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
                    Visible = false;
                }
                field(_AdmissionCount; _AdmissionCount)
                {
                    Caption = 'Admission Count';
                    ToolTip = 'Specifies the value of the Admission Count field.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of Item Description field.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    trigger OnDrillDown()
                    var
                        TicketItemCard: Page "NPR TM Ticket Item Card";
                        ItemVariant: Record "Item Variant";
                    begin

                        ItemVariant.SetFilter("Item No.", '=%1', Rec."Item No.");
                        ItemVariant.SetFilter("Code", '=%1', Rec."Code");
                        TicketItemCard.SetTableView(ItemVariant);
                        TicketItemCard.Run();
                    end;
                }
                field("TM Ticket Type"; _Item."NPR Ticket Type")
                {
                    ToolTip = 'Specifies the value of the Ticket Type field.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Category; _TicketType.Category)
                {
                    ToolTip = 'Specifies the value of the Ticket Types Category field.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field(Description_2; Rec."Description 2")
                {
                    ToolTip = 'Specifies the value of the Description 2 field.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
            }
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
                Caption = 'Edit';
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

        }
        area(Processing)
        {
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
            Action(ImportExternalTickets)
            {
                ToolTip = 'Import tickets created by external party.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Import External Tickets';
                Image = ExternalDocument;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ImportTicket: Codeunit "NPR TM ImportTicketControl";
                begin
                    ImportTicket.ImportTicketsFromFile(true);
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
                    SyncMessage: Label 'Ticket item %1 was scheduled for synchronization, endpoints will be updated in a moment.';
                begin
                    ResyncTicket.DeepRefreshItem(Rec."Item No.");
                    Message(SyncMessage, Rec."Item No.");
                end;
            }
        }
    }

    var
        _Item: Record Item;
        _TicketType: Record "NPR TM Ticket Type";
        _TicketPaymentType: Option DIRECT,PREPAID,POSTPAID;
        _TicketTypeCodeFilter: Text;
        _AdmissionCount: Integer;

    trigger OnOpenPage()
    begin
        if (Rec.IsTemporary()) then
            Rec.DeleteAll();

        LoadRecords();
    end;

    trigger OnAfterGetRecord()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        Clear(_Item);
        Clear(_TicketType);
        if (_Item.Get(Rec."Item No.")) then
            if (_TicketType.Get(_Item."NPR Ticket Type")) then;

        TicketBom.SetFilter("Item No.", '=%1', Rec."Item No.");
        _AdmissionCount := TicketBom.Count();
    end;

    procedure SetTicketTypeFilter(TicketTypeCodeFilter: text)
    begin
        _TicketTypeCodeFilter := TicketTypeCodeFilter
    end;

    local procedure LoadRecords()
    var
        Item: Record "Item";
        ItemVariant: Record "Item Variant";
    begin
        if (_TicketTypeCodeFilter = '') then
            Item.SetFilter("NPR Ticket Type", '<>%1', '')
        else
            Item.SetFilter("NPR Ticket Type", '%1', _TicketTypeCodeFilter);

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
}