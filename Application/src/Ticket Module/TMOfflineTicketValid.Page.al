page 6060093 "NPR TM Offline Ticket Valid."
{
    Extensible = False;
    Caption = 'Offline Ticket Validation';
    PageType = List;
    SourceTable = "NPR TM Offline Ticket Valid.";
    UsageCategory = Tasks;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Ticket Reference Type"; Rec."Ticket Reference Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Ticket Reference Type field';
                }
                field("Ticket Reference No."; Rec."Ticket Reference No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Reference No. field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Ticket: Record "NPR TM Ticket";
                        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
                    begin
                        Ticket.SetRange("External Ticket No.", Rec."Ticket Reference No.");
                        if Ticket.FindFirst() then begin
                            TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
                            if PAGE.RunModal(0, TicketAccessEntry) = ACTION::LookupOK then
                                Rec."Admission Code" := TicketAccessEntry."Admission Code";
                        end;
                    end;
                }
                field("Member Reference Type"; Rec."Member Reference Type")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Member Reference Type field';
                }
                field("Member Reference No."; Rec."Member Reference No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Member Reference No. field';
                }
                field("Event Type"; Rec."Event Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Type field';
                }
                field("Event Date"; Rec."Event Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Date field';

                    trigger OnValidate()
                    begin
                        OfflineTicketValidationRec.Reset();
                        OfflineTicketValidationRec.CopyFilters(Rec);
                        OfflineTicketValidationRec.SetFilter("Import Reference No.", '=%1', Rec."Import Reference No.");
                        OfflineTicketValidationRec.SetFilter("Process Status", '=%1', Rec."Process Status"::UNHANDLED);
                        if (Rec."Event Date" <> xRec."Event Date") then
                            if (Confirm(APPLY_ON_ALL, true, Rec."Event Date", OfflineTicketValidationRec.Count, Rec."Import Reference No.")) then begin
                                OfflineTicketValidationRec.ModifyAll("Event Date", Rec."Event Date");
                                CurrPage.Update(false);
                            end;
                    end;
                }
                field("Event Time"; Rec."Event Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Time field';

                    trigger OnValidate()
                    begin
                        OfflineTicketValidationRec.Reset();
                        OfflineTicketValidationRec.CopyFilters(Rec);
                        OfflineTicketValidationRec.SetFilter("Import Reference No.", '=%1', Rec."Import Reference No.");
                        OfflineTicketValidationRec.SetFilter("Process Status", '=%1', Rec."Process Status"::UNHANDLED);
                        if (Rec."Event Time" <> xRec."Event Time") then
                            if (Confirm(APPLY_ON_ALL, true, Rec."Event Time", OfflineTicketValidationRec.Count, Rec."Import Reference No.")) then begin
                                OfflineTicketValidationRec.ModifyAll("Event Time", Rec."Event Time");
                                CurrPage.Update(false);
                            end;
                    end;
                }
                field("Process Status"; Rec."Process Status")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Process Status field';

                    trigger OnValidate()
                    begin
                        OfflineTicketValidationRec.Reset();
                        OfflineTicketValidationRec.CopyFilters(Rec);
                        OfflineTicketValidationRec.SetFilter("Import Reference No.", '=%1', Rec."Import Reference No.");
                        if (Rec."Process Status" <> xRec."Process Status") then
                            if (Confirm(APPLY_ON_ALL, true, Rec."Process Status", OfflineTicketValidationRec.Count, Rec."Import Reference No.")) then begin
                                OfflineTicketValidationRec.ModifyAll("Process Status", Rec."Process Status");
                                CurrPage.Update(false);
                            end;
                    end;
                }
                field("Process Response Text"; Rec."Process Response Text")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Process Response Text field';
                }
                field("Import Reference No."; Rec."Import Reference No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Import Reference No. field';
                }
                field("Imported At"; Rec."Imported At")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Imported At field';
                }
                field("Import Reference Name"; Rec."Import Reference Name")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Import Reference Name field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Process Entry")
            {
                ToolTip = 'Generate admission entries for this ticket.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Process Entry';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    OfflineTicketValidation.ProcessEntry(Rec."Entry No.");
                    CurrPage.Update(false);
                end;
            }
            action("Process Batch")
            {
                ToolTip = 'Generate admission entries for all tickets for the batch of tickets.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Process Batch';
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    OfflineTicketValidation.ProcessImportBatch(Rec."Import Reference No.");
                    CurrPage.Update(false);
                end;
            }

            action(ImportFile)
            {
                ToolTip = 'Import a file containing ticket data.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Import File';
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Randomize();
                    OfflineTicketValidation.ImportOfflineValidationFile(Random(Power(2, 31) - 1));
                    CurrPage.Update(false);
                end;
            }

        }
        area(navigation)
        {
            action(Ticket)
            {
                ToolTip = 'Navigate to Ticket List';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket List";
                RunPageLink = "External Ticket No." = FIELD("Ticket Reference No.");
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetFilter("Process Status", '<>%1', Rec."Process Status"::VALID);
    end;

    var
        OfflineTicketValidationRec: Record "NPR TM Offline Ticket Valid.";
        OfflineTicketValidation: Codeunit "NPR TM OfflineTicketValidBL";
        APPLY_ON_ALL: Label 'Apply %1 on all unhandled lines (%2) in batch %3?';
}

