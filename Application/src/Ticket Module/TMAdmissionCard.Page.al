page 6150765 "NPR TM Admission Card"
{
    Extensible = False;
    Caption = 'Ticket Admissions Card';
    PageType = Card;
    SourceTable = "NPR TM Admission";
    UsageCategory = None;
    PromotedActionCategories = 'New,Process,Report,Navigate';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the code of the specific admission.';
                }
                field(Type; Rec."Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies whether the admission is a location or an event.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies useful information about the admission. The value you enter will be suggested as the default admission description when admission is used on the Ticket BOM.';
                }
                field("Location Admission Code"; Rec."Location Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Location Admission Code field';
                }
                field(CategoryCode; Rec.Category)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Category Code field.';
                }
                field(AdmissionTimeZone; _AdmissionTimeZoneDescription)
                {
                    Caption = 'Admission Time Zone';
                    ToolTip = 'Specifies the value of the Admission Time Zone field';
                    ApplicationArea = NPRTicketAdvanced;
                    Editable = false;
                    trigger OnAssistEdit()
                    var
                        TimeZone: Record "Time Zone";
#if BC17 or BC18
                        TimeZones: Page "Time Zones";
#else
                        TimeZones: Page "Time Zones Lookup";
#endif
                        PageAction: Action;
                    begin
                        TimeZones.LookupMode(true);
                        PageAction := TimeZones.RunModal();
                        if (not (PageAction = Action::LookupOK)) then
                            exit;

                        if (not CurrPage.Editable()) then
                            exit;

                        TimeZones.GetRecord(TimeZone);
                        Rec.TimeZoneNo := TimeZone."No.";
                        DisplayTimeZoneName(Rec.TimeZoneNo);

                        CurrPage.Update(true);
                    end;
                }
            }
            group(Capacity)
            {
                field("Capacity Limits By"; Rec."Capacity Limits By")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies how the maximum capacity is controlled.';
                    trigger OnValidate()
                    var
                        AdmSchLine: Record "NPR TM Admis. Schedule Lines";
                        ConfirmChange: Label 'Changing %1 will update all %2 for %3 %4';
                    begin
                        if ((Rec."Capacity Limits By" <> xRec."Capacity Limits By") and (Rec."Capacity Limits By" <> Rec."Capacity Limits By"::OVERRIDE)) then
                            if (not Confirm(ConfirmChange, true, Rec.FieldCaption("Capacity Limits By"), AdmSchLine.TableCaption(), Rec.FieldCaption("Admission Code"), Rec."Admission Code")) then
                                Error('');

                        _ManagedByAdmission := Rec."Capacity Limits By" = Rec."Capacity Limits By"::Admission;
                    end;
                }
                field("Default Schedule"; Rec."Default Schedule")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies how the assisted ticket sales process should select initial time slot.';
                }
                field("Dependency Code"; Rec."Dependency Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the rules which govern admission dependencies.';
                }
                field("Prebook Is Required"; Rec."Prebook Is Required")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies whether the entry is reservation-based or open.';
                    Editable = _ManagedByAdmission;
                }
                field("Max Capacity Per Sch. Entry"; Rec."Max Capacity Per Sch. Entry")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the maximum capacity of the admission.';
                    Editable = _ManagedByAdmission;
                }
                field("Capacity Control"; Rec."Capacity Control")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies whether it???s possible to sell an indefinite number of tickets, if the capacity is limited by the number of seats in the admission, or if the capacity is governed by the number of entries/the difference between the number of admitted and departed customers.';
                    Editable = _ManagedByAdmission;
                }
                field("Prebook From"; Rec."Prebook From")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies how far in advance the time slots will be generated for this admission. Ultimately it governs how far into the future a ticket for this admission can be sold.';
                    Editable = _ManagedByAdmission;
                }
                field("Event Arrival From Time"; Rec."Event Arrival From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Arrival From Time field';
                    Editable = _ManagedByAdmission;
                }
                field("Event Arrival Until Time"; Rec."Event Arrival Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Arrival Until Time field';
                    Editable = _ManagedByAdmission;
                }
            }
            group(Sales)
            {
                field("Sales From Date (Rel.)"; Rec."Sales From Date (Rel.)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Date (Rel.) field';
                    Editable = _ManagedByAdmission;
                }
                field("Sales From Time"; Rec."Sales From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Time field';
                    Editable = _ManagedByAdmission;
                }
                field("Sales Until Date (Rel.)"; Rec."Sales Until Date (Rel.)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Date (Rel.) field';
                    Editable = _ManagedByAdmission;
                }
                field("Sales Until Time"; Rec."Sales Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Time field';
                    Editable = _ManagedByAdmission;
                }
                field("Admission Base Calendar Code"; Rec."Admission Base Calendar Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The calendar defines exceptions to the general schedules and has the possibility to prevent sales for specific dates or holidays.';
                }
                field("AdmissionCustomized Calendar"; _CalendarManager.CustomizedChangesExist(Rec))
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Admission Customized Calendar';
                    Editable = false;
                    ToolTip = 'If a base calendar is added, you can select calendar variations in this column.';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord();
                        Rec.TestField("Admission Base Calendar Code");
                        _CalendarManager.ShowCustomizedCalendar(Rec);
                    end;
                }
                field("Ticket Base Calendar Code"; Rec."Ticket Base Calendar Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The calendar defines exceptions to the general schedules and has the possibility to prevent sales for specific dates or holidays.';
                }
                field("TicketCustomized Calendar"; _TmCalendarManager.TicketBomAdmissionChangesExist(Rec))
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Ticket Customized Calendar';
                    Editable = false;
                    ToolTip = 'If a base calendar is added, you can select calendar variations in this column.';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord();
                        Rec.TestField("Admission Base Calendar Code");
                        _TMCalendarManager.ShowTicketBomAdmissionCalendar(Rec);
                    end;
                }
                field("Waiting List Setup Code"; Rec."Waiting List Setup Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies conditions which need to be met for a waiting list to be created, and how the customers will be notified when they are able to buy tickets.';
                }
                field("Additional Experience Item No."; Rec."Additional Experience Item No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Additional Experience Item No. field. This Item will be used to post POS Line when adding additional experience to existing ticket.';
                }
                field("POS Schedule Selection Date F."; Rec."POS Schedule Selection Date F.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies a date formula to limit the range of possible dates for which a ticket can be sold. Used to make the selection process briefer on the POS.';
                }
            }
            group(Notifications)
            {
                field("Ticketholder Notification Type"; Rec."Ticketholder Notification Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies whether it???s required for ticketholders to state their phone number/email address when buying a ticket.';
                }
                field("Stakeholder (E-Mail/Phone No.)"; Rec."Stakeholder (E-Mail/Phone No.)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the email or phone number of the admission code owner.';
                }
                field("eTicket Type Code"; Rec."eTicket Type Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the eTicket Type Code field';
                }
            }
            group(Misc)
            {
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the SystemId field.';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.';
                }
            }
        }
        area(factboxes)
        {
            part(AdmissionImage; "NPR TM Admission Media")
            {
                Caption = 'Image';
                SubPageLink = "Admission Code" = FIELD("Admission Code");
                ApplicationArea = NPRTicketAdvanced;
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action("Ticket BOM")
            {
                ToolTip = 'Navigate to Ticket BOM.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Admission BOM';
                Image = BOM;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "NPR TM Ticket BOM";
                RunPageLink = "Admission Code" = FIELD("Admission Code");

            }
            action(Schedules)
            {
                ToolTip = 'Navigate to Schedules';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Schedules';
                Image = Workdays;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket Schedules";

            }
            action("Admission Schedules")
            {
                ToolTip = 'Navigate to Admission Schedules.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Admission Schedules';
                Image = CalendarWorkcenter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "NPR TM Admis. Schedule Lines";
                RunPageLink = "Admission Code" = FIELD("Admission Code");
            }
            action("Seating Setup")
            {
                ToolTip = 'Navigate to Seating Setup';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Seating Setup';
                Image = Segment;
                RunObject = Page "NPR TM Seating Setup";
                RunPageLink = "Admission Code" = FIELD("Admission Code");
            }
            action("Waiting List Setup")
            {
                ToolTip = 'Navigate to Waiting List Setup';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Waiting List Setup';
                Image = Open;
                RunObject = Page "NPR TM Waiting List Setup";
            }
            action("Send Waiting List Notifications")
            {
                ToolTip = 'Send notifications to those on waiting list.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Send Waiting List Notifications';
                Image = Interaction;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TicketWaitingListMgr: Codeunit "NPR TM Ticket WaitingList Mgr.";
                begin
                    if (Rec."Waiting List Setup Code" <> '') then
                        TicketWaitingListMgr.ProcessAdmission(Rec, Today, true);
                end;
            }
            action(SetUserTimeZone)
            {
                Caption = 'Reset Admission Time Zone';
                ToolTip = 'Reset the admission time zone to be same as the service time zone.';
                Image = Setup;
                ApplicationArea = NPRTicketAdvanced;

                trigger OnAction()
                begin
                    Rec.TimeZoneNo := 0;
                    CurrPage.Update(true);
                end;
            }
        }
        area(processing)
        {
        }
        area(reporting)
        {
            action("Admission Forecast")
            {
                Caption = 'Admission Forecast';
                ToolTip = 'Navigate to Admission Forecast.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = Forecast;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                var
                    AdmissionForecastMatrix: Page "NPR TM Admis. Forecast Matrix";
                begin
                    AdmissionForecastMatrix.SetInitialAdmissionCode(Rec."Admission Code");
                    AdmissionForecastMatrix.Run();
                end;
            }

            action("Event List")
            {
                ToolTip = 'Generate a report on admissions.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Event List';
                Image = CustomerList;
                RunObject = Report "NPR TM Admission List";
                ObsoleteState = Pending;
                ObsoleteTag = '2023-06-28';
                ObsoleteReason = 'NPR TM Admission List is going to be deleted.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        _ManagedByAdmission := Rec."Capacity Limits By" = Rec."Capacity Limits By"::Admission;
        DisplayTimeZoneName(Rec.TimeZoneNo);
    end;

    var
        _CalendarManager: Codeunit "Calendar Management";
        _TMCalendarManager: Codeunit "NPR TMBaseCalendarManager";
        _ManagedByAdmission: Boolean;
        _AdmissionTimeZoneDescription: Text;

    local procedure DisplayTimeZoneName(TimeZoneNo: Integer)
    var
        TimeZone: Record "Time Zone";
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        if (TimeZoneNo = 0) then
            if (TicketSetup.Get()) then
                TimeZoneNo := TicketSetup.ServiceTimeZoneNo;

        _AdmissionTimeZoneDescription := 'User-Impersonation';
        if (TimeZone.Get(TimeZoneNo)) then
            _AdmissionTimeZoneDescription := TimeZone."Display Name";
    end;
}
