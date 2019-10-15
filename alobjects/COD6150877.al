codeunit 6150877 "POS Action - Hardware Connect"
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
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    var
        HardwareConnectorMgt: Codeunit "Hardware Connector Mgt.";
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
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: Codeunit "POS JSON Management"; POSSession: Codeunit "POS Session"; State: Codeunit "POS Workflows 2.0 - State"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
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
        POSSession: Codeunit "POS Session";
        POSFrontEndManagement: Codeunit "POS Front End Management";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEndManagement, true);

        POSFrontEndManagement.QueueWorkflow(ActionCode(), '"Handler": "' + Handler + '", "Content": ' + Content + '');
    end;
}

