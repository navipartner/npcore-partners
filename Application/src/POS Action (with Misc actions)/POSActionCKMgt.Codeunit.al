codeunit 6150854 "NPR POS Action - CK Mgt."
{
    Access = Internal;
    var
        ActionDescription: Label 'This is a built-in action for CashKeeper Payments';
        Setup: Codeunit "NPR POS Setup";
        CashkeeperNotFound: Label 'CashKeeper Setup for POS unit %3 was not found.';

    local procedure ActionCode(): Code[20]
    begin
        exit('CK_MANAGEMENT');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin

            Sender.RegisterWorkflowStep('1', 'respond();');
            Sender.RegisterWorkflow(false);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        OnInvokeDevice(POSSession);

        Handled := true;
    end;

    procedure OnInvokeDevice(POSSession: Codeunit "NPR POS Session")
    var
        CashKeeperRequest: DotNet NPRNetCashKeeperRequest0;
        State: DotNet NPRNetState4;
        StateEnum: DotNet NPRNetState_Action2;
        CashKeeperSetup: Record "NPR CashKeeper Setup";
        FrontEnd: Codeunit "NPR POS Front End Management";
        StepTxt: Text;
        POSUnit: Record "NPR POS Unit";
    begin
        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);

        if not CashKeeperSetup.Get(POSUnit."No.") then
            Error(CashkeeperNotFound, POSUnit."No.");

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Stargate Management", 'OnDeviceResponse', '', true, true)]
    local procedure OnDeviceResponse(ActionName: Text; Step: Text; Envelope: DotNet NPRNetResponseEnvelope0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        if (ActionName <> 'CK_MANAGEMENT') then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Stargate Management", 'OnAppGatewayProtocol', '', true, true)]
    local procedure OnDeviceEvent(ActionName: Text; EventName: Text; Data: Text; ResponseRequired: Boolean; var ReturnData: Text; var Handled: Boolean)
    begin
        if (ActionName <> 'CK_MANAGEMENT') then
            exit;

        Handled := true;
        case EventName of
            'CloseForm':
                CloseForm(Data);
        end;
    end;

    local procedure CloseForm(Data: Text)
    var
        State: DotNet NPRNetState4;
        POSSession: Codeunit "NPR POS Session";
        POSUnit: Record "NPR POS Unit";
        CashKeeperOverview: Record "NPR CashKeeper Overview";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        OverviewAmout: Integer;
    begin
        State := State.Deserialize(Data);

        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if (State.MessageText = 'CKOVERVIEW') then begin
            if Evaluate(OverviewAmout, State.StatusText) then begin
                CashKeeperOverview.Init();
                CashKeeperOverview."CashKeeper IP" := State.IP;
                CashKeeperOverview."Lookup Timestamp" := CurrentDateTime;
                CashKeeperOverview."Register No." := POSUnit."No.";
                CashKeeperOverview.Salesperson := SalePOS."Salesperson Code";
                CashKeeperOverview."Value In Cents" := OverviewAmout;
                if CashKeeperOverview."Value In Cents" > 0 then
                    CashKeeperOverview."Total Amount" := CashKeeperOverview."Value In Cents" / 100;
                CashKeeperOverview."User Id" := CopyStr(UserId, 1, MaxStrLen(CashKeeperOverview."User Id"));
                CashKeeperOverview.Insert(true);
            end;
        end;
    end;
}

