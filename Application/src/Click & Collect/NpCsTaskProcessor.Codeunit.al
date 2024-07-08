codeunit 6150812 "NPR NpCs Task Processor"
{
    TableNo = "NPR Nc Task";
    Access = Internal;

    trigger OnRun()
    begin
        ProcessTask(Rec);
    end;

    local procedure ProcessTask(var NcTask: Record "NPR Nc Task");
    var
        NpCsTaskProcessorSetup: Record "NPR NpCs Task Processor Setup";
        NpCsDocument: Record "NPR NpCs Document";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        NpCsPostDocument: Codeunit "NPR NpCs Post Document";
        NpCsExpirationMgt: Codeunit "NPR NpCs Expiration Mgt.";
        UnhandledTaskProcessorErr: Label 'Task Processor Code %1 is not handled by this codeunit';
    begin
        NpCsDocument.SetPosition(NcTask."Record Position");
        if not NpCsDocument.Find() then
            exit;

        NpCsTaskProcessorSetup.Get();
        case NcTask."Task Processor Code" of
            NpCsTaskProcessorSetup."Run Workflow Code":
                NpCsWorkflowMgt.Run(NpCsDocument);
            NpCsTaskProcessorSetup."Document Posting Code":
                NpCsPostDocument.Run(NpCsDocument);
            NpCsTaskProcessorSetup."Expiration Code":
                NpCsExpirationMgt.Run(NpCsDocument);
            else
                Error(UnhandledTaskProcessorErr, NcTask."Task Processor Code");
        end;
    end;
}
