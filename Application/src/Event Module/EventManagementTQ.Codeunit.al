codeunit 6060156 "NPR Event Management TQ"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        GetAttendeeResponse();
    end;

    local procedure GetAttendeeResponse()
    var
        JobPlanningLine: Record "Job Planning Line";
        EventCalendarMgt: Codeunit "NPR Event Calendar Mgt.";
    begin
        JobPlanningLine.SetFilter("NPR Event Status", '%1|%2', JobPlanningLine."NPR Event Status"::Quote, JobPlanningLine."NPR Event Status"::Order);
        JobPlanningLine.SetFilter("NPR Calendar Item ID", '<>%1', '');
        JobPlanningLine.SetFilter("NPR Calendar Item Status", '<>%1', JobPlanningLine."NPR Calendar Item Status"::" ");
        if JobPlanningLine.FindSet() then
            repeat
                EventCalendarMgt.GetCalendarAttendeeResponse(JobPlanningLine);
            until JobPlanningLine.Next() = 0;
    end;
}