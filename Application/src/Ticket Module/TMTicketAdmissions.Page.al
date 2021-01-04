page 6060120 "NPR TM Ticket Admissions"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.08/TSA/20160262  CASE 232262 Dependant admission objects
    // TM1.09/TSA/20160229  CASE 235795 Default Schedule option on Admission Code
    // TM1.11/TSA/20160404  CASE 232250 Added new fields 47 and 48
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.13/TSA/20160502  CASE 239055 Transport TM1.13 - 29 April 2016
    // TM1.16/TSA/20160714  CASE 245004 Added support for participant notifications
    // TM1.18/NPKNAV/20170125  CASE 258974 Transport TM1.18 - 25 January 2017
    // TM1.21/ANEN /20170406 CASE 271150 Added field "POS Schedule Selection To Date"
    // TM1.28/TSA /20180201 CASE 303925 Added field for Base Calendar
    // TM1.38/TSA /20181012 CASE 332109 Adding eTicket
    // TM1.45/TSA /20191108 CASE 374620 Added "Stakeholder (E-Mail/Phone No.)"
    // TM1.45/TSA /20191113 CASE 322432 Added Seating Setup button
    // TM1.45/TSA /20191207 CASE 380754 Added waitinglist fields and action to notify
    // TM1.48/TSA /20200703 CASE 409741 Added Admission Forecast

    Caption = 'Ticket Admissions';
    PageType = List;
    SourceTable = "NPR TM Admission";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field(Type; Type)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Location Admission Code"; "Location Admission Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Location Admission Code field';
                }
                field("Capacity Limits By"; "Capacity Limits By")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Capacity Limits By field';
                }
                field("Default Schedule"; "Default Schedule")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Default Schedule field';
                }
                field("Prebook Is Required"; "Prebook Is Required")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Prebook Is Required field';
                }
                field("Max Capacity Per Sch. Entry"; "Max Capacity Per Sch. Entry")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Max Capacity Per Sch. Entry field';
                }
                field("Reserved For Web"; "Reserved For Web")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reserved For Web field';
                }
                field("Reserved For Members"; "Reserved For Members")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reserved For Members field';
                }
                field("Capacity Control"; "Capacity Control")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Capacity Control field';
                }
                field("Prebook From"; "Prebook From")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Prebook From field';
                }
                field("Ticketholder Notification Type"; "Ticketholder Notification Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticketholder Notification Type field';
                }
                field("Stakeholder (E-Mail/Phone No.)"; "Stakeholder (E-Mail/Phone No.)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Stakeholder (E-Mail/Phone No.) field';
                }
                field("Dependency Code"; "Dependency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Dependency Code field';
                }
                field("POS Schedule Selection Date F."; "POS Schedule Selection Date F.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the POS Admission Schedule Entry Selection Date Filter field';
                }
                field("Admission Base Calendar Code"; "Admission Base Calendar Code")
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
                        TestField("Admission Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(CustomizedCalendarChangeAdmissionTemp);
                    end;
                }
                field("Ticket Base Calendar Code"; "Ticket Base Calendar Code")
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
                        TestField("Admission Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(CustomizedCalendarChangeTicketTemp);
                    end;
                }
                field("eTicket Type Code"; "eTicket Type Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the eTicket Type Code field';
                }
                field("Waiting List Setup Code"; "Waiting List Setup Code")
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
                PromotedCategory = Process;
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
                PromotedCategory = Process;
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
                PromotedCategory = Process;
                RunObject = Page "NPR TM Admis. Schedule Lines";
                RunPageLink = "Admission Code" = FIELD("Admission Code");

            }
            action("Event List")
            {
                ToolTip = 'Generate a report on admissions.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Event List';
                Image = CustomerList;
                RunObject = Report "NPR TM Admission List";

            }
            action("Seating Setup")
            {
                ToolTip = 'Navigate to Seating Setup';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Seating Setup';
                Image = Segment;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "NPR TM Seating Setup";
                RunPageLink = "Admission Code" = FIELD("Admission Code");

            }
            action("Waiting List Setup")
            {
                ToolTip = 'Navigate to Waiting List Setup';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Waiting List Setup';
                Ellipsis = true;
                Image = Open;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "NPR TM Waiting List Setup";

            }
        }
        area(processing)
        {
            action("Send Waitinglist Notifications")
            {
                ToolTip = 'Send notifications to those on waitinglist.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Send Waitinglist Notifications';
                Image = Interaction;

                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                var
                    TicketWaitingListMgr: Codeunit "NPR TM Ticket WaitingList Mgr.";
                begin

                    //-TM1.45 [380754]
                    if ("Waiting List Setup Code" <> '') then
                        TicketWaitingListMgr.ProcessAdmission(Rec, Today, true);
                    //+TM1.45 [380754]
                end;
            }
        }
        area(reporting)
        {
            action("Admission Forecast")
            {
                ToolTip = 'Navigate to Admission Forecast.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = Forecast;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;


                trigger OnAction()
                var
                    AdmissionForecastMatrix: Page "NPR TM Admis. Forecast Matrix";
                begin

                    //-TM1.48 [409741]
                    AdmissionForecastMatrix.SetInitialAdmissionCode(Rec."Admission Code");
                    AdmissionForecastMatrix.Run();
                    //+TM1.48 [409741]
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Clear(CustomizedCalendarChangeAdmissionTemp);
        CustomizedCalendarChangeAdmissionTemp."Source Type" := CustomizedCalendarChangeAdmissionTemp."Source Type"::Location;
        CustomizedCalendarChangeAdmissionTemp."Source Code" := "Admission Code";
        CustomizedCalendarChangeAdmissionTemp."Base Calendar Code" := "Admission Base Calendar Code";
        if (not CustomizedCalendarChangeAdmissionTemp.Insert()) then;

        Clear(CustomizedCalendarChangeTicketTemp);
        CustomizedCalendarChangeTicketTemp."Source Type" := CustomizedCalendarChangeTicketTemp."Source Type"::Service;
        CustomizedCalendarChangeTicketTemp."Source Code" := "Admission Code";
        CustomizedCalendarChangeTicketTemp."Base Calendar Code" := "Ticket Base Calendar Code";
        if (not CustomizedCalendarChangeTicketTemp.Insert()) then;
    end;

    var
        CustomizedCalendarChangeAdmissionTemp: Record "Customized Calendar Change" temporary;
        CustomizedCalendarChangeTicketTemp: Record "Customized Calendar Change" temporary;
        CalendarMgmt: Codeunit "Calendar Management";
}

