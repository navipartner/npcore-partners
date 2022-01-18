codeunit 6059773 "NPR POS Action: Item Variants"
{
    local procedure ActionCode(): Text[20]
    begin
        exit('ITEM_VARIANTS');
    end;

    local procedure ActionVersion(): Code[10]
    begin

        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescription: Label 'This built-in action opens Item Variants page with calculated inventory for current location.';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20('await workflow.respond();');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSStore: Record "NPR POS Store";
        POSSetup: Codeunit "NPR POS Setup";
        ItemVariants: Page "NPR Item Variants";
    begin

        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSStore(POSStore);
        ItemVariants.SetLocationCodeFilter(POSStore."Location Code");
        ItemVariants.LookupMode(true);
        ItemVariants.Run();
    end;
}