codeunit 6060156 "Event Management TQ"
{
    // NPR5.32/NPKNAV/20170526  CASE 275954 Transport NPR5.32 - 26 May 2017

    TableNo = "Task Line";

    trigger OnRun()
    begin
        GetAttendeeResponse();
    end;

    local procedure GetAttendeeResponse()
    var
        JobPlanningLine: Record "Job Planning Line";
        EventCalendarMgt: Codeunit "Event Calendar Management";
    begin
        JobPlanningLine.SetFilter("Event Status",'%1|%2',JobPlanningLine."Event Status"::Quote,JobPlanningLine."Event Status"::Order);
        JobPlanningLine.SetFilter("Calendar Item ID",'<>%1','');
        JobPlanningLine.SetFilter("Calendar Item Status",'<>%1',JobPlanningLine."Calendar Item Status"::" ");
        if JobPlanningLine.FindSet then
          repeat
            EventCalendarMgt.GetCalendarAttendeeResponse(JobPlanningLine);
          until JobPlanningLine.Next = 0;
    end;
}

