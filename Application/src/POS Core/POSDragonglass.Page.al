page 6150750 "NPR POS (Dragonglass)"
{
    Extensible = False;
    Caption = 'POS';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            usercontrol(Framework; "NPR Dragonglass")
            {
                ApplicationArea = NPRRetail;

                trigger OnFrameworkReady()
                var
                    FrameworkDragonGlass: Codeunit "NPR Framework: Dragonglass";
                    POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
                begin
                    FrameworkDragonGlass.Constructor(CurrPage.Framework);
                    POSBackgroundTaskAPI.Initialize(_POSBackgroundTaskManager);
                    _POSSession.Constructor(FrameworkDragonGlass, _FrontEnd, _Setup, _PageId, POSBackgroundTaskAPI);
                    if _POSSession.GetErrorOnInitialize() then begin
                        CurrPage.Close();
                        Error(GetLastErrorText());
                    end;
                    _POSSession.DebugWithTimestamp('OnFrameworkReady');
                end;

                trigger OnInvokeMethod(method: Text; eventContext: JsonObject)
                var
                    POSPageStackCheck: Codeunit "NPR POS Page Stack Check";
                begin
                    if method = 'KeepAlive' then
                        exit; //exit asap to minimize overhead of idle sessions       
                    _POSSession.ErrorIfPageIdMismatch(_PageId);

                    _POSSession.DebugWithTimestamp('Method:' + method);
                    BindSubscription(POSPageStackCheck);
                    _POSBackgroundTaskManager.ClearQueues();

                    _JavaScript.InvokeMethod(method, eventContext, _POSSession, _FrontEnd, _JavaScript);

                    ProcessBackgroundTaskQueues();
                end;

                trigger OnAction("action": Text; workflowStep: Text; workflowId: Integer; actionId: Integer; context: JsonObject)
                var
                    POSPageStackCheck: Codeunit "NPR POS Page Stack Check";
                begin
                    _POSSession.ErrorIfNotInitialized();
                    _POSSession.ErrorIfPageIdMismatch(_PageId);

                    _POSSession.DebugWithTimestamp('Action:' + action);
                    BindSubscription(POSPageStackCheck);
                    _POSBackgroundTaskManager.ClearQueues();

                    _JavaScript.InvokeAction(CopyStr(action, 1, 20), workflowStep, workflowId, actionId, context, _POSSession, _FrontEnd, _JavaScript);

                    ProcessBackgroundTaskQueues();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        TempAction: Record "NPR POS Action" temporary;
    begin
        _PageId := CreateGuid();
        _POSSession.SetPageId(_PageId);
        _POSSession.DebugWithTimestamp('Action discovery starts');
        TempAction.DiscoverActions();
        _POSSession.DebugWithTimestamp('Action discovery ends');
    end;

    local procedure ProcessBackgroundTaskQueues()
    var
        QueuedTasks: List of [Integer];
        WrapperTaskId: Integer;
        Parameters: Dictionary of [Text, Text];
        Timeout: Integer;
        PBTTaskId: Integer;
        QueuedCancellations: List of [Integer];
    begin
        //Process enqueue tasks
        _POSBackgroundTaskManager.GetQueue(QueuedTasks);
        if QueuedTasks.Count() <> 0 then begin
            Commit(); // in case EnqueueBackgroundTask throws error we don't want to rollback anything that happened in the page trigger

            foreach WrapperTaskId in QueuedTasks do begin
                Clear(PBTTaskId);
                _POSBackgroundTaskManager.GetQueuedTask(WrapperTaskId, Parameters, Timeout);
                CurrPage.EnqueueBackgroundTask(PBTTaskId, Codeunit::"NPR POS Backgr. Task Manager", Parameters, Timeout);
                _POSBackgroundTaskManager.AddMappedId(PBTTaskId, WrapperTaskId);
            end;
        end;

        //Process cancellation requests
        _POSBackgroundTaskManager.GetCancellationQueue(QueuedCancellations);
        foreach WrapperTaskId in QueuedCancellations do begin
            if _POSBackgroundTaskManager.TryGetPBTTaskId(WrapperTaskId, PBTTaskId) then begin
                if CurrPage.CancelBackgroundTask(PBTTaskId) then begin
                    _POSBackgroundTaskManager.BackgroundTaskCancelled(PBTTaskId);
                end;
            end;
        end;
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        _POSBackgroundTaskManager.BackgroundTaskCompleted(TaskId, Results);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    begin
        _POSBackgroundTaskManager.BackgroundTaskError(TaskId, ErrorCode, ErrorText, ErrorCallStack, IsHandled);
    end;

    var
        _Setup: Codeunit "NPR POS Setup";
        _POSSession: Codeunit "NPR POS Session";
        _JavaScript: Codeunit "NPR POS JavaScript Interface";
        _FrontEnd: Codeunit "NPR POS Front End Management";
        _PageId: Guid;
        _POSBackgroundTaskManager: Codeunit "NPR POS Backgr. Task Manager";
}

