page 6150700 "NPR POS (Transcendence)"
{
    Caption = 'POS';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            usercontrol(Framework; "NPR Transcendence")
            {
                ApplicationArea = All;

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
                    if not PreHandleMethod(method, eventContext) then
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

    var
        WarningMessageText1: Label 'You have accessed the old discontinued POS page.\\If you are using Major Tom, please make sure to either configure it to use Dragonglass framework, or upgrade to Major Tom 6.3.';
        WarningMessageText2: Label '\If you are accessing this page directly through the browser, then please update your bookmarks to access page 6150750 instead.';
        WarningMessageText3: Label '\\Would you like us to take you directly to the new POS page?';

    trigger OnClosePage()
    begin
        Finalize();
    end;

    trigger OnOpenPage()
    var
        "Action": Record "NPR POS Action" temporary;
    begin
        if Confirm(WarningMessageText1 + WarningMessageText2 + WarningMessageText3) then begin
            Page.Run(Page::"NPR POS (Dragonglass)"); // Page 6150750
            CurrPage.Close();
        end;

        POSSession.DebugWithTimestamp('Action discovery starts');
        Action.SetSession(POSSession);
        Action.DiscoverActions();
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

    local procedure PreHandleMethod(Method: Text; Context: JsonObject): Boolean
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
