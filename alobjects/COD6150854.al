codeunit 6150854 "POS Action - CK Management"
{
    // NPR5.43/CLVA/20180613 CASE 319114 Object created
    // NPR5.43/CLVA/20180620 CASE 319764 Collecting CashKeeper overview info


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for CashKeeper Payments';
        Setup: Codeunit "POS Setup";
        TextAmountLabel: Label 'Enter Amount:';
        PaymentTypeNotFound: Label '%1 %2 for register %3 was not found.';
        CashkeeperNotFound: Label 'CashKeeper Setup for register %3 was not found.';
        NoCashBackErr: Label 'It is not allowed to enter an amount that is bigger than what is stated on the receipt for this payment type';
        RequestNotFound: Label 'Action Code %1 tried retrieving "TransactionRequest_EntryNo" from POS Session and got %2. There is however no record in %3 to match that entry number.';
        NoNegativeCashBackErr: Label 'It is not allowed to enter an amount that is different from what is stated on the receipt for this payment type';
        NegativeCashBackErr: Label 'It is not allowed to enter an negative amount';

    local procedure ActionCode(): Text
    begin
        exit ('CK_MANAGEMENT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin

          Sender.RegisterWorkflowStep('1','respond();');
          Sender.RegisterWorkflow(false);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ObjectId: Integer;
        ObjectType: Integer;
        MenuFilterCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        OnInvokeDevice(POSSession);

        Handled := true;
    end;

    local procedure "--Stargate"()
    begin
    end;

    procedure OnInvokeDevice(POSSession: Codeunit "POS Session")
    var
        CashKeeperRequest: DotNet CashKeeperRequest0;
        State: DotNet State4;
        StateEnum: DotNet State_Action2;
        CashKeeperSetup: Record "CashKeeper Setup";
        FrontEnd: Codeunit "POS Front End Management";
        StepTxt: Text;
        Register: Record Register;
    begin
        POSSession.GetSetup (Setup);
        Setup.GetRegisterRecord(Register);

        if not CashKeeperSetup.Get(Register."Register No.") then
          Error(CashkeeperNotFound,Register."Register No.");

        State := State.State();
        State.ActionType := StateEnum.Setup;
        StepTxt := 'Setup';

        if not CashKeeperSetup."Debug Mode" then begin
          CashKeeperSetup.TestField("CashKeeper IP");
          State.IP := CashKeeperSetup."CashKeeper IP";
        end else
          State.IP := 'localhost';

        CashKeeperRequest := CashKeeperRequest.CashKeeperRequest();
        CashKeeperRequest.State := State;

        FrontEnd.InvokeDevice(CashKeeperRequest, 'CK_MANAGEMENT', StepTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnDeviceResponse', '', true, true)]
    local procedure OnDeviceResponse(ActionName: Text;Step: Text;Envelope: DotNet ResponseEnvelope0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
        if (ActionName <> 'CK_MANAGEMENT') then
          exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnAppGatewayProtocol', '', true, true)]
    local procedure OnDeviceEvent(ActionName: Text;EventName: Text;Data: Text;ResponseRequired: Boolean;var ReturnData: Text;var Handled: Boolean)
    var
        FrontEnd: Codeunit "POS Front End Management";
    begin
        if (ActionName <> 'CK_MANAGEMENT') then
          exit;

        Handled := true;
        //-NPR5.43 [319764]
        case EventName of
          'CloseForm': CloseForm(Data);
        end;
        //+NPR5.43 [319764]
    end;

    local procedure "--- Protocol Events"()
    begin
    end;

    local procedure CloseForm(Data: Text)
    var
        State: DotNet State4;
        FrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        Register: Record Register;
        CashKeeperOverview: Record "CashKeeper Overview";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        OverviewAmout: Integer;
    begin
        State := State.Deserialize(Data);

        POSSession.GetSetup(Setup);
        Setup.GetRegisterRecord(Register);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if (State.MessageText = 'CKOVERVIEW') then begin
          if Evaluate(OverviewAmout,State.StatusText) then begin
            CashKeeperOverview.Init;
            CashKeeperOverview."CashKeeper IP" := State.IP;
            CashKeeperOverview."Lookup Timestamp" := CurrentDateTime;
            CashKeeperOverview."Register No." := Register."Register No.";
            CashKeeperOverview.Salesperson := SalePOS."Salesperson Code";
            CashKeeperOverview."Value In Cents" := OverviewAmout;
            if CashKeeperOverview."Value In Cents" > 0 then
              CashKeeperOverview."Total Amount" := CashKeeperOverview."Value In Cents" / 100;
            CashKeeperOverview."User Id" := UserId;
            CashKeeperOverview.Insert(true);
          end;
        end;
    end;
}

