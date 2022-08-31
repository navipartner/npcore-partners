codeunit 6059870 "NPR POS Action: Cur Sale Stats"
{
    Access = Internal;
    local procedure ActionCode(): Text[20]
    begin
        exit('CURRENT_SALE_STATS');
    end;

    local procedure ActionVersion(): Code[10]
    begin

        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescription: Label 'This built-in action opens page with current sale statistics.';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20('await workflow.respond();');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSSale: Record "NPR POS Sale";
        SalePOS: Codeunit "NPR POS Sale";
        POSCurrentStatsBuffer: Record "NPR POS Single Stats Buffer";
        POSStatisticsMgt: Codeunit "NPR POS Statistics Mgt.";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        POSSession.GetSale(SalePOS);
        SalePOS.GetCurrentSale(POSSale);

        POSStatisticsMgt.FillCurrentStatsBuffer(POSCurrentStatsBuffer, POSSale);
        Page.RunModal(Page::"NPR POS Current Sale Stats", POSCurrentStatsBuffer);
    end;
}