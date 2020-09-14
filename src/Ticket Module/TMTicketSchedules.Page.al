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
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Schedule Code"; "Schedule Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Schedule Type"; "Schedule Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Is"; "Admission Is")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Start From"; "Start From")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Recurrence Until Pattern"; "Recurrence Until Pattern")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("End After Occurrence Count"; "End After Occurrence Count")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("End After Date"; "End After Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Recurrence Pattern"; "Recurrence Pattern")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Recur Every N On"; "Recur Every N On")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Stop Time"; "Stop Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Event Duration"; "Event Duration")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Event Arrival From Time"; "Event Arrival From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Event Arrival Until Time"; "Event Arrival Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Sales From Date (Rel.)"; "Sales From Date (Rel.)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Sales From Time"; "Sales From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Sales Until Date (Rel.)"; "Sales Until Date (Rel.)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Sales Until Time"; "Sales Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Monday; Monday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Tuesday; Tuesday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Wednesday; Wednesday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Thursday; Thursday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Friday; Friday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Saturday; Saturday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Sunday; Sunday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Prebook Is Required"; "Prebook Is Required")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Notify Stakeholder"; "Notify Stakeholder")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Max Capacity Per Sch. Entry"; "Max Capacity Per Sch. Entry")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Reserved For Web"; "Reserved For Web")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                }
                field("Reserved For Members"; "Reserved For Members")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                }
                field("Unbookable Before Start (Secs)"; "Unbookable Before Start (Secs)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                }
                field("Bookable Passed Start (Secs)"; "Bookable Passed Start (Secs)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                }
                field("Capacity Control"; "Capacity Control")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Prebook From"; "Prebook From")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Base Calendar Code"; "Admission Base Calendar Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Customized Calendar"; CalendarMgmt.CustomizedChangesExist(CustomizedCalendarChangeTemp))
                {
                    ApplicationArea = NPRTicketAdvanced;
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
                ToolTip = 'Navigate to Admission List.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Admission';
                Image = WorkCenter;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

            }
            action("Admission Schedules")
            {
                ToolTip = 'Navigate to Admission Schedules.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
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

