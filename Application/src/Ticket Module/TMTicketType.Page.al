page 6059784 "NPR TM Ticket Type"
{

    Caption = 'Ticket Type';
    PageType = List;
    SourceTable = "NPR TM Ticket Type";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Related Ticket Type"; "Related Ticket Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Print Ticket"; "Print Ticket")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Print Object Type"; "Print Object Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("RP Template Code"; "RP Template Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Print Object ID"; "Print Object ID")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Registration"; "Admission Registration")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("External Ticket Pattern"; "External Ticket Pattern")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Activation Method"; "Activation Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Configuration Source"; "Ticket Configuration Source")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Duration Formula"; "Duration Formula")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Entry Validation"; "Ticket Entry Validation")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Max No. Of Entries"; "Max No. Of Entries")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Is Ticket"; "Is Ticket")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Membership Sales Item No."; "Membership Sales Item No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("DIY Print Layout Code"; "DIY Print Layout Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("eTicket Activated"; "eTicket Activated")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("eTicket Type Code"; "eTicket Type Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit Pass Template")
            {
                ToolTip = 'Define information sent to wallet.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'Edit Pass Template';
                Image = Template;
                Promoted = true;
                PromotedIsBig = true;
                Visible = not WebClient;

                trigger OnAction()
                begin
                    EditPassTemplate();
                end;
            }

            action("Export Wallet Template File")
            {
                Caption = 'Export Wallet Template File';
                ToolTip = 'Exports the default or current template used to send information to wallet.';
                Image = ExportAttachment;
                Visible = WebClient;
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                    TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                    Path: Text;
                    PassData: Text;
                    TemplateOutStream: outstream;
                begin
                    CalcFields("eTicket Template");
                    if (not "eTicket Template".HasValue()) then begin
                        PassData := TicketRequestManager.GetDefaultTemplate();
                        "eTicket Template".CreateOutStream(TemplateOutStream);
                        TemplateOutStream.Write(PassData);
                        Modify();
                        CalcFields("eTicket Template");
                    end;

                    TempBlob.FromRecord(Rec, FieldNo("eTicket Template"));
                    if (not TempBlob.HasValue()) then
                        exit;
                    Path := FileMgt.BLOBExport(TempBlob, TemporaryPath + StrSubstNo('%1 - %2.json', Code, Description), true);

                end;
            }
            action("Import File")
            {
                Caption = 'Import Wallet Template File';
                ToolTip = 'Define information sent to wallet.';
                Image = ImportCodes;
                Visible = WebClient;
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                    Path: Text;
                    FileName: Text;
                    RecRef: RecordRef;
                begin
                    FileName := FileMgt.BLOBImportWithFilter(TempBlob, IMPORT_FILE, '', 'Template Files (*.json)|*.json', 'json');

                    if (FileName = '') then
                        exit;

                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, Rec.FieldNo("eTicket Template"));
                    RecRef.SetTable(Rec);

                    Modify(true);
                    Clear(TempBlob);

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
                PromotedCategory = Process;
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
                PromotedCategory = Process;
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
                PromotedCategory = Process;
                RunObject = Page "NPR TM Ticket Admissions";

            }
            action("Ticket BOM")
            {
                ToolTip = 'Navigate to ticket contents setup.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Admission BOM';
                Image = BOM;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR TM Ticket BOM";

            }
            separator(Separator6014412)
            {
            }
            action("E-Mail Templates")
            {
                ToolTip = 'Setup templates for ticket e-mail.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'E-Mail Templates';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
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
                PromotedIsBig = true;
                RunObject = Page "NPR SMS Template List";
                RunPageView = WHERE("Table No." = CONST(6060110));

            }

        }
    }

    trigger OnOpenPage()
    begin
        WebClient := IsWebClient();
    end;

    var
        IMPORT_FILE: Label 'Import File';
        FileManagement: Codeunit "File Management";
        Webclient: Boolean;

    procedure HideTickets()
    begin
        SetRange("Is Ticket", false);
    end;

    local procedure EditPassTemplate()
    begin

        Rec.EditPassTemplate();
        CurrPage.Update(true);
    end;

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if ActiveSession.Get(ServiceInstanceId, SessionId) then
            exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
    end;
}

