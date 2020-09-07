page 6060123 "NPR TM Det. Ticket AccessEntry"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.09/TSA/20160311  CASE 236742 UX Improvemets
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.17/NPKNAV/20161026  CASE 256152 Transport TM1.17
    // TM1.28/TSA /20180130 CASE 301222 Added button to un-consume an item
    // TM1.48/TSA /20200727 CASE 416096 Changed properties and name on Schedule Entry button, added ticket request button

    Caption = 'Detailed Ticket Access Entry';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Det. Ticket AccessEntry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Ticket No."; "Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Ticket Access Entry No."; "Ticket Access Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("External Adm. Sch. Entry No."; "External Adm. Sch. Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Scheduled Time"; ScheduledTime)
                {
                    ApplicationArea = All;
                    Caption = 'Scheduled Time';
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Closed By Entry No."; "Closed By Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                }
                field("Sales Channel No."; "Sales Channel No.")
                {
                    ApplicationArea = All;
                }
                field("Created Datetime"; "Created Datetime")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Admission Schedule Entry")
            {
                Caption = 'Admission Schedule Entry';
                Ellipsis = true;
                Image = WorkCenterLoad;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Admis. Schedule Entry";
                RunPageLink = "External Schedule Entry No." = FIELD("External Adm. Sch. Entry No.");
                ApplicationArea=All;
            }
            action("Ticket Request")
            {
                Caption = 'Ticket Request';
                Ellipsis = true;
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                begin
                    //-TM1.48 [416096]
                    OpenTicketRequest(Rec);
                    //+TM1.48 [416096]
                end;
            }
        }
        area(processing)
        {
            action("Unconsume Item")
            {
                Caption = 'Unconsume Item';
                Image = ConsumptionJournal;
                ApplicationArea=All;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;

                trigger OnAction()
                begin

                    UnconsumeItem();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        ScheduledTime := '';
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', "External Adm. Sch. Entry No.");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (AdmissionScheduleEntry.FindFirst()) then
            ScheduledTime := StrSubstNo('%1 %2', AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
    end;

    var
        ScheduledTime: Text[30];

    local procedure UnconsumeItem()
    begin

        TestField(Type, Type::CONSUMED);
        if (Type = Type::CONSUMED) then
            Delete;
    end;

    local procedure OpenTicketRequest(DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry")
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequest: Page "NPR TM Ticket Request";
    begin

        //-TM1.48 [416096]
        Ticket.Get(DetTicketAccessEntry."Ticket No.");
        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketRequest.SetTableView(TicketReservationRequest);
        TicketRequest.Run();
        //+TM1.48 [416096]
    end;
}

