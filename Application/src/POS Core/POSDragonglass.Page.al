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

                trigger InvokeMethod(requestId: Integer; method: Text; parameters: JsonObject)
                var
                    POSPageStackCheck: Codeunit "NPR POS Page Stack Check";
                    Response: JsonObject;
                    Success: Boolean;
                    POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
                    POSSession: Codeunit "NPR POS Session"; //Single instance
                    POSDragonglassRunMethod: Codeunit "NPR POS Dragonglass Run Method";
                    Sentry: Codeunit "NPR Sentry";
                    BackgroundTaskSpan: Codeunit "NPR Sentry Span";
                    KeepAliveSpan: Codeunit "NPR Sentry Span";
                    FrameworkReadySpan: Codeunit "NPR Sentry Span";
                    MethodSpan: Codeunit "NPR Sentry Span";
                    SentryTraceHeader: Text;
                    StartTime: DateTime;
                begin
                    StartTime := CurrentDateTime();

                    SentryTraceHeader := GetSentryTraceHeader(parameters);
                    if SentryTraceHeader <> '' then
                        Sentry.InitScopeAndTransaction(method, 'bc.pos', SentryTraceHeader, StartTime)
                    else
                        Sentry.InitScopeAndTransaction(method, 'bc.pos', StartTime);

                    if method = 'KeepAlive' then begin //every couple of minutes to prevent NST from shutting down idle POS sessions
                        Sentry.StartSpan(KeepAliveSpan, 'bc.pos.keepalive');

                        Response.Add('RequestID', requestId);
                        Response.Add('Success', true);
                        CurrPage.Framework.ControlAddinResponse(Response);

                        KeepAliveSpan.Finish();
                        Sentry.FinalizeScope();
                        exit;
                    end;
                    if method = 'FrameworkReady' then begin //once when POS frontend has loaded
                        Sentry.StartSpan(FrameworkReadySpan, 'bc.pos.framework_ready');

                        POSBackgroundTaskAPI.Initialize(_POSBackgroundTaskManager);
                        POSSession.Constructor(POSBackgroundTaskAPI);
                        CheckUserLocked();
                        CheckUserExpired();
                        if POSSession.GetErrorOnInitialize() then begin
                            Sentry.AddLastErrorInEnglish();
                            FrameworkReadySpan.Finish();
                            Sentry.FinalizeScope();
                            CurrPage.Close();
                            Error(GetLastErrorText());
                        end;

                        Response.Add('RequestID', requestId);
                        Response.Add('Success', true);
                        CurrPage.Framework.ControlAddinResponse(Response);
                        FrameworkReadySpan.Finish();
                        Sentry.FinalizeScope();
                        exit;
                    end;

                    POSSession.ErrorIfPageIdMismatch(_PageId);

                    POSSession.PopResponseQueue();
                    _POSBackgroundTaskManager.ClearQueues();

                    BindSubscription(POSPageStackCheck);

                    Sentry.StartSpan(MethodSpan, 'bc.pos.method:' + method);

                    ClearLastError();
                    POSDragonglassRunMethod.SetMethodParameters(method, parameters);
                    Success := POSDragonglassRunMethod.Run(); //Implicit commit

                    Response.Add('RequestID', requestId);
                    Response.Add('Success', Success);
                    if Success then begin
                        Response.Add('Responses', POSSession.PopResponseQueue());
                    end else begin
                        Response.Add('ErrorMessage', GetLastErrorText());
                    end;

                    CurrPage.Framework.ControlAddinResponse(Response);

                    MethodSpan.Finish();

                    if not Success then begin
                        Sentry.AddLastErrorInEnglish();
                        Sentry.FinalizeScope();
                        Error(GetLastErrorText());
                    end;

                    Sentry.StartSpan(BackgroundTaskSpan, 'bc.pos.process_background_tasks');
                    ProcessBackgroundTaskQueues();
                    BackgroundTaskSpan.Finish();

                    Sentry.FinalizeScope();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        TempAction: Record "NPR POS Action" temporary;
        POSSession: Codeunit "NPR POS Session";
        ClientDiagnostic: Record "NPR Client Diagnostic v2";
        UserLoginType: Enum "NPR User Login Type";
    begin
        _PageId := CreateGuid();
        POSSession.SetPageId(_PageId);
        POSSession.DebugWithTimestamp('Action discovery starts');
        TempAction.DiscoverActions();
        POSSession.DebugWithTimestamp('Action discovery ends');

        if ClientDiagnostic.Get(UserSecurityId(), UserLoginType::POS) then
            TempClientDiagnostic := ClientDiagnostic;
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

    local procedure CheckUserExpired()
    begin
        if TempClientDiagnostic."Expiration Message" = '' then
            exit;

        Message(TempClientDiagnostic."Expiration Message");
        PreventLoginIfUserIsExpired();
    end;

    local procedure PreventLoginIfUserIsExpired()
    var
        UserExpired: Label 'Your account has expired on %1. Expiration Message was: "%2". In order to continue, contact NaviPartner support or uninstall NP Retail extension.', Comment = '%1 = Expiration Date, %2 = Expiration Message';
    begin
        if TempClientDiagnostic."Expiry Date" = 0DT then
            exit;

        if CurrentDateTime >= TempClientDiagnostic."Expiry Date" then begin
            CurrPage.Close();
            Error(UserExpired, TempClientDiagnostic."Expiry Date", TempClientDiagnostic."Expiration Message");
        end;
    end;

    local procedure CheckUserLocked()
    begin
        if TempClientDiagnostic."Locked Message" = '' then
            exit;

        CurrPage.Close();
        Error(TempClientDiagnostic."Locked Message");
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        _POSBackgroundTaskManager.BackgroundTaskCompleted(TaskId, Results);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    begin
        _POSBackgroundTaskManager.BackgroundTaskError(TaskId, ErrorCode, ErrorText, ErrorCallStack, IsHandled);
    end;

    local procedure GetSentryTraceHeader(parameters: JsonObject): Text
    var
        SentryTraceHeaderToken: JsonToken;
    begin
        if not parameters.SelectToken('context.sentryTraceHeader', SentryTraceHeaderToken) then
            exit('');

        exit(SentryTraceHeaderToken.AsValue().AsText());
    end;

    var
        TempClientDiagnostic: Record "NPR Client Diagnostic v2" temporary;
        _PageId: Guid;
        _POSBackgroundTaskManager: Codeunit "NPR POS Backgr. Task Manager";
}

