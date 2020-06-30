page 6060118 "TM Ticket Schedules"
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
    SourceTable = "TM Admission Schedule";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Schedule Code"; "Schedule Code")
                {
                }
                field("Schedule Type"; "Schedule Type")
                {
                }
                field("Admission Is"; "Admission Is")
                {
                }
                field(Description; Description)
                {
                }
                field("Start From"; "Start From")
                {
                }
                field("Recurrence Until Pattern"; "Recurrence Until Pattern")
                {
                }
                field("End After Occurrence Count"; "End After Occurrence Count")
                {
                }
                field("End After Date"; "End After Date")
                {
                }
                field("Recurrence Pattern"; "Recurrence Pattern")
                {
                }
                field("Recur Every N On"; "Recur Every N On")
                {
                }
                field("Start Time"; "Start Time")
                {
                }
                field("Stop Time"; "Stop Time")
                {
                }
                field("Event Duration"; "Event Duration")
                {
                }
                field("Event Arrival From Time"; "Event Arrival From Time")
                {
                }
                field("Event Arrival Until Time"; "Event Arrival Until Time")
                {
                }
                field("Sales From Date (Rel.)"; "Sales From Date (Rel.)")
                {
                }
                field("Sales From Time"; "Sales From Time")
                {
                }
                field("Sales Until Date (Rel.)"; "Sales Until Date (Rel.)")
                {
                }
                field("Sales Until Time"; "Sales Until Time")
                {
                }
                field(Monday; Monday)
                {
                }
                field(Tuesday; Tuesday)
                {
                }
                field(Wednesday; Wednesday)
                {
                }
                field(Thursday; Thursday)
                {
                }
                field(Friday; Friday)
                {
                }
                field(Saturday; Saturday)
                {
                }
                field(Sunday; Sunday)
                {
                }
                field("Prebook Is Required"; "Prebook Is Required")
                {
                }
                field("Notify Stakeholder"; "Notify Stakeholder")
                {
                }
                field("Max Capacity Per Sch. Entry"; "Max Capacity Per Sch. Entry")
                {
                }
                field("Reserved For Web"; "Reserved For Web")
                {
                    Visible = false;
                }
                field("Reserved For Members"; "Reserved For Members")
                {
                    Visible = false;
                }
                field("Unbookable Before Start (Secs)"; "Unbookable Before Start (Secs)")
                {
                    Visible = false;
                }
                field("Bookable Passed Start (Secs)"; "Bookable Passed Start (Secs)")
                {
                    Visible = false;
                }
                field("Capacity Control"; "Capacity Control")
                {
                }
                field("Prebook From"; "Prebook From")
                {
                }
                field("Admission Base Calendar Code"; "Admission Base Calendar Code")
                {
                }
                field("Customized Calendar"; CalendarMgmt.CustomizedChangesExist(CustomizedCalendarChangeTemp))
                {
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
                RunObject = Page "TM Admission Schedule Lines";
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

