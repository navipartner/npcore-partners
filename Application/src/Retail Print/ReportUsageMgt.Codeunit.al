codeunit 6014487 "NPR Report Usage Mgt."
{
    // NPR5.48/TJ  /20181108 CASE 324444 New object
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.51/ZESO/20190816 CASE 365191 All log Entry only for Reports which fall in 50000..99999


    trigger OnRun()
    begin
    end;

    var
        ReportUsageSetup: Record "NPR Report Usage Setup";
        Enabled: Boolean;
        ReportUsageInitText: Label '%1 has been %2.';
        EnabledText: Label 'enabled';
        DisabledText: Label 'disabled';

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterFindPrinter', '', false, false)]
    local procedure OnFindPrinter(ReportID: Integer; var PrinterName: Text[250])
    begin
        if not ReportUsageSetup.Get() then
            exit;
        if not ReportUsageSetup.Enabled then
            exit;

        //-NPR5.51 [365191]
        if ReportID in [50000 .. 99999] then
            //-NPR5.51 [365191]
            AddToLog(ReportID);
    end;

    procedure EnableDisableSetup(Enable: Boolean)
    begin
        Enabled := Enable;
        AddToLog(0);
    end;

    local procedure AddToLog(ReportID: Integer)
    var
        ReportUsageLogEntry: Record "NPR Report Usage Log Entry";
        ActiveSession: Record "Active Session";
        EntryNo: Integer;
        AllObj: Record AllObj;
    begin
        EntryNo := 1;
        if ReportUsageLogEntry.FindLast() then
            EntryNo := ReportUsageLogEntry."Entry No." + 1;
        ActiveSession.SetRange("Server Instance ID", ServiceInstanceId);
        ActiveSession.SetRange("Session ID", SessionId);
        ActiveSession.FindFirst();
        ReportUsageLogEntry.Init();
        ReportUsageLogEntry."Entry No." := EntryNo;
        ReportUsageLogEntry."Database Name" := ActiveSession."Database Name";
        ReportUsageLogEntry."Tenant Id" := TenantId;
        ReportUsageLogEntry."Company Name" := CompanyName;
        ReportUsageLogEntry."Report Id" := ReportID;
        case true of
            AllObj.Get(AllObj."Object Type"::Report, ReportID):
                ReportUsageLogEntry.Description := CopyStr(AllObj."Object Name", 1, MaxStrLen(ReportUsageLogEntry.Description));
            Enabled:
                ReportUsageLogEntry.Description := CopyStr(StrSubstNo(ReportUsageInitText, ReportUsageSetup.TableCaption, EnabledText), 1, MaxStrLen(ReportUsageLogEntry.Description));
            not Enabled:
                ReportUsageLogEntry.Description := CopyStr(StrSubstNo(ReportUsageInitText, ReportUsageSetup.TableCaption, DisabledText), 1, MaxStrLen(ReportUsageLogEntry.Description));
        end;
        ReportUsageLogEntry."Enabled/Disabled Entry" := ReportID = 0;
        ReportUsageLogEntry."User Id" := UserId;
        ReportUsageLogEntry."Used on" := CurrentDateTime;
        ReportUsageLogEntry.Insert();
    end;
}

