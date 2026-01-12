codeunit 6150812 "NPR NpCs Task Processor"
{
    TableNo = "NPR Nc Task";
    Access = Internal;

    trigger OnRun()
    var
        Sentry: Codeunit "NPR Sentry";
    begin
        Sentry.InitScopeAndTransaction('NpCs Task Processor', 'bc.task.processor');
        ProcessTask(Rec);
        Sentry.FinalizeScope();
    end;

    local procedure ProcessTask(var NcTask: Record "NPR Nc Task");
    var
        NpCsTaskProcessorSetup: Record "NPR NpCs Task Processor Setup";
        NpCsDocument: Record "NPR NpCs Document";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        NpCsPostDocument: Codeunit "NPR NpCs Post Document";
        NpCsExpirationMgt: Codeunit "NPR NpCs Expiration Mgt.";
        UnhandledTaskProcessorErr: Label 'Task Processor Code %1 is not handled by this codeunit';
        Sentry: Codeunit "NPR Sentry";
        ProcessSpan: Codeunit "NPR Sentry Span";
    begin
        Sentry.StartSpan(ProcessSpan, StrSubstNo('process_task_%1', NcTask."Task Processor Code"));

        NpCsDocument.SetPosition(NcTask."Record Position");
        if not NpCsDocument.Find() then begin
            ProcessSpan.Finish();
            exit;
        end;

        NpCsTaskProcessorSetup.Get();
        case NcTask."Task Processor Code" of
            NpCsTaskProcessorSetup."Run Workflow Code":
                NpCsWorkflowMgt.Run(NpCsDocument);
            NpCsTaskProcessorSetup."Document Posting Code":
                NpCsPostDocument.Run(NpCsDocument);
            NpCsTaskProcessorSetup."Expiration Code":
                NpCsExpirationMgt.Run(NpCsDocument);
            else begin
                Sentry.AddLastErrorInEnglish();
                ProcessSpan.Finish();
                Error(UnhandledTaskProcessorErr, NcTask."Task Processor Code");
            end;
        end;

        ProcessSpan.Finish();
    end;
}
