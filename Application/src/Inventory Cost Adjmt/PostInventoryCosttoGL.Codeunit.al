//This is an alternative for standard CU 2846 "Post Inventory Cost to G/L"
codeunit 6014683 "NPR Post Inventory Cost to G/L"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
#if not (BC17 or BC18 or BC19)
        GLSetup: Record "General Ledger Setup";
        InventorySetup: Record "Inventory Setup";
#endif
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
#if not (BC17 or BC18 or BC19)
        if GLSetup.Get() and GLSetup."Journal Templ. Name Mandatory" then begin
            InventorySetup.Get();
            InventorySetup.TestField("Invt. Cost Jnl. Template Name");
            InventorySetup.TestField("Invt. Cost Jnl. Batch Name");
            PostInvToGL.SetGenJnlBatch(InventorySetup."Invt. Cost Jnl. Template Name", InventorySetup."Invt. Cost Jnl. Batch Name");
        end;
#endif
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

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry")
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        Rec.Validate("Parameter String", CopyStr(ParamSaveToReportInbox(), 1, MaxStrLen(Rec."Parameter String")));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Post Inventory Cost to G/L");
    end;
}
