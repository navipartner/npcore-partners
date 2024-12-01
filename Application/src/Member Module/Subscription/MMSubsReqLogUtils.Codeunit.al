codeunit 6185126 "NPR MM Subs Req Log Utils"
{
    Access = Internal;
    internal procedure OpenLogEntries(SubscrRequest: Record "NPR MM Subscr. Request")
    var
        SubsReqLogEntry: Record "NPR MM Subs Req Log Entry";
    begin
        SubsReqLogEntry.SetRange("Request Entry No.", SubscrRequest."Entry No.");
        Page.Run(0, SubsReqLogEntry);
    end;

    internal procedure LogEntry(SubscrRequest: Record "NPR MM Subscr. Request"; Manual: Boolean; var SubsReqLogEntry: Record "NPR MM Subs Req Log Entry")
    begin
        SubsReqLogEntry.Init();
        SubsReqLogEntry."Request Entry No." := SubscrRequest."Entry No.";
        SubsReqLogEntry."Request Id" := SubscrRequest.SystemId;
        SubsReqLogEntry.Status := SubscrRequest.Status;
        SubsReqLogEntry.Manual := Manual;
        SubsReqLogEntry."Processing Status" := SubsReqLogEntry."Processing Status"::Success;
        SubsReqLogEntry.Insert(true);
    end;

    internal procedure UpdateEntry(var SubsReqLogEntry: Record "NPR MM Subs Req Log Entry"; ProcessingStatus: Enum "NPR MM Sub Req Log Proc Status"; ErrorMessage: Text)
    var
        IsModified: Boolean;
    begin
        if SubsReqLogEntry."Processing Status" <> ProcessingStatus then begin
            SubsReqLogEntry."Processing Status" := ProcessingStatus;
            IsModified := true;
        end;

        if SubsReqLogEntry."Error Message" <> CopyStr(ErrorMessage, 1, MaxStrLen(SubsReqLogEntry."Error Message")) then begin
            SubsReqLogEntry."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(SubsReqLogEntry."Error Message"));
            IsModified := true;
        end;

        if IsModified then
            SubsReqLogEntry.Modify(true);
    end;
}