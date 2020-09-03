page 6060118 "NPR TM Ticket Schedules"
{
    // TM1.00/TSA /20151217 CASE 228982 NaviPartner Ticket Management
    // TM1.11/TSA /20160404 CASE 232250 Added new fields 47 and 48
    // TM1.12/TSA /20160407 CASE 230600 Added DAN Captions
    // TM1.28/TSA /20180201 CASE 303925 Added calendar customization
    // TM1.37/TSA /20180905 CASE 327324 Added fields for better control of arrival window
    // TM1.45/TSA /20191108 CASE 374620 Added "Notify Stakeholder"
    // TM1.45/TSA /20191120 CASE 378212 Added Sales cut-off date and time

    Caption = 'Ticket Schedules';
    PageType = List;
    SourceTable = "NPR TM Admis. Schedule";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Schedule Code"; "Schedule Code")
                {
                    ApplicationArea = All;
                }
                field("Schedule Type"; "Schedule Type")
                {
                    ApplicationArea = All;
                }
                field("Admission Is"; "Admission Is")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Start From"; "Start From")
                {
                    ApplicationArea = All;
                }
                field("Recurrence Until Pattern"; "Recurrence Until Pattern")
                {
                    ApplicationArea = All;
                }
                field("End After Occurrence Count"; "End After Occurrence Count")
                {
                    ApplicationArea = All;
                }
                field("End After Date"; "End After Date")
                {
                    ApplicationArea = All;
                }
                field("Recurrence Pattern"; "Recurrence Pattern")
                {
                    ApplicationArea = All;
                }
                field("Recur Every N On"; "Recur Every N On")
                {
                    ApplicationArea = All;
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                }
                field("Stop Time"; "Stop Time")
                {
                    ApplicationArea = All;
                }
                field("Event Duration"; "Event Duration")
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
                field(Monday; Monday)
                {
                    ApplicationArea = All;
                }
                field(Tuesday; Tuesday)
                {
                    ApplicationArea = All;
                }
                field(Wednesday; Wednesday)
                {
                    ApplicationArea = All;
                }
                field(Thursday; Thursday)
                {
                    ApplicationArea = All;
                }
                field(Friday; Friday)
                {
                    ApplicationArea = All;
                }
                field(Saturday; Saturday)
                {
                    ApplicationArea = All;
                }
                field(Sunday; Sunday)
                {
                    ApplicationArea = All;
                }
                field("Prebook Is Required"; "Prebook Is Required")
                {
                    ApplicationArea = All;
                }
                field("Notify Stakeholder"; "Notify Stakeholder")
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
                field("Prebook From"; "Prebook From")
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
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Admission)
            {
                Caption = 'Admission';
                Image = WorkCenter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
            action("Admission Schedules")
            {
                Caption = 'Admission Schedules';
                Image = CalendarWorkcenter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Admis. Schedule Lines";
                RunPageLink = "Schedule Code" = FIELD("Schedule Code");
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Clear(CustomizedCalendarChangeTemp);
        CustomizedCalendarChangeTemp."Source Type" := CustomizedCalendarChangeTemp."Source Type"::Location;
        CustomizedCalendarChangeTemp."Additional Source Code" := "Schedule Code";
        CustomizedCalendarChangeTemp."Base Calendar Code" := "Admission Base Calendar Code";
        CustomizedCalendarChangeTemp.Insert();
    end;

    var
        CustomizedCalendarChangeTemp: Record "Customized Calendar Change" temporary;
        CalendarMgmt: Codeunit "Calendar Management";
}

