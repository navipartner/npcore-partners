codeunit 6150682 "NPR NPRE RVA: New WPad"
{
    Access = Internal;
    local procedure ActionCode(): Code[20]
    begin
        exit('RV_NEW_WAITER_PAD');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.3');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action");
    var
        ActionDescription: Label 'This built-in action creates a new waiter pad for the selected seating code.';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
              'let newWaiterpad = ' +
                '{"caption":"Welcome","title":"New Waiterpad","settings":[' +
                 '{"type":"plusminus","id":"guests","caption":"Number of Guests","minvalue":1,"maxvalue":100,"value":1},' +
                 '{"type":"text","id":"tablename","caption":"Name"},' +
                 ']' +
                '};' +
              '$context.waiterpadInfo = await popup.configuration (newWaiterpad);' +
              'await workflow.respond();');

            Sender.RegisterTextParameter('SeatingCode', '');
            Sender.RegisterBooleanParameter('SwitchToSaleView', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20(Action: Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        if Context.GetString('waiterpadInfo') = '' then
            exit;

        NewWaiterPad(POSSession, FrontEnd, Context);
    end;

    procedure NewWaiterPad(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: Codeunit "NPR POS JSON Management");
    var
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        NPREFrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SeatingCode: Code[20];
        Description: Text;
        NumberOfGuests: Integer;
        NotValidSettingErr: Label 'The provided seating code "%1" is invalid. A new waiterpad was not created.';
    begin
        SeatingCode := CopyStr(Context.GetStringParameterOrFail('SeatingCode', ActionCode()), 1, MaxStrLen(SeatingCode));

        if not Seating.Get(SeatingCode) then begin
            Message(NotValidSettingErr, SeatingCode);
            exit;
        end;

        Description := GetConfigurableOption(Context, 'waiterpadInfo', 'tablename');
        if not Evaluate(NumberOfGuests, GetConfigurableOption(Context, 'waiterpadInfo', 'guests')) then
            NumberOfGuests := 1;

        POSSession.GetSetup(Setup);
        WaiterPadMgt.CreateNewWaiterPad(Seating.Code, NumberOfGuests, Setup.Salesperson(), Description, WaiterPad);

        SeatingLocation.Get(Seating."Seating Location");
        NPREFrontendAssistant.RefreshWaiterPadData(POSSession, FrontEnd, SeatingLocation."Restaurant Code", '');
        NPREFrontendAssistant.RefreshWaiterPadContent(POSSession, FrontEnd, WaiterPad."No.");

        if Context.GetBooleanParameter('SwitchToSaleView') then begin
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            SalePOS.Find();
            SalePOS."NPRE Number of Guests" := NumberOfGuests;
            SalePOS."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
            SalePOS.Validate("NPRE Pre-Set Seating Code", SeatingCode);
            POSSale.Refresh(SalePOS);
            POSSale.Modify(true, false);

            SelectSalesView(POSSession);
        end;
        POSSession.RequestRefreshData();
    end;

    local procedure SelectSalesView(POSSession: Codeunit "NPR POS Session");
    begin
        POSSession.ChangeViewSale();
    end;

    local procedure GetConfigurableOption(Context: Codeunit "NPR POS JSON Management"; Scope: Text; "Key": Text): Text;
    begin
        Context.SetScopeRoot();

        if (not Context.SetScope(Scope)) then
            exit('');

        exit(Context.GetString("Key"))
    end;
}
