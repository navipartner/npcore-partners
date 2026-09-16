codeunit 6151268 "NPR Spfy Resync Scope Runner"
{
    Access = Internal;
    TableNo = "NPR Spfy Resync Run";

    trigger OnRun()
    var
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
    begin
        SpfyResyncMgt.DispatchScope(Rec);
    end;
}
