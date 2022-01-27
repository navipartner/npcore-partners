page 6060118 "NPR TM Ticket Schedules"
{
    Extensible = False;
    Caption = 'Ticket Schedules';
    PageType = List;
    SourceTable = "NPR TM Admis. Schedule";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Schedule Code"; Rec."Schedule Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Schedule Code field';
                }
                field("Schedule Type"; Rec."Schedule Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Schedule Type field';
                }
                field("Admission Is"; Rec."Admission Is")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Is field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Start From"; Rec."Start From")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Start From field';
                }
                field("Recurrence Until Pattern"; Rec."Recurrence Until Pattern")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Recurrence Until Pattern field';
                }
                field("End After Occurrence Count"; Rec."End After Occurrence Count")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the End After Occurrence Count field';
                }
                field("End After Date"; Rec."End After Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the End After Date field';
                }
                field("Recurrence Pattern"; Rec."Recurrence Pattern")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Recurrence Pattern field';
                }
                field("Recur Every N On"; Rec."Recur Every N On")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Recur Every N On field';
                }
                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field("Stop Time"; Rec."Stop Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Stop Time field';
                }
                field("Event Duration"; Rec."Event Duration")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Duration field';
                }
                field("Event Arrival From Time"; Rec."Event Arrival From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Arrival From Time field';
                }
                field("Event Arrival Until Time"; Rec."Event Arrival Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Event Arrival Until Time field';
                }
                field("Sales From Date (Rel.)"; Rec."Sales From Date (Rel.)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Date (Rel.) field';
                }
                field("Sales From Time"; Rec."Sales From Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales From Time field';
                }
                field("Sales Until Date (Rel.)"; Rec."Sales Until Date (Rel.)")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Date (Rel.) field';
                }
                field("Sales Until Time"; Rec."Sales Until Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Until Time field';
                }
                field(Monday; Rec.Monday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Monday field';
                }
                field(Tuesday; Rec.Tuesday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Tuesday field';
                }
                field(Wednesday; Rec.Wednesday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wednesday field';
                }
                field(Thursday; Rec.Thursday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Thursday field';
                }
                field(Friday; Rec.Friday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Friday field';
                }
                field(Saturday; Rec.Saturday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Saturday field';
                }
                field(Sunday; Rec.Sunday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sunday field';
                }
                field("Prebook Is Required"; Rec."Prebook Is Required")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Prebook Is Required field';
                }
                field("Notify Stakeholder"; Rec."Notify Stakeholder")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notify Stakeholder field';
                }
                field("Notify Stakeholder On Sell-Out"; Rec."Notify Stakeholder On Sell-Out")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notify Stakeholder On Sell-Out field';
                }
                field("Notify When Percentage Sold"; Rec."Notify When Percentage Sold")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notify When Percentage Sold field';
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
                field("Unbookable Before Start (Secs)"; Rec."Unbookable Before Start (Secs)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Unbookable Before Start (Secs) field';
                }
                field("Bookable Passed Start (Secs)"; Rec."Bookable Passed Start (Secs)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Bookable Passed Start (Secs) field';
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
                field("Admission Base Calendar Code"; Rec."Admission Base Calendar Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Base Calendar Code field';
                }
                field("Customized Calendar"; CalendarMgmt.CustomizedChangesExist(TempCustomizedCalendarChange))
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Customized Calendar';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customized Calendar field';

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord();
                        Rec.TestField("Admission Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(TempCustomizedCalendarChange);
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
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

            }
            action("Admission Schedules")
            {
                ToolTip = 'Navigate to Admission Schedules.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Admission Schedules';
                Image = CalendarWorkcenter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Admis. Schedule Lines";
                RunPageLink = "Schedule Code" = FIELD("Schedule Code");

            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Clear(TempCustomizedCalendarChange);
        TempCustomizedCalendarChange."Source Type" := TempCustomizedCalendarChange."Source Type"::Location;
        TempCustomizedCalendarChange."Additional Source Code" := Rec."Schedule Code";
        TempCustomizedCalendarChange."Base Calendar Code" := Rec."Admission Base Calendar Code";
        if (not TempCustomizedCalendarChange.Insert()) then;
    end;

    var
        TempCustomizedCalendarChange: Record "Customized Calendar Change" temporary;
        CalendarMgmt: Codeunit "Calendar Management";
}

