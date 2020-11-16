page 6150700 "NPR POS (Transcendence)"
{
    // NPR5.38/MHA /20180108  CASE 298399 Added Publisher OnOpenPOSTranscendence()
    // NPR5.40/VB  /20180213 CASE 306347 Performance improvement due to physical-table action discovery.
    //                                   Rolling back changes from NPR5.38/MHA /20180108  CASE 298399, due to substantial performance degradation in demo.
    // NPR5.41/MMV /20180410 CASE 307453 Changed implementation of 304310 to prevent double POS menu parse on first initialization.
    // NPR5.43/MMV /20180606 CASE 318028 Refactored initialization and finalization.

    Caption = 'POS';
    PageType = List;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            usercontrol(Framework; "NPR Transcendence")
            {
                ApplicationArea = All;

                trigger OnFrameworkReady()
                begin
                    //-NPR5.43 [318028]
                    if POSSession.IsFinalized() then
                        exit;
                    //+NPR5.43 [318028]
                    POSSession.DebugWithTimestamp('OnFrameworkReady');
                    Initialize();
                end;

                trigger OnInvokeMethod(method: Text; eventContext: JsonObject)
                begin
                    //-NPR5.43 [318028]
                    if POSSession.IsFinalized() then
                        exit;
                    //+NPR5.43 [318028]
                    POSSession.DebugWithTimestamp('Method:' + method);
                    if not PreHandleMethod(method, eventContext) then
                        JavaScript.InvokeMethod(method, eventContext, POSSession, FrontEnd, JavaScript);
                end;

                trigger OnAction("action": Text; workflowStep: Text; workflowId: Integer; actionId: Integer; Context: JsonObject)
                begin
                    //-NPR5.43 [318028]
                    if POSSession.IsFinalized() then
                        Error(SESSION_FINALIZED_ERROR);
                    //+NPR5.43 [318028]
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
        "Action": Record "NPR POS Action" temporary;
    begin
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
        Framework: Codeunit "NPR Framework: Transcendence";
    begin
        //-NPR5.43 [318028]
        // FrontEnd.Initialize(CurrPage.Framework,POSSession);
        // POSSession.InitializeCodeunit(FrontEnd,Setup,POSSession);
        // POSSession.DebugWithTimestamp('Page6150700 initialization first stage completed');
        //
        // FrontEndKeeper.Initialize(CurrPage.Framework,FrontEnd,POSSession);
        // BINDSUBSCRIPTION(FrontEndKeeper);
        Framework.Constructor(CurrPage.Framework);
        POSSession.Constructor(Framework, FrontEnd, Setup, POSSession);
        //+NPR5.43 [318028]
    end;

    local procedure Finalize()
    begin
        //-NPR5.43 [318028]
        // IF NOT Finalized THEN BEGIN
        //  Finalized := TRUE;
        //  UNBINDSUBSCRIPTION(FrontEndKeeper);
        // END;

        POSSession.Destructor();
        //+NPR5.43 [318028]
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

