page 6060093 "NPR TM Offline Ticket Valid."
{
    // TM1.22/NPKNAV/20170612  CASE 278142 Transport T0007 - 12 June 2017
    // TM90.1.46/TSA /20200203 CASE 383196 Added mass modify on event date and event time

    Caption = 'Offline Ticket Validation';
    PageType = List;
    SourceTable = "NPR TM Offline Ticket Valid.";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Ticket Reference Type"; "Ticket Reference Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Ticket Reference No."; "Ticket Reference No.")
                {
                    ApplicationArea = All;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                }
                field("Member Reference Type"; "Member Reference Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Member Reference No."; "Member Reference No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Event Type"; "Event Type")
                {
                    ApplicationArea = All;
                }
                field("Event Date"; "Event Date")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin

                        //-TM90.1.46 [383196]
                        OfflineTicketValidationRec.Reset();
                        OfflineTicketValidationRec.CopyFilters(Rec);
                        OfflineTicketValidationRec.SetFilter("Import Reference No.", '=%1', Rec."Import Reference No.");
                        OfflineTicketValidationRec.SetFilter("Process Status", '=%1', Rec."Process Status"::UNHANDLED);
                        if (Rec."Event Date" <> xRec."Event Date") then
                            if (Confirm(APPLY_ON_ALL, true, Rec."Event Date", OfflineTicketValidationRec.Count, Rec."Import Reference No.")) then begin
                                OfflineTicketValidationRec.ModifyAll("Event Date", Rec."Event Date");
                                CurrPage.Update(false);
                            end;
                        //+TM90.1.46 [383196]
                    end;
                }
                field("Event Time"; "Event Time")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin

                        //-TM90.1.46 [383196]
                        OfflineTicketValidationRec.Reset();
                        OfflineTicketValidationRec.CopyFilters(Rec);
                        OfflineTicketValidationRec.SetFilter("Import Reference No.", '=%1', Rec."Import Reference No.");
                        OfflineTicketValidationRec.SetFilter("Process Status", '=%1', Rec."Process Status"::UNHANDLED);
                        if (Rec."Event Time" <> xRec."Event Time") then
                            if (Confirm(APPLY_ON_ALL, true, Rec."Event Time", OfflineTicketValidationRec.Count, Rec."Import Reference No.")) then begin
                                OfflineTicketValidationRec.ModifyAll("Event Time", Rec."Event Time");
                                CurrPage.Update(false);
                            end;
                        //+TM90.1.46 [383196]
                    end;
                }
                field("Process Status"; "Process Status")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin

                        //-TM90.1.46 [383196]
                        OfflineTicketValidationRec.Reset();
                        OfflineTicketValidationRec.CopyFilters(Rec);
                        OfflineTicketValidationRec.SetFilter("Import Reference No.", '=%1', Rec."Import Reference No.");
                        if (Rec."Process Status" <> xRec."Process Status") then
                            if (Confirm(APPLY_ON_ALL, true, Rec."Process Status", OfflineTicketValidationRec.Count, Rec."Import Reference No.")) then begin
                                OfflineTicketValidationRec.ModifyAll("Process Status", Rec."Process Status");
                                CurrPage.Update(false);
                            end;
                        //+TM90.1.46 [383196]
                    end;
                }
                field("Process Response Text"; "Process Response Text")
                {
                    ApplicationArea = All;
                }
                field("Import Reference No."; "Import Reference No.")
                {
                    ApplicationArea = All;
                }
                field("Imported At"; "Imported At")
                {
                    ApplicationArea = All;
                }
                field("Import Reference Name"; "Import Reference Name")
                {
                    ApplicationArea = All;
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
                Caption = 'Process Entry';
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                begin

                    OfflineTicketValidation.ProcessEntry("Entry No.");
                    CurrPage.Update(false);
                end;
            }
            action("Process Batch")
            {
                Caption = 'Process Batch';
                Image = PostBatch;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                begin

                    OfflineTicketValidation.ProcessImportBatch("Import Reference No.");
                    CurrPage.Update(false);
                end;
            }
        }
        area(navigation)
        {
            action(Ticket)
            {
                Caption = 'Ticket';
                Image = Navigate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket List";
                RunPageLink = "External Ticket No." = FIELD("Ticket Reference No.");
                ApplicationArea=All;
            }
        }
    }

    trigger OnOpenPage()
    begin

        SetFilter("Process Status", '<>%1', "Process Status"::VALID);
    end;

    var
        OfflineTicketValidationRec: Record "NPR TM Offline Ticket Valid.";
        OfflineTicketValidation: Codeunit "NPR TM Offline Ticket Valid.";
        APPLY_ON_ALL: Label 'Apply %1 on all unhandled lines (%2) in batch %3?';
}

