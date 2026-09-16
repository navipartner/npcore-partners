codeunit 6151274 "NPR Spfy Poll Table Runner"
{
    Access = Internal;
    TableNo = "NPR Change Tracker";

    trigger OnRun()
    var
        SpfyChangeDetection: Codeunit "NPR Spfy Change Detection";
    begin
        SpfyChangeDetection.PollSourceTable(Rec);
    end;
}
