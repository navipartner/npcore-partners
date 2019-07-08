page 6150700 "POS (New)"
{
    // NPR5.38/MHA /20180108  CASE 298399 Added Publisher OnOpenPOSTranscendence()
    // NPR5.40/VB  /20180213 CASE 306347 Performance improvement due to physical-table action discovery.
    //                                   Rolling back changes from NPR5.38/MHA /20180108  CASE 298399, due to substantial performance degradation in demo.
    // NPR5.41/MMV /20180410 CASE 307453 Changed implementation of 304310 to prevent double POS menu parse on first initialization.
    // NPR5.43/MMV /20180606 CASE 318028 Refactored initialization and finalization.

    Caption = 'POS';
    PageType = List;

    layout
    {
        area(content)
        {
            usercontrol(Framework;"NaviPartner.Retail.Controls.Framework")
            {

                trigger OnFrameworkReady()
                begin
                    //-NPR5.43 [318028]
                    if POSSession.IsFinalized() then
                      exit;
                    //+NPR5.43 [318028]
                    POSSession.DebugWithTimestamp('OnFrameworkReady');
                    Initialize();
                end;

                trigger OnInvokeMethod(method: Text;eventContext: DotNet JObject)
                begin
                    //-NPR5.43 [318028]
                    if POSSession.IsFinalized() then
                      exit;
                    //+NPR5.43 [318028]
                    POSSession.DebugWithTimestamp('Method:' + method);
                    if not PreHandleMethod(method,eventContext) then
                      JavaScript.InvokeMethod(method,eventContext,POSSession,FrontEnd);
                end;

                trigger OnAction("action": Text;workflowStep: Text;workflowId: Integer;actionId: Integer;Context: DotNet JObject)
                begin
                    //-NPR5.43 [318028]
                    if POSSession.IsFinalized() then
                      Error(SESSION_FINALIZED_ERROR);
                    //+NPR5.43 [318028]
                    POSSession.DebugWithTimestamp('Action:' + action);
                    JavaScript.InvokeAction(action,workflowStep,workflowId,actionId,Context,POSSession,FrontEnd);
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
        "Action": Record "POS Action" temporary;
    begin
        POSSession.DebugWithTimestamp('Action discovery starts');
        Action.SetSession(POSSession);
        Action.DiscoverActions();
        POSSession.DebugWithTimestamp('Action discovery ends');
    end;

    var
        Setup: Codeunit "POS Setup";
        POSSession: Codeunit "POS Session";
        JavaScript: Codeunit "POS JavaScript Interface";
        FrontEnd: Codeunit "POS Front End Management";
        SESSION_FINALIZED_ERROR: Label 'This POS window is no longer active.\This happens if you''ve opened the POS in a newer window. Please use that instead or reload this one.';

    local procedure Initialize()
    begin
        //-NPR5.43 [318028]
        // FrontEnd.Initialize(CurrPage.Framework,POSSession);
        // POSSession.InitializeCodeunit(FrontEnd,Setup,POSSession);
        // POSSession.DebugWithTimestamp('Page6150700 initialization first stage completed');
        //
        // FrontEndKeeper.Initialize(CurrPage.Framework,FrontEnd,POSSession);
        // BINDSUBSCRIPTION(FrontEndKeeper);

        POSSession.Constructor(CurrPage.Framework,FrontEnd,Setup,POSSession);
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

    local procedure "--- Low-level method handling ---"()
    begin
    end;

    local procedure PreHandleMethod(Method: Text;Context: DotNet JObject): Boolean
    begin
        case Method of
          'KeepAlive':              exit(true);
          'CloseRequested':         exit(CloseRequested());
          'InitializationComplete': exit(InitializationComplete());
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

