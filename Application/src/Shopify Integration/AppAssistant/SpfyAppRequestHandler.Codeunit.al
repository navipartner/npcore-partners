#if not BC17
codeunit 6248247 "NPR Spfy App Request Handler"
{
    Access = Internal;
    TableNo = "NPR Spfy App Request";

    trigger OnRun()
    var
        SpfyAppRequest: Record "NPR Spfy App Request";
        SpfyAppRequestIHndlr: Interface "NPR Spfy App Request IHndlr";
    begin
        SelectLatestVersion();
#if not (BC18 or BC19 or BC20 or BC21)
        SpfyAppRequest.ReadIsolation := IsolationLevel::UpdLock;
#else
        SpfyAppRequest.LockTable();
#endif
        SpfyAppRequest.Get(Rec."Entry No.");
        if SpfyAppRequest.Status = SpfyAppRequest.Status::Processed then
            exit;  //already processed elsewhere

        Clear(SpfyAppRequest."Last Error Message");
        SpfyAppRequest.Status := SpfyAppRequest.Status::New;

        SpfyAppRequestIHndlr := SpfyAppRequest.Type;
        SpfyAppRequestIHndlr.ProcessAppRequest(SpfyAppRequest);

        Rec := SpfyAppRequest;
    end;
}
#endif