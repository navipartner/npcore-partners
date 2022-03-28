codeunit 6059817 "NPR POS Action: Turnover Stats"
{
    Access = Internal;
    local procedure ActionCode(): Text[20]
    begin
        exit('TURNOVER_STATS');
    end;

    local procedure ActionVersion(): Code[10]
    begin

        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescription: Label 'This built-in action opens Turnover Statistics page.';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20('await workflow.respond();');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSUnitNo: Code[10];
        POSStoreCode: Code[10];
        POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer";
        POSStatisticsMgt: Codeunit "NPR POS Statistics Mgt.";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        GetPOSInfo(POSSession, POSStoreCode, POSUnitNo);

        POSStatisticsMgt.FillTurnoverData(POSTurnoverCalcBuffer, WorkDate(), POSStoreCode, POSUnitNo);
        Page.RunModal(Page::"NPR POS Turnover", POSTurnoverCalcBuffer);
    end;

    local procedure GetPOSInfo(POSSession: Codeunit "NPR POS Session"; var POSStoreCode: Code[10]; var POSUnitNo: Code[10])
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSStore: Record "NPR POS Store";
    begin
        POSSession.GetSetup(POSSetup);

        POSSetup.GetPOSStore(POSStore);
        POSStoreCode := POSStore.Code;

        POSUnitNo := POSSetup.GetPOSUnitNo();
    end;
}