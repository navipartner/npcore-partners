codeunit 6150681 "NPR NPRE RVA: Set R-View"
{
    local procedure ActionCode(): Text;
    begin
        exit('RV_SET_R-VIEW');
    end;

    local procedure ActionVersion(): Text;
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action");
    var
        ActionDescription: Label 'This built-in action saves currently selected items to Waiter Pad and switches to the Restaurant View';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20('await workflow.respond();');

            Sender.RegisterBooleanParameter('ReturnToDefaultEndOfSaleView', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20(Action: Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        SaveToWaiterPad(POSSession, FrontEnd);
        SelectRestaurantView(POSSession, FrontEnd, Context);
        POSSession.RequestRefreshData();
    end;

    local procedure SaveToWaiterPad(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management");
    var
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."NPRE Pre-Set Waiter Pad No." = '' then
            exit;

        NPREWaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
        NPREWaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, NPREWaiterPad, true);

        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
    end;

    local procedure SelectRestaurantView(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: Codeunit "NPR POS JSON Management");
    var
        POSSale: Codeunit "NPR POS Sale";
    begin
        if Context.GetBooleanParameter('ReturnToDefaultEndOfSaleView') then begin
            POSSession.GetSale(POSSale);
            POSSale.SelectViewForEndOfSale(POSSession);
        end else
            POSSession.ChangeViewRestaurant();
    end;
}