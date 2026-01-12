codeunit 6059869 "NPR POS Backgr. Task Manager"
{
    Access = internal;

    // This object allows any AL callstack that was started from the POS to queue up background tasks that should be started in the POS page.
    // This allows writing asynchronous code without popping a new modal page on top of the POS - however it also has some downsides:
    // Because the CurrPage object cannot be passed outside the POS page object, this object acts as a queue which the POS page checks at the end of the AL call stack.
    // This means this codeunit can only be used in any callstack that started from a control addin trigger on the POS page - lucky for us, that includes all of our POS workflows calling back to NST.        
    // The continuation functions that run back on the user thread also cannot invoke the frontend directly - this seems to be undocumented by MS but any call back to a control addin is skipped.
    // This means that a single instance codeunit with state set by continuations + polling from frontend checking the single instance state is the best we can do - no way to avoid polling :(.

    // It also does not allow any error levels apart from "Error" as warnings don't work on the POS page and we require consumers of this codeunit to implement the error procedure of the interface.
    // It also does not allow handling of return value on EnqueuePageBackgroundTask as it is not invoked synchronously right away - instead the return value is left unhandled, meaning in the very unlikely scenario of 
    // 5 active page background child session + 100 queued child sessions it will throw an error. 

    // Note 1: If Microsoft ever gets their shit together and either invents a better Background Tasks API that does not require a page to execute them OR, as a smaller invention, adds an asynchronous 
    // HttpClient.SendAsync(HttpRequest, SuccessCodeunitId, FailureCodeunitId); API then this wrapper can just be deleted.

    // Note 2: The main reason this has been developed is that in BC Cloud there is, as of the time of this writing, a TENANT wide limit of 10 background sessions but a PARENT SESSION specific 
    // limit of 5 page background child sessions. This means background sessions are effectively ruled out for things like async EFT integrations.

    var
        _PBTIdToWrapperIdMap: Dictionary of [Integer, Integer];
        _WrapperIdToPBTIdMap: Dictionary of [Integer, Integer];
        _TaskParameters: Dictionary of [Integer, Dictionary of [Text, Text]];
        _TaskTimeouts: Dictionary of [Integer, Integer];
        _TaskImplementations: Dictionary of [Integer, Integer];
        _QueuedTasks: List of [Integer];
        _QueuedCancellations: List of [Integer];
        _LastUsedId: Integer;

    trigger OnRun()
    var
        Parameters: Dictionary of [Text, Text];
        Result: Dictionary of [Text, Text];
        TaskImplementation: Interface "NPR POS Background Task";
        TaskEnumKey: Integer;
        TaskId: Integer;
        Sentry: Codeunit "NPR Sentry";
        ExecutionSpan: Codeunit "NPR Sentry Span";
    begin
        Parameters := Page.GetBackgroundParameters();

        Evaluate(TaskEnumKey, Parameters.Get('__POSBackgroundTaskEnumKey'));
        Evaluate(TaskId, Parameters.Get('__POSBackgroundTaskId'));
        TaskImplementation := Enum::"NPR POS Background Task".FromInteger(TaskEnumKey);

        Sentry.InitScopeAndTransaction(StrSubstNo('POS Background Task: %1', Format(TaskImplementation)), 'bc.pos.background_task.execute');
        Sentry.StartSpan(ExecutionSpan, StrSubstNo('bc.pos.background_task.execute:%1', Format(TaskImplementation)));

        Parameters.Remove('__POSBackgroundTaskEnumKey');
        Parameters.Remove('__POSBackgroundTaskId');
        TaskImplementation.ExecuteBackgroundTask(TaskId, Parameters, Result);

        ExecutionSpan.Finish();
        Sentry.FinalizeScope();

        Page.SetBackgroundTaskResult(Result);
    end;

    procedure EnqueuePOSBackgroundTask(var WrapperTaskIdOut: Integer; TaskImplementation: Enum "NPR POS Background Task"; var Parameters: Dictionary of [Text, Text]; Timeout: Integer)
    var
        POSPageStackCheck: Codeunit "NPR POS Page Stack Check";
        Sentry: Codeunit "NPR Sentry";
        EnqueueSpan: Codeunit "NPR Sentry Span";
    begin
        if not POSPageStackCheck.CurrentStackWasStartedByPOSTrigger() then
            Error('POS Background Tasks can only be queued and executed in AL callstacks that originate from a POS Page trigger. This is a programming bug.');

        Sentry.StartSpan(EnqueueSpan, StrSubstNo('bc.pos.background_task.enqueue:%1', Format(TaskImplementation)));

        WrapperTaskIdOut := _LastUsedId + 1;
        _LastUsedId := WrapperTaskIdOut;


        _QueuedTasks.Add(WrapperTaskIdOut);
        _TaskParameters.Add(WrapperTaskIdOut, Parameters);
        _TaskTimeouts.Add(WrapperTaskIdOut, Timeout);
        _TaskImplementations.Add(WrapperTaskIdOut, TaskImplementation.AsInteger());

        EnqueueSpan.Finish();
    end;

    procedure CancelPOSBackgroundTask(WrapperTaskId: Integer)
    var
        POSPageStackCheck: Codeunit "NPR POS Page Stack Check";
    begin
        if not POSPageStackCheck.CurrentStackWasStartedByPOSTrigger() then
            Error('POS Background Tasks can only be cancelled in AL callstacks that originate from a POS Page trigger. This is a programming bug.');

        _QueuedCancellations.Add(WrapperTaskId);
    end;

    procedure GetQueue(var QueuedTasksOut: List of [Integer]);
    begin
        QueuedTasksOut := _QueuedTasks;
    end;

    procedure GetCancellationQueue(var QueuedCancellationsOut: List of [Integer])
    begin
        QueuedCancellationsOut := _QueuedCancellations;
    end;

    procedure TryGetPBTTaskId(WrapperTaskId: Integer; var PBTTaskIdOut: Integer): Boolean
    begin
        exit(_WrapperIdToPBTIdMap.Get(WrapperTaskId, PBTTaskIdOut));
    end;

    procedure GetQueuedTask(WrapperTaskId: Integer; var ParametersOut: Dictionary of [Text, Text]; var TimeoutOut: Integer)
    begin
        if not _QueuedTasks.Contains(WrapperTaskId) then
            Error('Tried to pop queued task with unknown id: %1. This is a programming bug.', WrapperTaskId);

        ParametersOut := _TaskParameters.Get(WrapperTaskId);
        TimeoutOut := _TaskTimeouts.Get(WrapperTaskId);

        //Add two internal fields to parameters, they will be deleted again before handing control to the implementation codeunit.

        ParametersOut.Add('__POSBackgroundTaskEnumKey', Format(_TaskImplementations.Get(WrapperTaskId)));
        ParametersOut.Add('__POSBackgroundTaskId', Format(WrapperTaskId));
    end;

    procedure AddMappedId(PBTTaskId: Integer; WrapperTaskId: Integer)
    begin
        _PBTIdToWrapperIdMap.Add(PBTTaskId, WrapperTaskId);
        _WrapperIdToPBTIdMap.Add(WrapperTaskId, PBTTaskId);
    end;

    procedure ClearQueues();
    begin
        Clear(_QueuedTasks);
        Clear(_QueuedCancellations);
        Clear(_TaskTimeouts);
    end;

    procedure BackgroundTaskCompleted(PBTTaskId: Integer; Results: Dictionary of [Text, Text])
    var
        WrapperTaskId: Integer;
        TaskImplementation: Interface "NPR POS Background Task";
        Parameters: Dictionary of [Text, Text];
        Sentry: Codeunit "NPR Sentry";
        CompletionSpan: Codeunit "NPR Sentry Span";
    begin
        WrapperTaskId := _PBTIdToWrapperIdMap.Get(PBTTaskId);
        TaskImplementation := Enum::"NPR POS Background Task".FromInteger(_TaskImplementations.Get(WrapperTaskId));
        _TaskParameters.Get(WrapperTaskId, Parameters);

        Sentry.StartSpan(CompletionSpan, StrSubstNo('bc.pos.background_task.complete:%1', Format(TaskImplementation)));

        CleanupTaskStateBeforeContinuation(PBTTaskId);
        TaskImplementation.BackgroundTaskSuccessContinuation(WrapperTaskId, Parameters, Results);

        CompletionSpan.Finish();
    end;

    procedure BackgroundTaskError(PBTTaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        WrapperTaskId: Integer;
        TaskImplementation: Interface "NPR POS Background Task";
        Parameters: Dictionary of [Text, Text];
        Sentry: Codeunit "NPR Sentry";
        ErrorSpan: Codeunit "NPR Sentry Span";
    begin
        WrapperTaskId := _PBTIdToWrapperIdMap.Get(PBTTaskId);
        TaskImplementation := Enum::"NPR POS Background Task".FromInteger(_TaskImplementations.Get(WrapperTaskId));
        _TaskParameters.Get(WrapperTaskId, Parameters);

        Sentry.StartSpan(ErrorSpan, StrSubstNo('bc.pos.background_task.error:%1', Format(TaskImplementation)));
        Sentry.AddError(ErrorText, ErrorCallStack);

        CleanupTaskStateBeforeContinuation(PBTTaskId);
        TaskImplementation.BackgroundTaskErrorContinuation(WrapperTaskId, Parameters, ErrorCode, ErrorText, ErrorCallStack);

        ErrorSpan.Finish();

        IsHandled := true;
    end;

    procedure BackgroundTaskCancelled(PBTTaskId: Integer)
    var
        WrapperTaskId: Integer;
        TaskImplementation: Interface "NPR POS Background Task";
        Parameters: Dictionary of [Text, Text];
        Sentry: Codeunit "NPR Sentry";
        CancelSpan: Codeunit "NPR Sentry Span";
    begin
        WrapperTaskId := _PBTIdToWrapperIdMap.Get(PBTTaskId);
        TaskImplementation := Enum::"NPR POS Background Task".FromInteger(_TaskImplementations.Get(WrapperTaskId));
        _TaskParameters.Get(WrapperTaskId, Parameters);

        Sentry.StartSpan(CancelSpan, StrSubstNo('bc.pos.background_task.cancel:%1', Format(TaskImplementation)));

        CleanupTaskStateBeforeContinuation(PBTTaskId);
        TaskImplementation.BackgroundTaskCancelled(WrapperTaskId, Parameters);

        CancelSpan.Finish();
    end;

    local procedure CleanupTaskStateBeforeContinuation(PBTTaskId: Integer)
    var
        WrapperTaskId: Integer;
    begin
        WrapperTaskId := _PBTIdToWrapperIdMap.Get(PBTTaskId);
        if _PBTIdToWrapperIdMap.Remove(PBTTaskId) then;
        if _WrapperIdToPBTIdMap.Remove(WrapperTaskId) then;
        if _TaskParameters.Remove(WrapperTaskId) then;
        if _TaskImplementations.Remove(WrapperTaskId) then;
        if _TaskTimeouts.Remove(WrapperTaskId) then;
    end;

}