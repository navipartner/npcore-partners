codeunit 6150661 "NPRE POS Action - Print Wa."
{
    // NPR5.50/TJ  /20190502 CASE 346387 New object


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Print waiterpad';
        NoWaiterpadsMsg: Label 'There are none or multiple waiterpads to print from!';

    local procedure ActionCode(): Text
    begin
        exit ('PRINT_WAITER_PAD');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
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
            RegisterWorkflowStep('printWaiterPad','respond();');
            RegisterWorkflow(false);

            RegisterOptionParameter('InputType','stringPad,intPad,List','stringPad');
            RegisterTextParameter('FixedSeatingCode','');
            RegisterTextParameter('SeatingFilter','');
            RegisterTextParameter('LocationFilter','');
            RegisterBooleanParameter('ShowOnlyActiveWaiPad',false);
            //type of report for printing could be added as a parameter as well if needed
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
          'printWaiterPad':
            OnActionPrintWaiterPad(JSON);
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

    local procedure OnActionPrintWaiterPad(JSON: Codeunit "POS JSON Management")
    var
        NPRESeating: Record "NPRE Seating";
        NPREWaiterPad: Record "NPRE Waiter Pad";
        NPRESeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        WaiterPadNo: Code[20];
        NPREWaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
        HospitalityPrint: Codeunit "NPRE Restaurant Print";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON,NPRESeating);
        NPRESeatingWaiterPadLink.SetRange("Seating Code",NPRESeating.Code);
        if (not NPRESeatingWaiterPadLink.FindFirst) or (NPRESeatingWaiterPadLink.Count > 1) then begin
          Message(NoWaiterpadsMsg);
          exit;
        end;
        NPREWaiterPad.Get(NPRESeatingWaiterPadLink."Waiter Pad No.");
        HospitalityPrint.PrintWaiterPadPreReceiptPressed(NPREWaiterPad);
    end;
}

