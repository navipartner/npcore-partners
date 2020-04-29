page 6150750 "POS (Dragonglass)"
{
    // NPR5.53/VB  /20191218 CASE 331640 Page created as an exact copy of page 6150700, except that it used the Dragonglass control add-in, instead of Transcendence

    Caption = 'POS';
    PageType = List;

    layout
    {
        area(content)
        {
            usercontrol(Framework;"NaviPartner.Retail.Controls.Dragonglass")
            {

                trigger OnFrameworkReady()
                begin
                    if POSSession.IsFinalized() then
                      exit;
                    POSSession.DebugWithTimestamp('OnFrameworkReady');
                    Initialize();
                end;

                trigger OnInvokeMethod(method: Text;eventContent: Variant)
                begin
                    if POSSession.IsFinalized() then
                      exit;
                    POSSession.DebugWithTimestamp('Method:' + method);
                    if not PreHandleMethod(method,eventContent) then
                      JavaScript.InvokeMethod(method,eventContent,POSSession,FrontEnd);
                end;

                trigger OnAction("action": Text;workflowStep: Text;workflowId: Integer;actionId: Integer;context: Variant)
                begin
                    if POSSession.IsFinalized() then
                      Error(SESSION_FINALIZED_ERROR);
                    POSSession.DebugWithTimestamp('Action:' + action);
                    JavaScript.InvokeAction(action,workflowStep,workflowId,actionId,context,POSSession,FrontEnd);
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
        POSSession.Constructor(CurrPage.Framework,FrontEnd,Setup,POSSession);
    end;

    local procedure Finalize()
    begin
        POSSession.Destructor();
    end;

    local procedure "--- Low-level method handling ---"()
    begin
    end;

    local procedure PreHandleMethod(Method: Text;Context: DotNet npNetJObject): Boolean
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

