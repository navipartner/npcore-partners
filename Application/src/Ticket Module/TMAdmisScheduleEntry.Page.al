page 6060122 "NPR TM Admis. Schedule Entry"
{
    Caption = 'Admission Schedule Entry';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Admis. Schedule Entry";
    UsageCategory = Lists;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    PromotedActionCategories = 'New,Process,Report,Navigate';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("External Schedule Entry No."; Rec."External Schedule Entry No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Schedule Entry No. field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Schedule Code"; Rec."Schedule Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Schedule Code field';
                }
                field(Cancelled; Rec.Cancelled)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Cancelled field';
                }
                field("Admission Start Date"; Rec."Admission Start Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Start Date field';
                }
                field("Admission Start Time"; Rec."Admission Start Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Start Time field';
                }
                field("Event Duration"; Rec."Event Duration")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Event Duration field';
                }
                field("Admission End Date"; Rec."Admission End Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission End Date field';
                }
                field("Admission End Time"; Rec."Admission End Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission End Time field';
                }
                field("Admission Is"; Rec."Admission Is")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Is field';
                }
                field("Visibility On Web"; Rec."Visibility On Web")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Visibility On Web field';
                }
                field("Regenerate With"; Rec."Regenerate With")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Regenerate With field';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reason Code field';
                }
                field("Initial Entry"; Rec."Initial Entry")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Initial Entry field';
                }
                field("Open Reservations"; Rec."Open Reservations")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Open Reservations field';
                }
                field("Open Admitted"; Rec."Open Admitted")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Open Admitted field';
                }
                field(Departed; Rec.Departed)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Departed field';
                }
                field("Max Capacity Per Sch. Entry"; Rec."Max Capacity Per Sch. Entry")
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
                field("Event Arrival From Time"; Rec."Event Arrival From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Arrival From Time field';
                }
                field("Event Arrival Until Time"; Rec."Event Arrival Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Arrival Until Time field';
                }
                field("Sales From Date"; Rec."Sales From Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Date field';
                }
                field("Sales From Time"; Rec."Sales From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Time field';
                }
                field("Sales Until Date"; Rec."Sales Until Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Date field';
                }
                field("Sales Until Time"; Rec."Sales Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Time field';
                }
                field("Allocation By"; Rec."Allocation By")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Allocation By field';
                }
                field("Waiting List Queue"; Rec."Waiting List Queue")
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
        area(navigation)
        {
            action("Show Ticket Holder List")
            {
                ToolTip = 'Show list of ticket holders for this time entry.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Show Ticket Holder List';
                Image = WIPLedger;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
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
                Image = Open;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "NPR TM Ticket Waiting List";
                RunPageLink = "External Schedule Entry No." = FIELD("External Schedule Entry No.");

            }
            action("Create Ticket Holder List")
            {
                ToolTip = 'Create a list of ticket holders for this time entry.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Create Ticket Holder List';
                Image = WIPEntries;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    NotifyTicketHolders();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ConcurrentCapacityText := CalculateConcurrentCapacity(Rec);
    end;

    trigger OnOpenPage()
    begin
        Rec.SetFilter(Cancelled, '=%1', false);
    end;

    var
        ConcurrentCapacityText: Text[20];

    local procedure NotifyTicketHolders()
    var
        AdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
        TicketParticipantWks: Record "NPR TM Ticket Particpt. Wks.";
    begin

        AdmissionSchManagement.CreateNotificationList(Rec."Entry No.");

        TicketParticipantWks.FilterGroup(6);
        TicketParticipantWks.Reset();
        TicketParticipantWks.SetCurrentKey("Applies To Schedule Entry No.");
        TicketParticipantWks.SetFilter("Applies To Schedule Entry No.", '=%1', Rec."Entry No.");
        TicketParticipantWks.FilterGroup(0);

        PAGE.Run(0, TicketParticipantWks);
    end;

    local procedure CalculateConcurrentCapacity(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry") ResultText: Text[30]
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Actual: Integer;
        MaxCapacity: Integer;
    begin

        ResultText := '-/-';
        if (TicketManagement.CalculateConcurrentCapacity(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", AdmissionScheduleEntry."Admission Start Date", Actual, MaxCapacity)) then
            ResultText := StrSubstNo('%1/%2', Actual, MaxCapacity);
    end;
}

