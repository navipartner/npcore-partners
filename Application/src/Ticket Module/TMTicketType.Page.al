page 6059784 "NPR TM Ticket Type"
{

    Caption = 'Ticket Type';
    PageType = List;
    SourceTable = "NPR TM Ticket Type";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Code field';
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
                field("Print Ticket"; Rec."Print Ticket")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Ticket field';
                }
                field("Print Object Type"; Rec."Print Object Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Objekt Type field';
                }
                field("RP Template Code"; Rec."RP Template Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the RP Template Code field';
                }
                field("Print Object ID"; Rec."Print Object ID")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Object ID field';
                }
                field("Admission Registration"; Rec."Admission Registration")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Registration field';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the No. Series field';
                }
                field("External Ticket Pattern"; Rec."External Ticket Pattern")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Ticket Pattern field';
                }
                field("Activation Method"; Rec."Activation Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Activation Method field';
                }
                field("Ticket Configuration Source"; Rec."Ticket Configuration Source")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Configuration Source field';
                }
                field("Duration Formula"; Rec."Duration Formula")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Duration Formula field';
                }
                field("Ticket Entry Validation"; Rec."Ticket Entry Validation")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Entry Validation field';
                }
                field("Max No. Of Entries"; Rec."Max No. Of Entries")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Max No. Of Entries field';
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
                    ToolTip = 'Specifies the value of the Membership Sales Item No. field';
                }
                field("DIY Print Layout Code"; Rec."DIY Print Layout Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Layout Code field';
                }
                field("eTicket Activated"; Rec."eTicket Activated")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the eTicket Activated field';
                }
                field("eTicket Type Code"; Rec."eTicket Type Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the eTicket Type Code field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {

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
                ToolTip = 'Navigate to Item List.';
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
            action("Ticket BOM")
            {
                ToolTip = 'Navigate to ticket contents setup.';
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
                ToolTip = 'Setup templates for ticket e-mail.';
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
                ToolTip = 'Setup templates for ticket SMS.';
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
                ToolTip = 'Define information sent to wallet.';
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

    procedure HideTickets()
    begin
        Rec.SetRange("Is Ticket", false);
    end;

}

