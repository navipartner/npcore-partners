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
                begin
                    FrameworkDragonGlass.Constructor(CurrPage.Framework);
                    _POSSession.Constructor(FrameworkDragonGlass, _FrontEnd, _Setup, _PageId);
                    _POSSession.DebugWithTimestamp('OnFrameworkReady');
                end;

                trigger OnInvokeMethod(method: Text; eventContext: JsonObject)
                begin
                    if method = 'KeepAlive' then
                        exit; //exit asap to minimize overhead of idle sessions       
                    if not _POSSession.AttachedToPageId(_PageId) then
                        Error(_SESSION_FINALIZED_ERROR);
                    _POSSession.DebugWithTimestamp('Method:' + method);
                    _JavaScript.InvokeMethod(method, eventContext, _POSSession, _FrontEnd, _JavaScript);
                end;

                trigger OnAction("action": Text; workflowStep: Text; workflowId: Integer; actionId: Integer; context: JsonObject)
                begin
                    if not _POSSession.AttachedToPageId(_PageId) then
                        Error(_SESSION_FINALIZED_ERROR);
                    _POSSession.DebugWithTimestamp('Action:' + action);
                    _JavaScript.InvokeAction(CopyStr(action, 1, 20), workflowStep, workflowId, actionId, context, _POSSession, _FrontEnd, _JavaScript);
                end;
            }
        }
    }

    trigger OnClosePage()
    begin
        _POSSession.ClearAll();
    end;

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

    var
        _Setup: Codeunit "NPR POS Setup";
        _POSSession: Codeunit "NPR POS Session";
        _JavaScript: Codeunit "NPR POS JavaScript Interface";
        _FrontEnd: Codeunit "NPR POS Front End Management";
        _SESSION_FINALIZED_ERROR: Label 'This POS window is no longer active.\This happens if you''ve opened the POS in a newer window. Please use that instead or reload this one.';
        _PageId: Guid;
}

