page 6150700 "NPR POS (Transcendence)"
{
    Caption = 'POS';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            usercontrol(Framework; "NPR Transcendence")
            {
                ApplicationArea = NPRRetail;


                trigger OnFrameworkReady()
                begin
                    if POSSession.IsFinalized() then
                        exit;
                    POSSession.DebugWithTimestamp('OnFrameworkReady');
                    Initialize();
                end;

                trigger OnInvokeMethod(method: Text; eventContext: JsonObject)
                begin
                    if POSSession.IsFinalized() then
                        exit;
                    POSSession.DebugWithTimestamp('Method:' + method);
                    if not PreHandleMethod(method) then
                        JavaScript.InvokeMethod(method, eventContext, POSSession, FrontEnd, JavaScript);
                end;

                trigger OnAction("action": Text; workflowStep: Text; workflowId: Integer; actionId: Integer; Context: JsonObject)
                begin
                    if POSSession.IsFinalized() then
                        Error(SESSION_FINALIZED_ERROR);
                    POSSession.DebugWithTimestamp('Action:' + action);
                    JavaScript.InvokeAction(action, workflowStep, workflowId, actionId, Context, POSSession, FrontEnd, JavaScript);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnClosePage()
    begin
        Finalize();
    end;

    trigger OnOpenPage()
    var
        TempAction: Record "NPR POS Action" temporary;
    begin
        POSSession.DebugWithTimestamp('Action discovery starts');
        TempAction.SetSession(POSSession);
        TempAction.DiscoverActions();
        POSSession.DebugWithTimestamp('Action discovery ends');
    end;

    var
        Setup: Codeunit "NPR POS Setup";
        POSSession: Codeunit "NPR POS Session";
        JavaScript: Codeunit "NPR POS JavaScript Interface";
        FrontEnd: Codeunit "NPR POS Front End Management";
        SESSION_FINALIZED_ERROR: Label 'This POS window is no longer active.\This happens if you''ve opened the POS in a newer window. Please use that instead or reload this one.';

    local procedure Initialize()
    var
        FrameworkTranscendence: Codeunit "NPR Framework: Transcendence";
    begin
        FrameworkTranscendence.Constructor(CurrPage.Framework);
        POSSession.Constructor(FrameworkTranscendence, FrontEnd, Setup, POSSession);
    end;

    local procedure Finalize()
    begin
        POSSession.Destructor();
    end;

    local procedure PreHandleMethod(Method: Text): Boolean
    begin
        case Method of
            'KeepAlive':
                exit(true);
            'CloseRequested':
                exit(CloseRequested());
            'InitializationComplete':
                exit(InitializationComplete());
        end;
    end;

    local procedure CloseRequested(): Boolean
    begin
        Finalize();
        exit(true);
    end;

    local procedure InitializationComplete(): Boolean
    begin
        POSSession.DebugWithTimestamp('InitializeUI');
        POSSession.InitializeUI();
        POSSession.DebugWithTimestamp('InitializeSession');
        POSSession.InitializeSession(false);
        exit(true);
    end;
}
