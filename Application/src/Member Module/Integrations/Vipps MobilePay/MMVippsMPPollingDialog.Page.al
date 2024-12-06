page 6184867 "NPR MM VippsMP Polling Dialog"
{
    Extensible = False;
    Caption = 'Waiting for the Vipps MobilePay request to be approved...';
    PageType = StandardDialog;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            usercontrol(BackgrTaskReqHandler; "NPR Backgr. Task Req. Handler")
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger ControlAddInReady()
                begin
                    CurrPage.BackgrTaskReqHandler.PollBackgroundTaskCompletion();
                end;

                trigger BackgroundTaskCompletionCallBack()
                begin
                    if TaskError.Message <> '' then begin
                        CurrPage.Close();
                    end;

                    if BackgroundTaskCompleted then
                        CurrPage.Close();

                    CurrPage.BackgrTaskReqHandler.PollBackgroundTaskCompletion();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR MM VippsMP Communication", TaskParameters, 900000, PageBackgroundTaskErrorLevel::Ignore);
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        if TaskId = BackgroundTaskId then begin
            TaskResults := Results;
            BackgroundTaskCompleted := true;
        end;
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    begin
        if TaskId = BackgroundTaskId then begin
            TaskError.Message := ErrorText;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21
            TaskError.Title := 'Vipps/MobilePay integration error';
            TaskError.DetailedMessage := 'Source AL call stack: ' + ErrorCallStack;
#endif
        end;
    end;

    internal procedure SetBackgroundTaskParameters(Parameters: Dictionary of [Text, Text])
    begin
        TaskParameters := Parameters;
    end;

    internal procedure GetBackgroundTaskResults(var Results: Dictionary of [Text, Text])
    begin
        Results := TaskResults;
    end;

    internal procedure IsCompleted(): Boolean
    begin
        exit(BackgroundTaskCompleted);
    end;

    internal procedure GetTaskError(): ErrorInfo
    begin
        exit(TaskError)
    end;

    var
        BackgroundTaskId: Integer;
        TaskParameters: Dictionary of [Text, Text];
        TaskResults: Dictionary of [Text, Text];
        BackgroundTaskCompleted: Boolean;
        TaskError: ErrorInfo;
}
