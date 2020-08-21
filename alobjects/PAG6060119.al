page 6060119 "TM Admission Schedule Lines"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.09/TSA/20160310  CASE 236742 UX improvements
    // TM1.11/TSA/20160404  CASE 232250 Added new fields 47 and 48
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.19/TSA/20170220 CASE 266768 Added default filter to not show blocked entries
    // TM1.24/TSA /20170829 CASE 288396 Added a button for soft regenerare and a message on hard regenerate
    // TM1.28/TSA /20180201 CASE 303925 Added calendar customization
    // TM1.28/TSA /20180221 CASE 306039 Added "Visibility On Web"
    // TM1.37/TSA /20180905 CASE 327324 Added fields for better control of arrival window
    // TM1.41/TSA /20190507 CASE 353981 Adding Scheduled based pricing
    // TM1.45/TSA /20191120 CASE 378212 Added sales cut-off date and time
    // TM1.45/TSA /20200116 CASE 385922 Added Concurrency Code field

    Caption = 'Admission Schedule Lines';
    PageType = List;
    SourceTable = "TM Admission Schedule Lines";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                }
                field("Schedule Code"; "Schedule Code")
                {
                    ApplicationArea = All;
                }
                field("Visibility On Web"; "Visibility On Web")
                {
                    ApplicationArea = All;
                }
                field("Process Order"; "Process Order")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Prebook Is Required"; "Prebook Is Required")
                {
                    ApplicationArea = All;
                }
                field("Max Capacity Per Sch. Entry"; "Max Capacity Per Sch. Entry")
                {
                    ApplicationArea = All;
                }
                field("Reserved For Web"; "Reserved For Web")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Reserved For Members"; "Reserved For Members")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Unbookable Before Start (Secs)"; "Unbookable Before Start (Secs)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Bookable Passed Start (Secs)"; "Bookable Passed Start (Secs)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Capacity Control"; "Capacity Control")
                {
                    ApplicationArea = All;
                }
                field("Concurrency Code"; "Concurrency Code")
                {
                    ApplicationArea = All;
                }
                field("Prebook From"; "Prebook From")
                {
                    ApplicationArea = All;
                }
                field("Schedule Generated Until"; "Schedule Generated Until")
                {
                    ApplicationArea = All;
                }
                field("Admission Base Calendar Code"; "Admission Base Calendar Code")
                {
                    ApplicationArea = All;
                }
                field("Customized Calendar"; CalendarMgmt.CustomizedChangesExist(CustomizedCalendarChangeTemp))
                {
                    ApplicationArea = All;
                    Caption = 'Customized Calendar';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        TestField("Admission Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(CustomizedCalendarChangeTemp);
                    end;
                }
                field("Scheduled Start Time"; "Scheduled Start Time")
                {
                    ApplicationArea = All;
                }
                field("Scheduled Stop Time"; "Scheduled Stop Time")
                {
                    ApplicationArea = All;
                }
                field("Event Arrival From Time"; "Event Arrival From Time")
                {
                    ApplicationArea = All;
                }
                field("Event Arrival Until Time"; "Event Arrival Until Time")
                {
                    ApplicationArea = All;
                }
                field("Sales From Date (Rel.)"; "Sales From Date (Rel.)")
                {
                    ApplicationArea = All;
                }
                field("Sales From Time"; "Sales From Time")
                {
                    ApplicationArea = All;
                }
                field("Sales Until Date (Rel.)"; "Sales Until Date (Rel.)")
                {
                    ApplicationArea = All;
                }
                field("Sales Until Time"; "Sales Until Time")
                {
                    ApplicationArea = All;
                }
                field("Pricing Option"; "Pricing Option")
                {
                    ApplicationArea = All;
                }
                field("Price Scope"; "Price Scope")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field(Percentage; Percentage)
                {
                    ApplicationArea = All;
                }
                field("Amount Includes VAT"; "Amount Includes VAT")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Calculate Schedule Entries")
            {
                Caption = 'Calculate Schedule Entries';
                Image = CalcWorkCenterCalendar;
                Promoted = true;

                trigger OnAction()
                var
                    TMAdmissionSchManagement: Codeunit "TM Admission Sch. Management";
                begin

                    TMAdmissionSchManagement.CreateAdmissionSchedule("Admission Code", false, WorkDate);
                end;
            }
            action("Calculate Schedule Entries (Force)")
            {
                Caption = 'Calculate Schedule Entries (Force)';
                Image = CalcWorkCenterCalendar;

                trigger OnAction()
                var
                    TMAdmissionSchManagement: Codeunit "TM Admission Sch. Management";
                begin
                    //-TM1.24 [288396]
                    if (Confirm(FORCE_GENERATE, false)) then
                        TMAdmissionSchManagement.CreateAdmissionSchedule("Admission Code", true, WorkDate);
                    //+TM1.24 [288396]
                end;
            }
        }
        area(navigation)
        {
            action(Admission)
            {
                Caption = 'Admission';
                Image = WorkCenter;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "TM Ticket Admissions";
                RunPageLink = "Admission Code" = FIELD("Admission Code");
            }
            action(Schedules)
            {
                Caption = 'Schedules';
                Image = Workdays;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "TM Ticket Schedules";
                RunPageLink = "Schedule Code" = FIELD("Schedule Code");
            }
            action("Schedule Entries")
            {
                Caption = 'Schedule Entries';
                Image = WorkCenterLoad;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "TM Admission Schedule Entry";
                RunPageLink = "Admission Code" = FIELD("Admission Code"),
                              "Schedule Code" = FIELD("Schedule Code");
            }
        }
    }

    trigger OnOpenPage()
    begin

        //-+TM1.19 [266768]
        Rec.SetFilter(Blocked, '=%1', false);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Clear(CustomizedCalendarChangeTemp);
        CustomizedCalendarChangeTemp."Source Type" := CustomizedCalendarChangeTemp."Source Type"::Location;
        CustomizedCalendarChangeTemp."Source Code" := "Admission Code";
        CustomizedCalendarChangeTemp."Additional Source Code" := "Schedule Code";
        CustomizedCalendarChangeTemp."Base Calendar Code" := "Admission Base Calendar Code";
        CustomizedCalendarChangeTemp.Insert();
    end;

    var
        FORCE_GENERATE: Label 'This action will regenerate all schedules entries based on the schedule definitions. Manual changes will be lost. Do you want to continue?';
        CustomizedCalendarChangeTemp: Record "Customized Calendar Change" temporary;
        CalendarMgmt: Codeunit "Calendar Management";
}