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
                    ToolTip = 'Specifies the value of the Schedule Code field';
                }
                field("Schedule Type"; "Schedule Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Schedule Type field';
                }
                field("Admission Is"; "Admission Is")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Is field';
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Start From"; "Start From")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Start From field';
                }
                field("Recurrence Until Pattern"; "Recurrence Until Pattern")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Recurrence Until Pattern field';
                }
                field("End After Occurrence Count"; "End After Occurrence Count")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the End After Occurrence Count field';
                }
                field("End After Date"; "End After Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the End After Date field';
                }
                field("Recurrence Pattern"; "Recurrence Pattern")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Recurrence Pattern field';
                }
                field("Recur Every N On"; "Recur Every N On")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Recur Every N On field';
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field("Stop Time"; "Stop Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Stop Time field';
                }
                field("Event Duration"; "Event Duration")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Duration field';
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
                field(Monday; Monday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Monday field';
                }
                field(Tuesday; Tuesday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Tuesday field';
                }
                field(Wednesday; Wednesday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wednesday field';
                }
                field(Thursday; Thursday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Thursday field';
                }
                field(Friday; Friday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Friday field';
                }
                field(Saturday; Saturday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Saturday field';
                }
                field(Sunday; Sunday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sunday field';
                }
                field("Prebook Is Required"; "Prebook Is Required")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Prebook Is Required field';
                }
                field("Notify Stakeholder"; "Notify Stakeholder")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notify Stakeholder field';
                }
                field("Notify Stakeholder On Sell-Out"; "Notify Stakeholder On Sell-Out")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notify Stakeholder On Sell-Out field';
                }
                field("Notify When Percentage Sold"; "Notify When Percentage Sold")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notify When Percentage Sold field';
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
                field("Prebook From"; "Prebook From")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Prebook From field';
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

