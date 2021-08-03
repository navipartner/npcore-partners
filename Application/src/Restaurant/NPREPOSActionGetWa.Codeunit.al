codeunit 6150667 "NPR NPRE POSAction: Get Wa."
{
    var
        Text000: Label 'Transfer Waiter Pad to POS Sale';
        ConfirmTableCaption: Label 'Are you sure you want to retrieve from %1?';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Code[20]
    begin
        exit('GET_WAITER_PAD');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          Text000,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('addPresetValuesToContext', 'respond();');
            Sender.RegisterWorkflowStep('seatingInput',
              'if (param.FixedSeatingCode) {' +
              '  context.seatingCode = param.FixedSeatingCode;' +
              '  respond();' +
              '} else {' +
              '  switch(param.InputType + "") {' +
              '    case "0":' +
              '      stringpad(labels["InputTypeLabel"]).respond("seatingCode");' +
              '      break;' +
              '    case "1":' +
              '      intpad(labels["InputTypeLabel"]).respond("seatingCode");' +
              '      break;' +
              '    case "2":' +
              '      respond();' +
              '      break;' +
              '  }' +
              '}'
            );
            Sender.RegisterWorkflowStep('selectWaiterPad',
              'if (context.seatingCode) {' +
              '  respond();' +
              '}'
            );
            Sender.RegisterWorkflowStep('getSaleFromPad',
              'if (context.waiterPadNo) {' +
              '  respond();' +
              '}'
            );
            Sender.RegisterWorkflow(false);

            Sender.RegisterOptionParameter('InputType', 'stringPad,intPad,List', 'stringPad');
            Sender.RegisterTextParameter('FixedSeatingCode', '');
            Sender.RegisterTextParameter('SeatingFilter', '');
            Sender.RegisterTextParameter('LocationFilter', '');
            Sender.RegisterBooleanParameter('ShowOnlyActiveWaiPad', false);
            Sender.RegisterBooleanParameter('WarnBeforeTableRetrieval', false)
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        NPRESeating: Record "NPR NPRE Seating";
    begin
        Captions.AddActionCaption(ActionCode(), 'InputTypeLabel', NPRESeating.TableCaption);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'addPresetValuesToContext':
                OnActionAddPresetValuesToContext(JSON, FrontEnd, POSSession);
            'seatingInput':
                OnActionSeatingInput(JSON, FrontEnd);
            'selectWaiterPad':
                OnActionSelectWaiterPad(JSON, FrontEnd);
            'getSaleFromPad':
                OnActionGetSaleFromPad(JSON, POSSession);
        end;

        Handled := true;
    end;

    local procedure OnActionSeatingInput(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);

        if JSON.GetBooleanParameter('WarnBeforeTableRetrieval') then
            if not Confirm(ConfirmTableCaption, true, NPRESeating.Description) then
                Error('');

        JSON.SetContext('seatingCode', NPRESeating.Code);

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSelectWaiterPad(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        if not NPREWaiterPadPOSMgt.SelectWaiterPad(NPRESeating, NPREWaiterPad) then
            exit;

        JSON.SetContext('waiterPadNo', NPREWaiterPad."No.");

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionGetSaleFromPad(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPadNo: Code[20];
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        JSON.SetScopeRoot();
        WaiterPadNo := CopyStr(JSON.GetStringOrFail('waiterPadNo', StrSubstNo(ReadingErr, ActionCode())), 1, MaxStrLen(WaiterPadNo));
        NPREWaiterPad.Get(WaiterPadNo);

        NPREWaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(NPREWaiterPad, POSSession);

        POSSession.RequestRefreshData();
    end;

    local procedure OnActionAddPresetValuesToContext(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(POSSetup);
        JSON.SetContext('restaurantCode', POSSetup.RestaurantCode());
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;
}
