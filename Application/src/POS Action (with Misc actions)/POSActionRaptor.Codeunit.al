codeunit 6150875 "NPR POS Action: Raptor"
{
    // NPR5.51/CLVA/20190710 CASE 355871 Object created
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements + use workflow 2.0
    // NPR5.54/ALPO/20200406 CASE 399189 Enable lookup and valide for parameter RaptorActionCode
    // NPR5.54/ALPO/10200417 CASE 400510 As WF2.0 is not fully supported on Transcendence, a workaround done for the time being


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'An action to run Raptor integration functions';

    local procedure ActionCode(): Text
    begin
        exit('RAPTOR');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('2.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction20(
                ActionCode,
                ActionDescription,
                ActionVersion)
            then begin
                //RegisterWorkflow20('await workflow.respond();');  //NPR5.54 [400510]-revoked
                //-NPR5.54 [400510]
                RegisterWorkflow20(
                  'await workflow.respond(); ' +
                  'if ($context.ActionFailed) {if ($context.ActionFailReasonMsg.length > 0) {await popup.message($context.ActionFailReasonMsg);};}');
                //+NPR5.54 [400510]
                RegisterTextParameter('RaptorActionCode', '');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        RaptorAction: Record "NPR Raptor Action";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        RaptorMgt: Codeunit "NPR Raptor Management";
        RaptorActionCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;
        Handled := true;

        //-NPR5.54 [400510]
        if not TryToRunAction(Action, Context, POSSession) then begin
            Context.SetContext('ActionFailed', true);
            Context.SetContext('ActionFailReasonMsg', GetLastErrorText);
        end;
        //+NPR5.54 [400510]
        //-NPR5.54 [400510]-revoked
        /*
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TESTFIELD("Customer No.");
        
        RaptorActionCode := Context.GetStringParameter('RaptorActionCode',FALSE);
        IF RaptorActionCode <> '' THEN
          RaptorAction.GET(RaptorActionCode)
        ELSE
          IF NOT RaptorMgt.SelectRaptorAction('',FALSE,RaptorAction) THEN
            ERROR('');
        RaptorMgt.ShowRaptorData(RaptorAction,SalePOS."Customer No.");
        */
        //+NPR5.54 [400510]-revoked

    end;

    [TryFunction]
    local procedure TryToRunAction("Action": Record "NPR POS Action"; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        RaptorAction: Record "NPR Raptor Action";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        RaptorMgt: Codeunit "NPR Raptor Management";
        RaptorActionCode: Code[20];
    begin
        //-NPR5.54 [400510]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");

        RaptorActionCode := Context.GetStringParameter('RaptorActionCode', false);
        if RaptorActionCode <> '' then
            RaptorAction.Get(RaptorActionCode)
        else
            if not RaptorMgt.SelectRaptorAction('', false, RaptorAction) then
                Error('');
        RaptorMgt.ShowRaptorData(RaptorAction, SalePOS."Customer No.");
        //+NPR5.54 [400510]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        RaptorAction: Record "NPR Raptor Action";
    begin
        //-NPR5.54 [399189]
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'RaptorActionCode':
                begin
                    if POSParameterValue.Value <> '' then begin
                        RaptorAction.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(RaptorAction.Code));
                        if RaptorAction.Find('=><') then;
                    end;
                    if PAGE.RunModal(0, RaptorAction) = ACTION::LookupOK then
                        POSParameterValue.Value := RaptorAction.Code;
                end;
        end;
        //+NPR5.54 [399189]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        RaptorAction: Record "NPR Raptor Action";
    begin
        //-NPR5.54 [399189]
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'RaptorActionCode':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    RaptorAction.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(RaptorAction.Code));
                    RaptorAction.Find;
                end;
        end;
        //+NPR5.54 [399189]
    end;
}

