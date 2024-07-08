page 6060032 "NPR MM Membership Statistics"
{
    ApplicationArea = NPRMembershipEssential;
    Caption = 'Membership Statistics';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR MM Membership Statistics";
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Reference Date"; Rec."Reference Date")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Reference Date field.';
                }
                field("Active Members"; ActiveMembers)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Caption = 'Active Members';
                    ToolTip = 'Specifies the value of the Active Members field.';
                }
                field("First Time Members"; Rec."First Time Members")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the First Time Members field.';
                }
                field("First Time Members (%)"; FirstTimeMembersPct)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Caption = 'First Time Members (%)';
                    ToolTip = 'Specifies the value of the First Time Members (%) field.';
                }
                field("Recurring Members"; Rec."Recurring Members")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Recurring Members field.';
                }
                field("Recurring Members (%)"; RecurringMembersPct)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Caption = 'Recurring Members (%)';
                    ToolTip = 'Specifies the value of the Recurring Members (%) field.';
                }
                field("Future Timeslot"; Rec."Future Members")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Future Members field.';
                }
                field("Future Timeslot (%)"; FutureTimeslotPct)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Caption = 'Future Timeslot (%)';
                    ToolTip = 'Specifies the value of the Future Members (%) field.';
                }
                field("First Time Members Last Year"; Rec."First Time Members Last Year")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the First Time Members Last Year field.';
                }
                field("Recurring Members Last Year"; Rec."Recurring Members Last Year")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Recurring Members Last Year field.';
                }
                field("No. of Members compared LY (%)"; MembersComparedLYPct)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Caption = 'No. of Members compared LY (%)';
                    ToolTip = 'Specifies the value of the No. of Members compared LY (%) field.';
                }
                field("No. of Members expire CM"; Rec."No. of Members expire CM")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the No. of Members expire CM field.';
                }
                field("No. of Members expire CM (%)"; MembersExpireCM)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Caption = 'No. of Members expire CM (%)';
                    ToolTip = 'Specifies the value of the No. of Members expire CM (%) field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateHistory)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Create Historical Data';
                ToolTip = 'Creates historical data for statistics purpose.';
                Image = History;
                trigger OnAction()
                var
                    MMStatMgmt: Codeunit "NPR MM Membership Stat. Mgmt.";
                begin
                    MMStatMgmt.CreateHistoricalData();
                end;
            }
            action(CreateHistorySingleDate)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Create Historical Data (Single Date)';
                ToolTip = 'Creates historical data for statistics purpose for a single date.';
                Image = Add;
                trigger OnAction()
                var
                    MMStatMgmt: Codeunit "NPR MM Membership Stat. Mgmt.";
                begin
                    MMStatMgmt.CreateHistoricalDataSingleDate();
                end;
            }
            action(DeleteHistory)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Delete Historical Data';
                ToolTip = 'Delete created historical data until a selected date.';
                Image = Delete;
                trigger OnAction()
                var
                    MMStatMgmt: Codeunit "NPR MM Membership Stat. Mgmt.";
                begin
                    MMStatMgmt.DeleteHistoricalData();
                end;
            }
            action(CreateJob)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Create Recurring Job';
                ToolTip = 'Creates a Job Queue Entry to update the Membership Statistics daily.';
                Image = ResetStatus;
                trigger OnAction()
                var
                    MMStatMgmt: Codeunit "NPR MM Membership Stat. Mgmt.";
                begin
                    MMStatMgmt.CreateJobQueueEntry();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ClearGlobals();
        ActiveMembers := Rec."First Time Members" + Rec."Recurring Members";
        if ActiveMembers > 0 then begin
            FirstTimeMembersPct := Rec."First Time Members" / ActiveMembers;
            RecurringMembersPct := Rec."Recurring Members" / ActiveMembers;
            FutureTimeslotPct := Rec."Future Members" / ActiveMembers;
            MembersExpireCM := Rec."No. of Members expire CM" / ActiveMembers;
        end;
        if (Rec."First Time Members Last Year" + Rec."Recurring Members Last Year") > 0 then
            MembersComparedLYPct := (ActiveMembers / (Rec."First Time Members Last Year" + Rec."Recurring Members Last Year") - 1)
        else
            MembersComparedLYPct := 1;
    end;

    local procedure ClearGlobals()
    var
    begin
        ActiveMembers := 0;
        FirstTimeMembersPct := 0;
        RecurringMembersPct := 0;
        FutureTimeslotPct := 0;
        MembersComparedLYPct := 0;
        MembersExpireCM := 0;
    end;

    var
        ActiveMembers: Integer;
        FirstTimeMembersPct: Decimal;
        RecurringMembersPct: Decimal;
        FutureTimeslotPct: Decimal;
        MembersComparedLYPct: Decimal;
        MembersExpireCM: Decimal;
}
