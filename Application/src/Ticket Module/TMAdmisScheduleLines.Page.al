page 6060119 "NPR TM Admis. Schedule Lines"
{
    Extensible = False;
    Caption = 'Admission Schedule Lines';
    PageType = List;
    SourceTable = "NPR TM Admis. Schedule Lines";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    PromotedActionCategories = 'New,Process,Report,Calculate Entries,Navigate';

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
                field("Schedule Code"; Rec."Schedule Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Schedule Code field';
                }
                field("Visibility On Web"; Rec."Visibility On Web")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Visibility On Web field';
                }
                field("Process Order"; Rec."Process Order")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Process Order field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Blocked field';
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
                field("Concurrency Code"; Rec."Concurrency Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Concurrency Code field';
                }
                field("Prebook From"; Rec."Prebook From")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Prebook From field';
                }
                field("Schedule Generated Until"; Rec."Schedule Generated Until")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Schedule Generated Until field';
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
                field("Scheduled Start Time"; Rec."Scheduled Start Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Scheduled Start Time field';
                }
                field("Scheduled Stop Time"; Rec."Scheduled Stop Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Scheduled Stop Time field';
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
                field("Pricing Option"; Rec."Pricing Option")
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Pricing Option field';
                }
                field("Price Scope"; Rec."Price Scope")
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Price Scope field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field(Percentage; Rec.Percentage)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Percentage field';
                }
                field("Amount Includes VAT"; Rec."Amount Includes VAT")
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Amount Includes VAT field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Calculate Schedule Entries")
            {
                ToolTip = 'Append to the list of generated time slots';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Calculate New Entries';
                Image = CalcWorkCenterCalendar;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    TMAdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
                begin

                    TMAdmissionSchManagement.CreateAdmissionSchedule(Rec."Admission Code", false, WorkDate());
                end;
            }
            action("Calculate Schedule Entries (Force)")
            {
                ToolTip = 'Regenerate all time slot entries from today';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Recreate Entries';
                Image = CalcWorkCenterCalendar;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    TMAdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
                begin
                    if (Confirm(FORCE_GENERATE, false)) then
                        TMAdmissionSchManagement.CreateAdmissionSchedule(Rec."Admission Code", true, WorkDate());
                end;
            }

            action(Admission)
            {
                Caption = 'Admission';
                ToolTip = 'Navigate to Admission List.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = WorkCenter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
                RunObject = Page "NPR TM Ticket Admissions";
                RunPageLink = "Admission Code" = FIELD("Admission Code");

            }
            action(Schedules)
            {
                ToolTip = 'Navigate to Admission Schedules.';
                Caption = 'Schedule';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = Workdays;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category5;
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
                PromotedCategory = Category5;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Admis. Schedule Entry";
                RunPageLink = "Admission Code" = FIELD("Admission Code"),
                              "Schedule Code" = FIELD("Schedule Code");

            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetFilter(Blocked, '=%1', false);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Clear(TempCustomizedCalendarChange);
        TempCustomizedCalendarChange."Source Type" := TempCustomizedCalendarChange."Source Type"::Location;
        TempCustomizedCalendarChange."Source Code" := Rec."Admission Code";
        TempCustomizedCalendarChange."Additional Source Code" := Rec."Schedule Code";
        TempCustomizedCalendarChange."Base Calendar Code" := Rec."Admission Base Calendar Code";
        if (not TempCustomizedCalendarChange.Insert()) then;
    end;

    var
        FORCE_GENERATE: Label 'This action will regenerate all schedules entries based on the schedule definitions. Manual changes will be lost. Do you want to continue?';
        TempCustomizedCalendarChange: Record "Customized Calendar Change" temporary;
        CalendarMgmt: Codeunit "Calendar Management";
}
