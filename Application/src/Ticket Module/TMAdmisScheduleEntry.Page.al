page 6060122 "NPR TM Admis. Schedule Entry"
{
    Extensible = False;
    Caption = 'Admission Schedule Entry';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Admis. Schedule Entry";
    UsageCategory = Lists;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    PromotedActionCategories = 'New,Process,Report,Navigate';
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
                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        NewAdmissionIs: Option;
                    begin
                        CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                        NewAdmissionIs := Rec."Admission Is";
                        if (AdmissionScheduleEntry.FindSet(true)) then begin
                            AdmissionScheduleEntry.ModifyAll("Admission Is", NewAdmissionIs);
                            AdmissionScheduleEntry.ModifyAll("Regenerate With", AdmissionScheduleEntry."Regenerate With"::MANUAL);
                        end;
                        CurrPage.Update(false);
                    end;
                }
                field("Visibility On Web"; Rec."Visibility On Web")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Visibility On Web field';
                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        NewVisibilityOnWeb: Option;
                    begin
                        CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                        NewVisibilityOnWeb := Rec."Visibility On Web";
                        if (AdmissionScheduleEntry.FindSet(true)) then begin
                            AdmissionScheduleEntry.ModifyAll("Visibility On Web", NewVisibilityOnWeb);
                            AdmissionScheduleEntry.ModifyAll("Regenerate With", AdmissionScheduleEntry."Regenerate With"::MANUAL);
                        end;
                        CurrPage.Update(false);
                    end;
                }
                field("Regenerate With"; Rec."Regenerate With")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Regenerate With field';
                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        NewRegenerateWith: Option;
                    begin
                        CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                        NewRegenerateWith := Rec."Regenerate With";
                        if (AdmissionScheduleEntry.FindSet(true)) then
                            AdmissionScheduleEntry.ModifyAll("Regenerate With", NewRegenerateWith);
                        CurrPage.Update(false);
                    end;
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
                    ToolTip = 'Specifies the value of the Initial Entry field. This includes paid entries only.';
                }
                field("Initial Entry (All)"; Rec."Initial Entry (All)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Initial Entry (All) field. This is a temporary number since unpaid requests are listed. This includes f.ex. tour tickets and incomplete ticket web requests.';
                    Visible = false;
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
                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        NewCapacity: Integer;
                    begin
                        CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                        NewCapacity := Rec."Max Capacity Per Sch. Entry";
                        if (AdmissionScheduleEntry.FindSet(true)) then begin
                            AdmissionScheduleEntry.ModifyAll("Max Capacity Per Sch. Entry", NewCapacity);
                            AdmissionScheduleEntry.ModifyAll("Regenerate With", AdmissionScheduleEntry."Regenerate With"::MANUAL);
                        end;
                        CurrPage.Update(false);
                    end;
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
                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        NewFromTime: Time;
                    begin
                        CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                        NewFromTime := Rec."Event Arrival From Time";
                        if (AdmissionScheduleEntry.FindSet(true)) then begin
                            AdmissionScheduleEntry.ModifyAll("Event Arrival From Time", NewFromTime);
                            AdmissionScheduleEntry.ModifyAll("Regenerate With", AdmissionScheduleEntry."Regenerate With"::MANUAL);
                        end;
                        CurrPage.Update(false);
                    end;
                }
                field("Event Arrival Until Time"; Rec."Event Arrival Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Arrival Until Time field';
                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        NewUntilTime: Time;
                    begin
                        CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                        NewUntilTime := Rec."Event Arrival Until Time";
                        if (AdmissionScheduleEntry.FindSet(true)) then begin
                            AdmissionScheduleEntry.ModifyAll("Event Arrival Until Time", NewUntilTime);
                            AdmissionScheduleEntry.ModifyAll("Regenerate With", AdmissionScheduleEntry."Regenerate With"::MANUAL);
                        end;
                        CurrPage.Update(false);
                    end;
                }
                field("Sales From Date"; Rec."Sales From Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Date field';
                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        NewFromDate: Date;
                    begin
                        CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                        NewFromDate := Rec."Sales From Date";
                        if (AdmissionScheduleEntry.FindSet(true)) then begin
                            AdmissionScheduleEntry.ModifyAll("Sales From Date", NewFromDate);
                            AdmissionScheduleEntry.ModifyAll("Regenerate With", AdmissionScheduleEntry."Regenerate With"::MANUAL);
                        end;
                        CurrPage.Update(false);
                    end;
                }
                field("Sales From Time"; Rec."Sales From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Time field';
                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        NewFromTime: Time;
                    begin
                        CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                        NewFromTime := Rec."Sales From Time";
                        if (AdmissionScheduleEntry.FindSet(true)) then begin
                            AdmissionScheduleEntry.ModifyAll("Sales From Time", NewFromTime);
                            AdmissionScheduleEntry.ModifyAll("Regenerate With", AdmissionScheduleEntry."Regenerate With"::MANUAL);
                        end;
                        CurrPage.Update(false);
                    end;
                }
                field("Sales Until Date"; Rec."Sales Until Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Date field';
                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        NewFromDate: Date;
                    begin
                        CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                        NewFromDate := Rec."Sales Until Date";
                        if (AdmissionScheduleEntry.FindSet(true)) then begin
                            AdmissionScheduleEntry.ModifyAll("Sales Until Date", NewFromDate);
                            AdmissionScheduleEntry.ModifyAll("Regenerate With", AdmissionScheduleEntry."Regenerate With"::MANUAL);
                        end;
                        CurrPage.Update(false);
                    end;
                }
                field("Sales Until Time"; Rec."Sales Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Time field';
                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        NewUntilTime: Time;
                    begin
                        CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                        NewUntilTime := Rec."Sales Until Time";
                        if (AdmissionScheduleEntry.FindSet(true)) then begin
                            AdmissionScheduleEntry.ModifyAll("Sales Until Time", NewUntilTime);
                            AdmissionScheduleEntry.ModifyAll("Regenerate With", AdmissionScheduleEntry."Regenerate With"::MANUAL);
                        end;
                        CurrPage.Update(false);
                    end;
                }
                field("Allocation By"; Rec."Allocation By")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Allocation By field';
                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        NewAllocationBy: Option;
                    begin
                        CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                        NewAllocationBy := Rec."Allocation By";
                        if (AdmissionScheduleEntry.FindSet(true)) then begin
                            AdmissionScheduleEntry.ModifyAll("Allocation By", NewAllocationBy);
                            AdmissionScheduleEntry.ModifyAll("Regenerate With", AdmissionScheduleEntry."Regenerate With"::MANUAL);
                        end;
                        CurrPage.Update(false);
                    end;
                }
                field(DynamicPriceProfileCode; Rec."Dynamic Price Profile Code")
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Dynamic Price Profile Code field';
                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        NewDynamicPriceProfileCode: Code[10];
                    begin
                        CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                        NewDynamicPriceProfileCode := Rec."Dynamic Price Profile Code";
                        if (AdmissionScheduleEntry.FindSet(true)) then begin
                            AdmissionScheduleEntry.ModifyAll("Dynamic Price Profile Code", NewDynamicPriceProfileCode);
                            AdmissionScheduleEntry.ModifyAll("Regenerate With", AdmissionScheduleEntry."Regenerate With"::MANUAL);
                        end;
                        CurrPage.Update(false);
                    end;
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
        area(Processing)
        {
            action(Reschedule)
            {
                Caption = 'Replan Reservations';
                ToolTip = 'Shows list of open reservation for selected time slot and allows to move them to a different time slot.';
                ApplicationArea = NPRTicketAdvanced;
                Image = Replan;
                Scope = Repeater;
                Promoted = false;
                trigger OnAction()
                begin
                    ReplanReservations();
                    CurrPage.Update(false);
                end;
            }
        }
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
                Scope = Repeater;
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
            action("List of Attendees")
            {
                ToolTip = 'Create a list of attendees for this time entry.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Attendee List';
                Image = Approval;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Category4;
                Scope = Repeater;
                trigger OnAction()
                var
                    AttendeePage: Page "NPR TM Attendee List";
                    AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                begin
                    CurrPage.SetSelectionFilter(AdmissionScheduleEntry);
                    if (AdmissionScheduleEntry.FindSet()) then begin
                        repeat
                            AttendeePage.LoadPageBuffer(AdmissionScheduleEntry);
                        until (AdmissionScheduleEntry.Next() = 0);
                        AttendeePage.Run();
                    end;
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
        ConcurrentCapacityText: Text[30];

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
        ResultLbl: Label '%1/%2', Locked = true;
    begin

        ResultText := '-/-';
        if (TicketManagement.CalculateConcurrentCapacity(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", AdmissionScheduleEntry."Admission Start Date", Actual, MaxCapacity)) then
            ResultText := StrSubstNo(ResultLbl, Actual, MaxCapacity);
    end;

    local procedure ReplanReservations()
    var
        ReplanReservationPage: Page "NPR TM Replan Schedule";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        Commit();
        DetailedTicketAccessEntry.FilterGroup(180);
        DetailedTicketAccessEntry.SetFilter("External Adm. Sch. Entry No.", '=%1', Rec."External Schedule Entry No.");
        DetailedTicketAccessEntry.SetFilter(Type, '=%1', DetailedTicketAccessEntry.Type::RESERVATION);
        DetailedTicketAccessEntry.SetFilter(Open, '=%1', true);
        DetailedTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
        DetailedTicketAccessEntry.FilterGroup(0);

        ReplanReservationPage.SetAdmissionCode(Rec."Admission Code");
        ReplanReservationPage.SetTableView(DetailedTicketAccessEntry);
        ReplanReservationPage.RunModal();
    end;
}

