page 6060122 "TM Admission Schedule Entry"
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

    Caption = 'Admission Schedule Entry';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "TM Admission Schedule Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                    Editable = false;
                }
                field("External Schedule Entry No.";"External Schedule Entry No.")
                {
                    Editable = false;
                }
                field("Admission Code";"Admission Code")
                {
                    Editable = false;
                }
                field("Schedule Code";"Schedule Code")
                {
                    Editable = false;
                }
                field(Cancelled;Cancelled)
                {
                    Editable = false;
                    Visible = false;
                }
                field("Admission Start Date";"Admission Start Date")
                {
                    Editable = false;
                }
                field("Admission Start Time";"Admission Start Time")
                {
                    Editable = false;
                }
                field("Event Duration";"Event Duration")
                {
                    Editable = false;
                }
                field("Admission End Date";"Admission End Date")
                {
                    Editable = false;
                }
                field("Admission End Time";"Admission End Time")
                {
                    Editable = false;
                }
                field("Admission Is";"Admission Is")
                {
                }
                field("Visibility On Web";"Visibility On Web")
                {
                }
                field("Regenerate With";"Regenerate With")
                {
                }
                field("Reason Code";"Reason Code")
                {
                    Visible = false;
                }
                field("Open Reservations";"Open Reservations")
                {
                    Editable = false;
                }
                field("Open Admitted";"Open Admitted")
                {
                    Editable = false;
                }
                field(Departed;Departed)
                {
                    Editable = false;
                }
                field("Max Capacity Per Sch. Entry";"Max Capacity Per Sch. Entry")
                {
                }
                field("Event Arrival From Time";"Event Arrival From Time")
                {
                }
                field("Event Arrival Until Time";"Event Arrival Until Time")
                {
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

                trigger OnAction()
                begin
                    NotifyTicketHolders ();
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
                RunObject = Page "TM Ticket Participant Wks.";
                RunPageLink = "Applies To Schedule Entry No."=FIELD("Entry No.");
                RunPageView = SORTING("Applies To Schedule Entry No.")
                              ORDER(Ascending);
            }
        }
    }

    trigger OnOpenPage()
    begin

        //-+TM1.19 [266768]
        Rec.SetFilter (Cancelled, '=%1', false);
    end;

    local procedure NotifyTicketHolders()
    var
        AdmissionSchManagement: Codeunit "TM Admission Sch. Management";
        TicketParticipantWks: Record "TM Ticket Participant Wks.";
    begin

        AdmissionSchManagement.CreateNotificationList ("Entry No.");

        TicketParticipantWks.FilterGroup (6);
        TicketParticipantWks.Reset ();
        TicketParticipantWks.SetCurrentKey ("Applies To Schedule Entry No.");
        TicketParticipantWks.SetFilter ("Applies To Schedule Entry No.", '=%1', "Entry No.");
        TicketParticipantWks.FilterGroup (0);

        PAGE.Run (0, TicketParticipantWks);
    end;
}

