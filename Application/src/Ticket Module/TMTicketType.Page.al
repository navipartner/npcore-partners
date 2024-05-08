page 6059784 "NPR TM Ticket Type"
{
    Extensible = False;

    Caption = 'Ticket Type';
    PageType = List;
    SourceTable = "NPR TM Ticket Type";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Code field. This is what connects a Item to the ticket module.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Related Ticket Type"; Rec."Related Ticket Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Related Ticket Type field';
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Category field, listed in the ListTicketItems service.';
                }
                field("Print Ticket"; Rec."Print Ticket")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies if the ticket should be printed or not. Print often happens during sale on POS.';
                }
                field("Print Object Type"; Rec."Print Object Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies if print should be handled by Codeunit, Retail print template, or a Report.';
                }
                field("RP Template Code"; Rec."RP Template Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the RP Template Code used to print the ticket.';
                }
                field("Print Object ID"; Rec."Print Object ID")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the object ID, if printing is done by Codeunit or Report.';
                }
                field("Admission Registration"; Rec."Admission Registration")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Ticket Admission Registration';
                    ToolTip = 'Specifies if the ticket should be issued as individual tickets, or as one group ticket.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the numberseries used to issue the ticket.';
                }
                field("External Ticket Pattern"; Rec."External Ticket Pattern")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the External Ticket Pattern. The pattern can include fixed text, the original ticket number and random characters. Any characters not within the [ and ] will be treated as fixed text. [S] – Will be substituted with the original ticket number from no. series. The following modifiers can be used. [N] – Random number, [N*4] – 4 random numbers, [A] – Random character, [A*4] – 4 random characters An example could be: TK-[S]-[N*4] which would result in TK-<ticket number>-<four random numbers>';
                }
                field("Activation Method"; Rec."Activation Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the Activation Method. POS (Default), will admit the default admission after sale from POS. POS (All Admissions), Will admit all the admissions after sale on POS. Scan will require the ticket to be scanned for admission.';
                }
                field("Ticket Configuration Source"; Rec."Ticket Configuration Source")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies Ticket Configuration Source. Ticket Type, will use the settings defined on the specific Type. Ticket BOM, will use the settings defined per ticket item on Ticket BOM table.';
                }
                field("Duration Formula"; Rec."Duration Formula")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Ticket Duration Formula';
                    ToolTip = 'Specifies the value of the Ticket Duration Formula field. The following modifiers apply. C, D, M and Y. Use 1Y for a validity of 1 year. or 30D for 30 days.';
                }
                field("Ticket Entry Validation"; Rec."Ticket Entry Validation")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies Ticket Entry Validation. Single will allow for one single use per admission. Same day will allow for unlimited uses per admission, on the same date as first admission. Multiple will allow for a number of uses per admission, as specified in "Max No of entried" spanning across multiple days.';
                }
                field("Max No. Of Entries"; Rec."Max No. Of Entries")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the Max No. Of Entries allowed, when Ticket entry validation is set for "Multiple';
                }
                field("Is Ticket"; Rec."Is Ticket")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Ticket field';
                }
                field("Membership Sales Item No."; Rec."Membership Sales Item No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the Membership Sales Item No. This is used only for selling Tickets as "Gift Memberships" where customers exchange them to a specific membership product, within the ticket valid to period. ';
                }
                field(CouponProfileCode; Rec."CouponProfileCode")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Profile Code field.';
                }
                field("DIY Print Layout Code"; Rec."DIY Print Layout Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the Ticket Layout Code from the Online Ticket designer. This needs to be filled if you want to export a ticket URL when doing Prepaid/Postpaid ticket. Or if you want the ticket URL to be published to notifications during create. This Ticket designer code, can be different from the Ticket Type Code. ';
                }
                field("eTicket Activated"; Rec."eTicket Activated")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies if eTicket should be activated on this ticket type. If activated a Wallet Template file, needs to be imported under "Process"';
                }
                field("eTicket Type Code"; Rec."eTicket Type Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the eTicket Type Code used to create the eTicket. This value should correspond to a template design on the PassServer.';
                }
                field("Defer Revenue"; Rec."Defer Revenue")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Defer Revenue field.';
                }
                field(DeferRevenueProfileCode; Rec.DeferRevenueProfileCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Defer Revenue Profile Code field.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(BatchAddTicketsToDeferral)
            {
                ToolTip = 'Add all Tickets for ticket type to Deferral from a specific date.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Batch Add Tickets to Deferral';
                Image = PostBatch;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                Ellipsis = true;
                //RunObject = report "NPR TM DeferBatchAddTicket";
                trigger OnAction()
                var
                    AddToDeferral: Report "NPR TM DeferBatchAddTicket";
                    TicketType: Record "NPR TM Ticket Type";
                begin
                    Rec.TestField("Defer Revenue");
                    TicketType.Get(Rec.Code);
                    TicketType.SetRecFilter();
                    AddToDeferral.SetTableView(TicketType);
                    AddToDeferral.Run();
                end;
            }
        }
        area(navigation)
        {
            action("Ticket Setup")
            {
                ToolTip = 'Navigate to ticket setup.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Setup';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket Setup";
            }
            action(Items)
            {
                ToolTip = 'Navigate to Items configured with the selected Ticket Type.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Items';
                Image = ItemLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "Item List";
                RunPageLink = "NPR Ticket Type" = FIELD(Code);
            }
            action(Admissions)
            {
                ToolTip = 'Navigate to Admission List.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Admissions';
                Image = WorkCenter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "NPR TM Ticket Admissions";
            }

            action(TicketItemsFiltered)
            {
                ToolTip = 'Navigate to Ticket Items List, showing Tickets Items configured with the selected Ticket Type';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Items (Filtered)';
                Image = ItemTracing;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                trigger OnAction()
                var
                    TicketItemsListPage: Page "NPR TM Ticket Item List";
                begin
                    TicketItemsListPage.SetTicketTypeFilter(Rec.Code);
                    TicketItemsListPage.Run();
                end;
            }

            action(TicketItemsAll)
            {
                ToolTip = 'Navigate to Ticket Items List, showing Tickets Items configured with the selected Ticket Type';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Items (All)';
                Image = ItemTracing;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "NPR TM Ticket Item List";
            }

            action("Ticket BOM")
            {
                ToolTip = 'Navigate to Ticket BOM, showing Tickets configured with the selected Ticket Type';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Admission BOM';
                Image = BOM;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "NPR TM Ticket BOM";
            }

            action("E-Mail Templates")
            {
                ToolTip = 'Navigate to Email templates';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'E-Mail Templates';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "NPR E-mail Templates";
                RunPageView = WHERE("Table No." = CONST(6060110));
            }
            action("SMS Template")
            {
                ToolTip = 'Navigate to SMS templates';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'SMS Template';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "NPR SMS Template List";
                RunPageView = WHERE("Table No." = CONST(6060110));
            }

            action("Export Wallet Template File")
            {
                Caption = 'Export Wallet Template File';
                ToolTip = 'Exports the default or current template used to send information to wallet.';
                Image = ExportAttachment;
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                    PassData: Text;
                    FileName: Text;
                    TemplateOutStream: outstream;
                    TemplateInStream: InStream;
                    FileNameLbl: Label '%1 - %2.json', Locked = true;
                    DownloadLbl: Label 'Downloading template';
                begin
                    Rec.CalcFields("eTicket Template");
                    if (not Rec."eTicket Template".HasValue()) then begin
                        PassData := TicketRequestManager.GetDefaultTemplate();
                        Rec."eTicket Template".CreateOutStream(TemplateOutStream);
                        TemplateOutStream.Write(PassData);
                        Rec.Modify();
                        Rec.CalcFields("eTicket Template");
                    end;

                    TempBlob.FromRecord(Rec, Rec.FieldNo("eTicket Template"));
                    if (not TempBlob.HasValue()) then
                        exit;
                    TempBlob.CreateInStream(TemplateInStream);
                    FileName := StrSubstNo(FileNameLbl, Rec.Code, Rec.Description);
                    DownloadFromStream(TemplateInStream, DownloadLbl, '', 'Template Files (*.json)|*.json', FileName);
                end;
            }
            action("Import File")
            {
                Caption = 'Import Wallet Template File';
                ToolTip = 'Import a new template to be used to send information to wallet.';
                Image = ImportCodes;
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                    FileName: Text;
                    RecRef: RecordRef;
                begin
                    FileName := FileMgt.BLOBImportWithFilter(TempBlob, IMPORT_FILE, '', 'Template Files (*.json)|*.json', 'json');

                    if (FileName = '') then
                        exit;

                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, Rec.FieldNo("eTicket Template"));
                    RecRef.SetTable(Rec);

                    Rec.Modify(true);
                    Clear(TempBlob);
                end;
            }
        }
    }

    var
        IMPORT_FILE: Label 'Import File';

    internal procedure HideTickets()
    begin
        Rec.SetRange("Is Ticket", false);
    end;

}

