page 6060120 "NPR TM Ticket Admissions"
{
    Extensible = False;
    Caption = 'Ticket Admissions';
    PageType = List;
    SourceTable = "NPR TM Admission";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    ContextSensitiveHelpPage = 'product/ticket/intro.html';
    PromotedActionCategories = 'New,Process,Report,Navigate';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the code of the specific admission.';
                }
                field(Type; Rec.Type)
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
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Location Admission Code field';
                }
                field("Capacity Limits By"; Rec."Capacity Limits By")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies how the maximum capacity is controlled.';
                }
                field("Default Schedule"; Rec."Default Schedule")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies how the assisted ticket sales process should select initial time slot.';
                }
                field("Prebook Is Required"; Rec."Prebook Is Required")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies whether the entry is reservation-based or open.';
                }
                field("Max Capacity Per Sch. Entry"; Rec."Max Capacity Per Sch. Entry")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the maximum capacity of the admission.';
                }
                field("Reserved For Web"; Rec."Reserved For Web")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reserved For Web field';
                }
                field("Reserved For Members"; Rec."Reserved For Members")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reserved For Members field';
                }
                field("Capacity Control"; Rec."Capacity Control")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies whether it’s possible to sell an indefinite number of tickets, if the capacity is limited by the number of seats in the admission, or if the capacity is governed by the number of entries/the difference between the number of admitted and departed customers.';
                }
                field("Prebook From"; Rec."Prebook From")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies how far in advance the time slots will be generated for this admission. Ultimately it governs how far into the future a ticket for this admission can be sold.';
                }
                field("Ticketholder Notification Type"; Rec."Ticketholder Notification Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies whether it’s required for ticketholders to state their phone number/email address when buying a ticket.';
                }
                field("Stakeholder (E-mail/Phone No.)"; Rec."Stakeholder (E-mail/Phone No.)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the email or phone number of the admission code owner.';
                    Caption = 'Stakeholder Email/Phone No.';
                }
                field("Dependency Code"; Rec."Dependency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the rules which govern admission dependencies.';
                }
                field("POS Schedule Selection Date F."; Rec."POS Schedule Selection Date F.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies a date formula to limit the range of possible dates for which a ticket can be sold. Used to make the selection process briefer on the POS.';
                    Caption = 'Admission Schedule Filter (POS)';
                }
                field("Admission Base Calendar Code"; Rec."Admission Base Calendar Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'The calendar defines exceptions to the general schedules and has the possibility to prevent sales for specific dates or holidays.';
                }
                field("AdmissionCustomized Calendar"; CalendarMgmt.CustomizedChangesExist(TempCustomizedCalendarChangeAdmission))
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Admission Customized Calendar';
                    Editable = false;
                    ToolTip = 'If a base calendar is added, you can select calendar variations in this column.';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord();
                        Rec.TestField("Admission Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(TempCustomizedCalendarChangeAdmission);
                    end;
                }
                field("Ticket Base Calendar Code"; Rec."Ticket Base Calendar Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'The calendar defines exceptions to the general schedules and has the possibility to prevent sales for specific dates or holidays.';
                }
                field("TicketCustomized Calendar"; CalendarMgmt.CustomizedChangesExist(TempCustomizedCalendarChangeTicket))
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Ticket Customized Calendar';
                    Editable = false;
                    ToolTip = 'If a base calendar is added, you can select calendar variations in this column.';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord();
                        Rec.TestField("Admission Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(TempCustomizedCalendarChangeTicket);
                    end;
                }
                field("eTicket Type Code"; Rec."eTicket Type Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the eTicket Type Code field';
                }
                field("Waiting List Setup Code"; Rec."Waiting List Setup Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies conditions which need to be met for a waiting list to be created, and how the customers will be notified when they are able to buy tickets.';
                }
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

            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Clear(TempCustomizedCalendarChangeAdmission);
        TempCustomizedCalendarChangeAdmission."Source Type" := TempCustomizedCalendarChangeAdmission."Source Type"::Location;
        TempCustomizedCalendarChangeAdmission."Source Code" := Rec."Admission Code";
        TempCustomizedCalendarChangeAdmission."Base Calendar Code" := Rec."Admission Base Calendar Code";
        if (not TempCustomizedCalendarChangeAdmission.Insert()) then;

        Clear(TempCustomizedCalendarChangeTicket);
        TempCustomizedCalendarChangeTicket."Source Type" := TempCustomizedCalendarChangeTicket."Source Type"::Service;
        TempCustomizedCalendarChangeTicket."Source Code" := Rec."Admission Code";
        TempCustomizedCalendarChangeTicket."Base Calendar Code" := Rec."Ticket Base Calendar Code";
        if (not TempCustomizedCalendarChangeTicket.Insert()) then;
    end;

    var
        TempCustomizedCalendarChangeAdmission: Record "Customized Calendar Change" temporary;
        TempCustomizedCalendarChangeTicket: Record "Customized Calendar Change" temporary;
        CalendarMgmt: Codeunit "Calendar Management";
}

