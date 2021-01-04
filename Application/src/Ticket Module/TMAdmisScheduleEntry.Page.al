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
    UsageCategory = Lists;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("External Schedule Entry No."; "External Schedule Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Schedule Entry No. field';
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Schedule Code"; "Schedule Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Schedule Code field';
                }
                field(Cancelled; Cancelled)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Cancelled field';
                }
                field("Admission Start Date"; "Admission Start Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Start Date field';
                }
                field("Admission Start Time"; "Admission Start Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Start Time field';
                }
                field("Event Duration"; "Event Duration")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Event Duration field';
                }
                field("Admission End Date"; "Admission End Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission End Date field';
                }
                field("Admission End Time"; "Admission End Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission End Time field';
                }
                field("Admission Is"; "Admission Is")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Is field';
                }
                field("Visibility On Web"; "Visibility On Web")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Visibility On Web field';
                }
                field("Regenerate With"; "Regenerate With")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Regenerate With field';
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reason Code field';
                }
                field("Initial Entry"; "Initial Entry")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Initial Entry field';
                }
                field("Open Reservations"; "Open Reservations")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Open Reservations field';
                }
                field("Open Admitted"; "Open Admitted")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Open Admitted field';
                }
                field(Departed; Departed)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Departed field';
                }
                field("Max Capacity Per Sch. Entry"; "Max Capacity Per Sch. Entry")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Max Capacity Per Sch. Entry field';
                }
                field(ConcurrentCapacityText; ConcurrentCapacityText)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Concurrent Capacity';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Concurrent Capacity field';
                }
                field("Event Arrival From Time"; "Event Arrival From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Arrival From Time field';
                }
                field("Event Arrival Until Time"; "Event Arrival Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Arrival Until Time field';
                }
                field("Sales From Date"; "Sales From Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Date field';
                }
                field("Sales From Time"; "Sales From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Time field';
                }
                field("Sales Until Date"; "Sales Until Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Date field';
                }
                field("Sales Until Time"; "Sales Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Time field';
                }
                field("Allocation By"; "Allocation By")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Allocation By field';
                }
                field("Waiting List Queue"; "Waiting List Queue")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Waiting List Queue field';
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
                ToolTip = 'Create a list of ticket holders for this time entry.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Create Ticketholders List';
                Ellipsis = true;
                Image = WIPEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;


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
                ToolTip = 'Show list of ticket holders for this time entry.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Show Ticketholder List';
                Ellipsis = true;
                Image = WIPLedger;
                RunObject = Page "NPR TM Ticket Particpt. Wks.";
                RunPageLink = "Applies To Schedule Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Applies To Schedule Entry No.")
                              ORDER(Ascending);

            }
            action("Waiting List")
            {
                ToolTip = 'Navigate to Waiting List';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Waiting List';
                Ellipsis = true;
                Image = Open;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR TM Ticket Waiting List";
                RunPageLink = "External Schedule Entry No." = FIELD("External Schedule Entry No.");

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

