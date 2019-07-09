codeunit 6150668 "NPRE POS Action - Split Wa."
{
    // NPR5.45/MHA /20180827  CASE 318369 Object created
    // NPR5.50/TJ  /20190530  CASE 346384 New parameter added


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Partially load Waiter Pad to POS Sale';

    local procedure ActionCode(): Text
    begin
        exit ('SPLIT_WAITER_PAD');
    end;

    local procedure ActionVersion(): Text
    begin
        //-NPR5.50 [346384]
        //EXIT ('1.0');
        exit ('1.1');
        //+NPR5.50 [346384]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
          if DiscoverAction(
            ActionCode(),
            Text000,
            ActionVersion(),
            Type::Generic,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('seatingInput',
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
            RegisterWorkflowStep('selectWaiterPad',
              'if (context.seatingCode) {' +
              '  respond();' +
              '}'
            );
            RegisterWorkflowStep('splitWaiterPad',
              'if (context.waiterPadNo) {' +
              '  respond();' +
              '}'
            );
            RegisterWorkflow(false);

            RegisterOptionParameter('InputType','stringPad,intPad,List','stringPad');
            RegisterTextParameter('FixedSeatingCode','');
            RegisterTextParameter('SeatingFilter','');
            RegisterTextParameter('LocationFilter','');
            //-NPR5.50 [346384]
            RegisterBooleanParameter('ShowOnlyActiveWaiPad',false);
            //+NPR5.50 [346384]
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        NPRESeating: Record "NPRE Seating";
    begin
        Captions.AddActionCaption(ActionCode(),'InputTypeLabel',NPRESeating.TableCaption);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          'seatingInput':
            OnActionSeatingInput(JSON,FrontEnd);
          'selectWaiterPad':
            OnActionSelectWaiterPad(JSON,FrontEnd);
          'splitWaiterPad' :
            OnActionSplitWaiterPad(JSON,POSSession);
        end;

        Handled := true;
    end;

    local procedure OnActionSeatingInput(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        NPRESeating: Record "NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON,NPRESeating);

        JSON.SetContext('seatingCode',NPRESeating.Code);

        FrontEnd.SetActionContext(ActionCode(),JSON);
    end;

    local procedure OnActionSelectWaiterPad(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        NPREWaiterPad: Record "NPRE Waiter Pad";
        NPRESeating: Record "NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON,NPRESeating);
        if not NPREWaiterPadPOSMgt.SelectWaiterPad(NPRESeating,NPREWaiterPad) then
          exit;

        JSON.SetContext('waiterPadNo',NPREWaiterPad."No.");

        FrontEnd.SetActionContext(ActionCode(),JSON);
    end;

    local procedure OnActionSplitWaiterPad(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        NPRESeating: Record "NPRE Seating";
        NPREWaiterPad: Record "NPRE Waiter Pad";
        NPREWaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
        POSSaleLine: Codeunit "POS Sale Line";
        WaiterPadNo: Code[20];
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON,NPRESeating);
        JSON.SetScope('/',true);
        WaiterPadNo := JSON.GetString('waiterPadNo',true);
        NPREWaiterPad.Get(WaiterPadNo);

        POSSession.GetSaleLine(POSSaleLine);

        NPREWaiterPadPOSMgt.SplitBill(NPREWaiterPad,POSSaleLine);

        POSSession.RequestRefreshData();
    end;
}

