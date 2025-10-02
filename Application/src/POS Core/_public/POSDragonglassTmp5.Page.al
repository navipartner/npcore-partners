#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22 and not BC23 and not BC24 and not BC25 
page 6185121 "NPR POS (Dragonglass) Tmp5"
{
    Caption = '[Testing purposes only] : UserControlHost';
    PageType = UserControlHost;
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
                begin
                    if method = 'KeepAlive' then begin //every couple of minutes to prevent NST from shutting down idle POS sessions
                        Response.Add('RequestID', requestId);
                        Response.Add('Success', true);
                        CurrPage.Framework.ControlAddinResponse(Response);
                        exit;
                    end;
                    if method = 'FrameworkReady' then begin //once when POS frontend has loaded
                        POSBackgroundTaskAPI.Initialize(_POSBackgroundTaskManager);
                        POSSession.Constructor(POSBackgroundTaskAPI);
                        CheckUserLocked();
                        CheckUserExpired();
                        if POSSession.GetErrorOnInitialize() then begin
                            CurrPage.Close();
                            Error(GetLastErrorText());
                        end;

                        Response.Add('RequestID', requestId);
                        Response.Add('Success', true);
                        CurrPage.Framework.ControlAddinResponse(Response);
                        exit;
                    end;

                    POSSession.ErrorIfPageIdMismatch(_PageId);

                    POSSession.PopResponseQueue();
                    _POSBackgroundTaskManager.ClearQueues();

                    BindSubscription(POSPageStackCheck);

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

                    if not Success then begin
                        Error(GetLastErrorText());
                    end;

                    ProcessBackgroundTaskQueues();
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

    var
        TempClientDiagnostic: Record "NPR Client Diagnostic v2" temporary;
        _PageId: Guid;
        _POSBackgroundTaskManager: Codeunit "NPR POS Backgr. Task Manager";
}

#endIf