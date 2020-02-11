codeunit 6150875 "POS Action - Raptor"
{
    // NPR5.51/CLVA/20190710  CASE 355871 Object created
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements + use workflow 2.0


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'An action to run Raptor integration functions';

    local procedure ActionCode(): Text
    begin
        exit ('RAPTOR');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('2.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction20(
              ActionCode,
              ActionDescription,
              ActionVersion)
          then begin
            RegisterWorkflow20('await workflow.respond();');
            RegisterTextParameter('RaptorActionCode','');
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "POS Action";WorkflowStep: Text;Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";State: Codeunit "POS Workflows 2.0 - State";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        RaptorAction: Record "Raptor Action";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        RaptorMgt: Codeunit "Raptor Management";
        RaptorActionCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");

        RaptorActionCode := Context.GetStringParameter('RaptorActionCode',false);
        if RaptorActionCode <> '' then
          RaptorAction.Get(RaptorActionCode)
        else
          if not RaptorMgt.SelectRaptorAction('',false,RaptorAction) then
            Error('');
        RaptorMgt.ShowRaptorData(RaptorAction,SalePOS."Customer No.");
    end;
}

