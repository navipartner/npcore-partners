codeunit 6151557 "NPR NpXml Process Single Batch"
{
    Access = Internal;
    TableNo = "NPR NpXml Template";

    trigger OnRun()
    var
        NpXmlBatchMgt: Codeunit "NPR NpXml Batch Mgt.";
    begin
        NpXmlBatchMgt.RunSingleBatch(Rec);
    end;
}
