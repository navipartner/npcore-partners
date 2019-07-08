codeunit 6150665 "NPRE POS Action - New Wa."
{
    // NPR5.45/MHA /20180827  CASE 318369 Object created


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Create new Waiter Pad on Seating';
        Text001: Label 'There are already active waiter pad(s) on seating %1.\Press Yes to add new waiterpad.\Press No to abort.';
        Text002: Label 'Waiter Pad added for seating %1.';
        Text003: Label 'Open new waiter pad?';
        Text004: Label 'New Waiter Pad';

    local procedure ActionCode(): Text
    begin
        exit ('NEW_WAITER_PAD');
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
            RegisterWorkflowStep('confirmNewWaiterPad',
              'if (context.confirmString) {' +
                'confirm(labels["ConfirmLabel"], context.confirmString, true, true).no(abort);' +
              '}'
            );
            RegisterWorkflowStep('newWaiterPad',
              'if (context.seatingCode) {' +
              '  respond();' +
              '}'
            );
            RegisterWorkflowStep('actionMessage',
              'if (context.actionMessage) {' +
              '  message(labels["ActionMessageLabel"], context.actionMessage);' +
              '}'
            );
            RegisterWorkflow(false);

            RegisterOptionParameter('InputType','stringPad,intPad,List','stringPad');
            RegisterTextParameter('FixedSeatingCode','');
            RegisterTextParameter('SeatingFilter','');
            RegisterTextParameter('LocationFilter','');
            RegisterBooleanParameter('OpenWaiterPad',false);
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        NPRESeating: Record "NPRE Seating";
    begin
        Captions.AddActionCaption(ActionCode(),'InputTypeLabel',NPRESeating.TableCaption);
        Captions.AddActionCaption(ActionCode(),'ConfirmLabel',Text003);
        Captions.AddActionCaption(ActionCode(),'ActionMessageLabel',Text004);
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
          'newWaiterPad':
            OnActionNewWaiterPad(JSON,FrontEnd);
        end;

        Handled := true;
    end;

    local procedure OnActionSeatingInput(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        NPRESeating: Record "NPRE Seating";
        NPREWaiterPadPOSManagement: Codeunit "NPRE Waiter Pad POS Management";
        ConfirmString: Text;
    begin
        NPREWaiterPadPOSManagement.FindSeating(JSON,NPRESeating);

        JSON.SetContext('seatingCode',NPRESeating.Code);
        ConfirmString := GetConfirmString(NPRESeating);
        if ConfirmString <> '' then
          JSON.SetContext('confirmString',ConfirmString);

        FrontEnd.SetActionContext(ActionCode(),JSON);
    end;

    local procedure OnActionNewWaiterPad(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        NPRESeating: Record "NPRE Seating";
        NPREWaiterPad: Record "NPRE Waiter Pad";
        NPRESeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        WaiterPadPOSManagement: Codeunit "NPRE Waiter Pad POS Management";
        SeatingCode: Code[10];
        OpenWaiterPad: Boolean;
    begin
        SeatingCode := JSON.GetString('seatingCode',true);
        NPRESeating.Get(SeatingCode);

        WaiterPadPOSManagement.AddNewWaiterPadForSeating(NPRESeating.Code,NPREWaiterPad,NPRESeatingWaiterPadLink);
        Commit;

        if OpenWaiterPad then begin
          WaiterPadPOSManagement.UIShowWaiterPad(NPREWaiterPad);
          exit;
        end;

        JSON.SetContext('actionMessage',StrSubstNo(Text002,NPRESeating.Description));
        FrontEnd.SetActionContext(ActionCode(),JSON);
    end;

    local procedure GetConfirmString(NPRESeating: Record "NPRE Seating") ConfirmString: Text
    var
        NPREWaiterPad: Record "NPRE Waiter Pad";
        NPRESeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        NPRESeatingWaiterPadLink.SetRange("Seating Code",NPRESeating.Code);
        if NPRESeatingWaiterPadLink.IsEmpty then
          exit('');

        NPRESeatingWaiterPadLink.FindSet;
        ConfirmString := StrSubstNo(Text001,NPRESeating.Code);
        ConfirmString += '\';
        repeat
          if NPREWaiterPad.Get(NPRESeatingWaiterPadLink."Waiter Pad No.") then
            ConfirmString += '\  - ' + NPREWaiterPad."No.";
            ConfirmString += ' ' + Format(NPREWaiterPad."Start Date");
            ConfirmString += ' ' + Format(NPREWaiterPad."Start Time");
            if NPREWaiterPad.Description <> '' then
              ConfirmString += ' ' + NPREWaiterPad.Description;
        until NPRESeatingWaiterPadLink.Next = 0;

        exit(ConfirmString);
    end;
}

