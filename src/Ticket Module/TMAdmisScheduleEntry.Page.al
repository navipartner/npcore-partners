page 6060122 "NPR TM Admis. Schedule Entry"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.09/TSA/20160310  CASE 236742 UX improvements
    // TM1.11/TSA/20160404  CASE 232250 Added new fields 47 and 48
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Caption
    // TM1.16/TSA/20160714  CASE 245004 Added NotifyTicketholder
    // TM1.17/NPKNAV/20161026  CASE 256205 Transport TM1.17
    // TM1.19/TSA/20170220 CASE 266768 Added default filter to not show blocked entries
    // TM1.21/ANEN /20170410 CASE 271405 Added fld. [Explicit Cancel Cap. Change]
    // TM1.23/NPKNAV/20170728  CASE 280612 Transport TM1.23 - 28 July 2017
    // TM1.24/NPKNAV/20170925  CASE 289293 Transport TM1.24 - 25 September 2017
    // TM1.28/TSA /20180221 CASE 306039 Added "Visibility On Web"
    // TM1.37/TSA/20180927  CASE 327324 Transport TM1.37 - 27 September 2018
    // TM1.39/TSA /20181102 CASE 334585 A control of type 'FlowFilter' is not allowed in a parent control of type 'Repeater'
    // TM1.45/TSA /20191204 CASE 378212 Added sales limitation fields
    // TM1.45/TSA /20191204 CASE 380754 Added Waiting list properties and actions
    // TM1.45/TSA /20200116 CASE 385922 Added Concurrency Capacity calculation field
    // TM1.48/TSA /20200702 CASE 409741 Added Initial Entry flowfield to page

    Caption = 'Admission Schedule Entry';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Admis. Schedule Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("External Schedule Entry No."; "External Schedule Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Schedule Code"; "Schedule Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Cancelled; Cancelled)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Admission Start Date"; "Admission Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Admission Start Time"; "Admission Start Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Event Duration"; "Event Duration")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Admission End Date"; "Admission End Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Admission End Time"; "Admission End Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Admission Is"; "Admission Is")
                {
                    ApplicationArea = All;
                }
                field("Visibility On Web"; "Visibility On Web")
                {
                    ApplicationArea = All;
                }
                field("Regenerate With"; "Regenerate With")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Initial Entry"; "Initial Entry")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Open Reservations"; "Open Reservations")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Open Admitted"; "Open Admitted")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Departed; Departed)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Max Capacity Per Sch. Entry"; "Max Capacity Per Sch. Entry")
                {
                    ApplicationArea = All;
                }
                field(ConcurrentCapacityText; ConcurrentCapacityText)
                {
                    ApplicationArea = All;
                    Caption = 'Concurrent Capacity';
                    Editable = false;
                }
                field("Event Arrival From Time"; "Event Arrival From Time")
                {
                    ApplicationArea = All;
                }
                field("Event Arrival Until Time"; "Event Arrival Until Time")
                {
                    ApplicationArea = All;
                }
                field("Sales From Date"; "Sales From Date")
                {
                    ApplicationArea = All;
                }
                field("Sales From Time"; "Sales From Time")
                {
                    ApplicationArea = All;
                }
                field("Sales Until Date"; "Sales Until Date")
                {
                    ApplicationArea = All;
                }
                field("Sales Until Time"; "Sales Until Time")
                {
                    ApplicationArea = All;
                }
                field("Allocation By"; "Allocation By")
                {
                    ApplicationArea = All;
                }
                field("Waiting List Queue"; "Waiting List Queue")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Ticketholders List")
            {
                Caption = 'Create Ticketholders List';
                Ellipsis = true;
                Image = WIPEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    NotifyTicketHolders();
                end;
            }
        }
        area(navigation)
        {
            action("Show Ticketholder List")
            {
                Caption = 'Show Ticketholder List';
                Ellipsis = true;
                Image = WIPLedger;
                RunObject = Page "NPR TM Ticket Particpt. Wks.";
                RunPageLink = "Applies To Schedule Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Applies To Schedule Entry No.")
                              ORDER(Ascending);
                ApplicationArea = All;
            }
            action("Waiting List")
            {
                Caption = 'Waiting List';
                Ellipsis = true;
                Image = Open;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR TM Ticket Waiting List";
                RunPageLink = "External Schedule Entry No." = FIELD("External Schedule Entry No.");
                ApplicationArea = All;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        ConcurrentCapacityText := CalculateConcurrentCapacity(Rec);
    end;

    trigger OnOpenPage()
    begin

        //-+TM1.19 [266768]
        Rec.SetFilter(Cancelled, '=%1', false);
    end;

    var
        ConcurrentCapacityText: Text[20];

    local procedure NotifyTicketHolders()
    var
        AdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
        TicketParticipantWks: Record "NPR TM Ticket Particpt. Wks.";
    begin

        AdmissionSchManagement.CreateNotificationList("Entry No.");

        TicketParticipantWks.FilterGroup(6);
        TicketParticipantWks.Reset();
        TicketParticipantWks.SetCurrentKey("Applies To Schedule Entry No.");
        TicketParticipantWks.SetFilter("Applies To Schedule Entry No.", '=%1', "Entry No.");
        TicketParticipantWks.FilterGroup(0);

        PAGE.Run(0, TicketParticipantWks);
    end;

    local procedure CalculateConcurrentCapacity(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry") ResultText: Text[30]
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Actual: Integer;
        MaxCapacity: Integer;
    begin

        //-TM1.45 [385922]
        ResultText := '-/-';
        with AdmissionScheduleEntry do
            if (TicketManagement.CalculateConcurrentCapacity("Admission Code", "Schedule Code", "Admission Start Date", Actual, MaxCapacity)) then
                ResultText := StrSubstNo('%1/%2', Actual, MaxCapacity);

        //+TM1.45 [385922]
    end;
}

