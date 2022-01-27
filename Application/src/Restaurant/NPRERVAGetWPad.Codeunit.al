codeunit 6150680 "NPR NPRE RVA: Get WPad"
{
    Access = Internal;
    var
        NotFoundErr: Label 'The waiter pad "%1", was not found.';

    local procedure ActionCode(): Code[20]
    begin
        exit('RV_GET_WAITER_PAD');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action");
    var
        ActionDescription: Label 'This built-in action transfer provided Waiter Pad to POS Sale and selects sales view';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20('await workflow.respond();');

            Sender.RegisterTextParameter('WaiterPadCode', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20(Action: Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        WaiterPadCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        WaiterPadCode := CopyStr(Context.GetStringParameterOrFail('WaiterPadCode', ActionCode()), 1, MaxStrLen(WaiterPadCode));

        LoadWaiterPad(POSSession, FrontEnd, WaiterPadCode);
        SelectSalesView(POSSession);
    end;

    procedure LoadWaiterPad(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; WaiterPadCode: Code[20]);
    var
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        if not NPREWaiterPad.Get(WaiterPadCode) then begin
            Message(NotFoundErr, WaiterPadCode);
            exit;
        end;

        NPREWaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(NPREWaiterPad, POSSession);
        POSSession.RequestRefreshData();
    end;

    procedure RequestWaiterPad(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; WaiterPadCode: Code[20]);
    var
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPREFrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
    begin
        if not NPREWaiterPad.Get(WaiterPadCode) then begin
            Message(NotFoundErr, WaiterPadCode);
            exit;
        end;

        NPREFrontendAssistant.RefreshWaiterPadContent(POSSession, FrontEnd, WaiterPadCode);
    end;

    local procedure SelectSalesView(POSSession: Codeunit "NPR POS Session");
    begin
        POSSession.ChangeViewSale();
    end;
}
