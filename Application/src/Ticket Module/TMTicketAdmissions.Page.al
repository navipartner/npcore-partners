page 6060120 "NPR TM Ticket Admissions"
{
    Caption = 'Ticket Admissions';
    PageType = List;
    SourceTable = "NPR TM Admission";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
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
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
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
                    ToolTip = 'Specifies the value of the Capacity Limits By field';
                }
                field("Default Schedule"; Rec."Default Schedule")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Default Schedule field';
                }
                field("Prebook Is Required"; Rec."Prebook Is Required")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Prebook Is Required field';
                }
                field("Max Capacity Per Sch. Entry"; Rec."Max Capacity Per Sch. Entry")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Max Capacity Per Sch. Entry field';
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
                    ToolTip = 'Specifies the value of the Capacity Control field';
                }
                field("Prebook From"; Rec."Prebook From")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Prebook From field';
                }
                field("Ticketholder Notification Type"; Rec."Ticketholder Notification Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticketholder Notification Type field';
                }
                field("Stakeholder (E-Mail/Phone No.)"; Rec."Stakeholder (E-Mail/Phone No.)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Stakeholder (E-Mail/Phone No.) field';
                }
                field("Dependency Code"; Rec."Dependency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Dependency Code field';
                }
                field("POS Schedule Selection Date F."; Rec."POS Schedule Selection Date F.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the POS Admission Schedule Entry Selection Date Filter field';
                }
                field("Admission Base Calendar Code"; Rec."Admission Base Calendar Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Base Calendar Code field';
                }
                field("AdmissionCustomized Calendar"; CalendarMgmt.CustomizedChangesExist(CustomizedCalendarChangeAdmissionTemp))
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Admission Customized Calendar';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Customized Calendar field';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        Rec.TestField("Admission Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(CustomizedCalendarChangeAdmissionTemp);
                    end;
                }
                field("Ticket Base Calendar Code"; Rec."Ticket Base Calendar Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Base Calendar Code field';
                }
                field("TicketCustomized Calendar"; CalendarMgmt.CustomizedChangesExist(CustomizedCalendarChangeTicketTemp))
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Ticket Customized Calendar';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Ticket Customized Calendar field';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        Rec.TestField("Admission Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(CustomizedCalendarChangeTicketTemp);
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
                    ToolTip = 'Specifies the value of the Waiting List Setup Code field';
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
        Clear(CustomizedCalendarChangeAdmissionTemp);
        CustomizedCalendarChangeAdmissionTemp."Source Type" := CustomizedCalendarChangeAdmissionTemp."Source Type"::Location;
        CustomizedCalendarChangeAdmissionTemp."Source Code" := Rec."Admission Code";
        CustomizedCalendarChangeAdmissionTemp."Base Calendar Code" := Rec."Admission Base Calendar Code";
        if (not CustomizedCalendarChangeAdmissionTemp.Insert()) then;

        Clear(CustomizedCalendarChangeTicketTemp);
        CustomizedCalendarChangeTicketTemp."Source Type" := CustomizedCalendarChangeTicketTemp."Source Type"::Service;
        CustomizedCalendarChangeTicketTemp."Source Code" := Rec."Admission Code";
        CustomizedCalendarChangeTicketTemp."Base Calendar Code" := Rec."Ticket Base Calendar Code";
        if (not CustomizedCalendarChangeTicketTemp.Insert()) then;
    end;

    var
        CustomizedCalendarChangeAdmissionTemp: Record "Customized Calendar Change" temporary;
        CustomizedCalendarChangeTicketTemp: Record "Customized Calendar Change" temporary;
        CalendarMgmt: Codeunit "Calendar Management";
}

