page 6151356 "NPR TM ImportTicketLog"
{
    Extensible = true;
    PageType = List;
    Caption = 'Import Ticket Log';
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    UsageCategory = Lists;
    SourceTable = "NPR TM ImportTicketLog";
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTableView = Sorting(EntryNo) Order(Descending);

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field(JobId; Rec.JobId)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Job ID field.';
                }
                field(FileName; Rec.FileName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the File Name field.';
                }
                field(ImportDuration; Rec.ImportDuration)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Import Duration field.';
                }
                field(Success; Rec.Success)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Success field.';
                }
                field(NumberOfTickets; Rec.NumberOfTickets)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Number of Tickets field.';
                }
                field(ImportedBy; Rec.ImportedBy)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Import by field.';
                }
                field(ResponseMessage; Rec.ResponseMessage)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Response Message field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ListOrder)
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Show Orders';
                ToolTip = 'Show imported ticket orders.';
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = page "NPR TM ImportTicketsArchive";
                RunPageLink = JobId = field(JobId);
                Image = ImportCodes;
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
        }
    }

}