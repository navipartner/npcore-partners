codeunit 6151557 "NPR NpXml Process Single Batch"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    TableNo = "NPR NpXml Template";

    trigger OnRun()
    var
        NpXmlBatchMgt: Codeunit "NPR NpXml Batch Mgt.";
    begin
        NpXmlBatchMgt.RunSingleBatch(Rec);
    end;
}
