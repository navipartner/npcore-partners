codeunit 6150877 "NPR POS Action: HardwareConn."
{
    // NPR5.51/MMV /20190812 CASE 360975 Created object


    trigger OnRun()
    begin
    end;

    var
        ACTION_DESC: Label 'Action for sending hardware requests';

    local procedure ActionCode(): Text
    begin
        exit('HARDWARE_CONNECTOR');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.00');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        HardwareConnectorMgt: Codeunit "NPR Hardware Connector Mgt.";
    begin
        if Sender.DiscoverAction20(
          ActionCode(),
          ACTION_DESC,
          ActionVersion())
        then begin
            Sender.RegisterWorkflow20(
              HardwareConnectorMgt.GetSocketClientScript() +
              'let hardwareResponse = await window._np_hardware_connector.sendRequestAndWaitForResponseAsync($context.Handler, $context.Content);' +
              'workflow.respond("response", { result: hardwareResponse } );'
            );
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JToken: JsonToken;
        Success: Boolean;
        DummyJsonToken: JsonToken;
    begin
        if Action.Code <> ActionCode() then
            exit;

        Handled := true;

        case WorkflowStep of
            'response':
                begin
                    Context.GetJToken(JToken, 'result', true);
                    Success := JToken.AsObject().Get('success', DummyJsonToken);
                    if not Success then begin
                        JToken.AsObject().Get('errorText', DummyJsonToken);
                        Error(DummyJsonToken.AsValue().AsText());
                    end;
                end;
        end;
    end;

    procedure QueueRequest(Handler: Text; Content: Text)
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);

        POSFrontEndManagement.QueueWorkflow(ActionCode(), '"Handler": "' + Handler + '", "Content": ' + Content + '');
    end;
}

