codeunit 6059768 "NPR NaviDocs Management TQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        NaviDocsSetup: Record "NPR NaviDocs Setup";
    begin
        if NaviDocsSetup.Get() and NaviDocsSetup."Enable NaviDocs" then
            DocManageNaviDocs();

        CleanupNaviDocs();
    end;

    procedure DocManageNaviDocs()
    var
        NaviDocsSetup: Record "NPR NaviDocs Setup";
        NaviDocsHandlingProfile: Record "NPR NaviDocs Handling Profile";
        NaviDocsEntry: Record "NPR NaviDocs Entry";
        NaviDocsEntry2: Record "NPR NaviDocs Entry";
        NaviDocsMgt: Codeunit "NPR NaviDocs Management";
    begin
        if not NaviDocsSetup.Get() then
            exit;

        if not NaviDocsSetup."Enable NaviDocs" then
            exit;

        NaviDocsEntry.Reset();
        NaviDocsEntry.SetCurrentKey(Status);
        NaviDocsEntry.SetRange(Status, 0, 1);
        NaviDocsHandlingProfile.SetRange("Handle by NAS", true);
        if NaviDocsHandlingProfile.FindSet() then
            repeat
                NaviDocsEntry.SetRange("Document Handling Profile", NaviDocsHandlingProfile.Code);
                NaviDocsEntry.SetFilter("Processed Qty.", '<%1', NaviDocsSetup."Max Retry Qty");
                if NaviDocsEntry.FindSet(true) then
                    repeat
                        NaviDocsEntry2.Copy(NaviDocsEntry);
                        NaviDocsMgt.Process(NaviDocsEntry2);
                        Commit();
                    until NaviDocsEntry.Next() = 0;
            until NaviDocsHandlingProfile.Next() = 0;
    end;

    local procedure CleanupNaviDocs()
    var
        NaviDocsSetup: Record "NPR NaviDocs Setup";
        NaviDocsEntry: Record "NPR NaviDocs Entry";
        DeleteLogsBeforeDate: Date;
    begin
        if not NaviDocsSetup.Get() then
            exit;

        if NaviDocsSetup."Keep Log for" = 0 then
            exit;

        DeleteLogsBeforeDate := DT2Date(CreateDateTime(Today, 000000T) - NaviDocsSetup."Keep Log for");
        NaviDocsEntry.Reset();
        NaviDocsEntry.SetFilter("Insert Date", '<%1', DeleteLogsBeforeDate);
        NaviDocsEntry.DeleteAll(true);
    end;
}

