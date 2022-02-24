codeunit 6059785 "NPR POS Action: Check Avail."
{
    Access = Internal;

    var
        ActionDescription: Label 'This built-in action checks availability of items included in a POS sale.';

    local procedure ActionCode(): Code[20]
    begin
        exit('ITEM_AVAILABILITY');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction20(
            ActionCode(),
            ActionDescription,
            ActionVersion())
        then begin
            Sender.RegisterWorkflow20('');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        POSSale: Codeunit "NPR POS Sale";
        AllInStockMsg: Label 'All items are in stock.';
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        Clear(PosItemCheckAvail);
        BindSubscription(PosItemCheckAvail);
        PosItemCheckAvail.SetIgnoreProfile(true);
        PosItemCheckAvail.CheckAvailability_PosSale(SalePOS, false);
        if not PosItemCheckAvail.GetAvailabilityIssuesFound() then
            Message(AllInStockMsg);
        UnbindSubscription(PosItemCheckAvail);
    end;
}