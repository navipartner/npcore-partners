#if BC17
//For BC18 and above use standard CU 2846 "Post Inventory Cost to G/L"
codeunit 6014683 "NPR Post Inventory Cost to G/L"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        ReportInbox: Record "Report Inbox";
        PostInvToGL: Report "Post Inventory Cost to G/L";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        PostMethod: Option "per Posting Group","per Entry";
        OutStr: OutStream;
    begin
        ReportInbox.Init();
        ReportInbox."User ID" := Rec."User ID";
        ReportInbox."Job Queue Log Entry ID" := Rec.ID;
        ReportInbox."Report ID" := Report::"Post Inventory Cost to G/L";
        ReportInbox.Description := Rec.Description;
        ReportInbox."Report Output".CreateOutStream(OutStr);

        PostInvToGL.InitializeRequest(PostMethod::"per Entry", '', true);
        PostInvToGL.UseRequestPage(false);
        PostInvToGL.SaveAs(GetReportParameters(), ReportFormat::Pdf, OutStr);

        JQParamStrMgt.Parse(Rec."Parameter String");
        if not JQParamStrMgt.GetParamValueAsBoolean(ParamSaveToReportInbox()) then
            exit;
        ReportInbox."Created Date-Time" := RoundDateTime(CurrentDateTime, 60000);
        ReportInbox.Insert(true);
    end;

    local procedure GetReportParameters(): Text
    begin
        exit('');
    end;

    procedure ParamSaveToReportInbox(): Text
    begin
        exit('save_to_report_inbox');
    end;
}
#endif
