codeunit 6150875 "POS Action - Raptor"
{
    // NPR5.51/CLVA/20190710  CASE 355871 Object created


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for running a report';
        Model: DotNet npNetModel;
        ActiveModelID: Guid;
        TransactionDone: Boolean;

    local procedure ActionCode(): Text
    begin
        exit('RAPTOR');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('1', 'respond();');
                RegisterWorkflow(false);
                RegisterOptionParameter('RaptorAction', 'GetUserIdOrderHistory', 'GetUserIdOrderHistory');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        RaptorActionSetting: Option GetUserIdOrderHistory;
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        JSONString: Text;
        RaptorAPI: Codeunit "Raptor API";
        Result: Text;
        RaptorHelperFunctions: Codeunit "Raptor Helper Functions";
        JArray: DotNet JArray;
        JObject: DotNet JObject;
        ErrorMsg: Text;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        InitState();

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);

        RaptorActionSetting := JSON.GetInteger('RaptorAction', true);

        case RaptorActionSetting of
            RaptorActionSetting::GetUserIdOrderHistory:
                begin
                    if SalePOS."Customer No." <> '' then begin

                        //Test customer value 27154950
                        Result := RaptorAPI.GetUserIdOrderHistory(SalePOS."Customer No.", ErrorMsg);

                        if ErrorMsg = '' then begin

                            //>> Sample for reading result from Raptor
                            RaptorHelperFunctions.TryParse(Result, JArray);

                            foreach JObject in JArray do begin
                                Message(RaptorHelperFunctions.GetValueAsText(JObject, 'ProductId') + ' , ' + Format(RaptorHelperFunctions.GetValueAsDate(JObject, 'Orderdate')));
                            end;
                            //<< Sample for reading result from Raptor
                        end;
                    end;
                end;
        end;

        Handled := true;
    end;

    local procedure InitState()
    begin
        Clear(Model);
        Clear(ActiveModelID);
        Clear(TransactionDone);
    end;
}

