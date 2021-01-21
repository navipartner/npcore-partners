page 6060119 "NPR TM Admis. Schedule Lines"
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
    SourceTable = "NPR TM Admis. Schedule Lines";
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
                field("Schedule Code"; "Schedule Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Schedule Code field';
                }
                field("Visibility On Web"; "Visibility On Web")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Visibility On Web field';
                }
                field("Process Order"; "Process Order")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Process Order field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Blocked field';
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
                field("Unbookable Before Start (Secs)"; "Unbookable Before Start (Secs)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Unbookable Before Start (Secs) field';
                }
                field("Bookable Passed Start (Secs)"; "Bookable Passed Start (Secs)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Bookable Passed Start (Secs) field';
                }
                field("Capacity Control"; "Capacity Control")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Capacity Control field';
                }
                field("Concurrency Code"; "Concurrency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Concurrency Code field';
                }
                field("Prebook From"; "Prebook From")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Prebook From field';
                }
                field("Schedule Generated Until"; "Schedule Generated Until")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Schedule Generated Until field';
                }
                field("Admission Base Calendar Code"; "Admission Base Calendar Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Base Calendar Code field';
                }
                field("Customized Calendar"; CalendarMgmt.CustomizedChangesExist(CustomizedCalendarChangeTemp))
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Customized Calendar';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customized Calendar field';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        TestField("Admission Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(CustomizedCalendarChangeTemp);
                    end;
                }
                field("Scheduled Start Time"; "Scheduled Start Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Scheduled Start Time field';
                }
                field("Scheduled Stop Time"; "Scheduled Stop Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Scheduled Stop Time field';
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
                field("Sales From Date (Rel.)"; "Sales From Date (Rel.)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Date (Rel.) field';
                }
                field("Sales From Time"; "Sales From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Time field';
                }
                field("Sales Until Date (Rel.)"; "Sales Until Date (Rel.)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Date (Rel.) field';
                }
                field("Sales Until Time"; "Sales Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Time field';
                }
                field("Pricing Option"; "Pricing Option")
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Pricing Option field';
                }
                field("Price Scope"; "Price Scope")
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Price Scope field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field(Percentage; Percentage)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Percentage field';
                }
                field("Amount Includes VAT"; "Amount Includes VAT")
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Amount Includes VAT field';
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
                ToolTip = 'Append to the list of generated time slots';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Calculate Schedule Entries';
                Image = CalcWorkCenterCalendar;
                Promoted = true;
				PromotedOnly = true;


                trigger OnAction()
                var
                    TMAdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
                begin

                    TMAdmissionSchManagement.CreateAdmissionSchedule("Admission Code", false, WorkDate);
                end;
            }
            action("Calculate Schedule Entries (Force)")
            {
                ToolTip = 'Regenerate all time slot entries from today';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Calculate Schedule Entries (Force)';
                Image = CalcWorkCenterCalendar;


                trigger OnAction()
                var
                    TMAdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
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
                ToolTip = 'Navigate to Admission List.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = WorkCenter;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "NPR TM Ticket Admissions";
                RunPageLink = "Admission Code" = FIELD("Admission Code");

            }
            action(Schedules)
            {
                ToolTip = 'Navigate to Admission Schedules.';
                Caption = 'Schedules';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = Workdays;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket Schedules";
                RunPageLink = "Schedule Code" = FIELD("Schedule Code");

            }
            action("Schedule Entries")
            {
                ToolTip = 'Navigate to Admission Schedules Entries.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Schedule Entries';
                Image = WorkCenterLoad;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Admis. Schedule Entry";
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
        if (not CustomizedCalendarChangeTemp.Insert()) then;
    end;

    var
        FORCE_GENERATE: Label 'This action will regenerate all schedules entries based on the schedule definitions. Manual changes will be lost. Do you want to continue?';
        CustomizedCalendarChangeTemp: Record "Customized Calendar Change" temporary;
        CalendarMgmt: Codeunit "Calendar Management";
}
