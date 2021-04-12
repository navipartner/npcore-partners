codeunit 6150666 "NPR NPRE POSAction: Save2Wa."
{
    var
        Text000: Label 'Save POS Sale to Waiter Pad';
        Text001: Label 'No Water Pad exists on %1\Create new Water Pad?';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('SAVE_TO_WAITER_PAD');
    end;

    local procedure ActionVersion(): Text
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
              'if (!context.seatingCode) {' +
                'if (param.FixedSeatingCode) {' +
                '  context.seatingCode = param.FixedSeatingCode;' +
                '  respond();' +
                '} else {' +
                '  switch(param.InputType + "") {' +
                '    case "0":' +
                '      stringpad(labels["InputTypeLabel"]).respond("seatingCode").cancel(abort);' +
                '      break;' +
                '    case "1":' +
                '      intpad(labels["InputTypeLabel"]).respond("seatingCode").cancel(abort);' +
                '      break;' +
                '    case "2":' +
                '      respond();' +
                '      break;' +
                '  }' +
                '}' +
              '}'
            );
            Sender.RegisterWorkflowStep('createNewWaiterPad',
              'if ((context.seatingCode) && (context.confirmString)) {' +
              '  confirm(" ", context.confirmString, true, true).no(abort).yes(respond);' +
              '}'
            );
            Sender.RegisterWorkflowStep('selectWaiterPad',
              'if (!context.waiterPadNo) {' +
                'if (context.seatingCode) {' +
                '  respond();' +
                '}' +
              '}'
            );
            Sender.RegisterWorkflowStep('saveSale2Pad',
              'if (context.waiterPadNo) {' +
              '  respond();' +
              '}'
            );
            Sender.RegisterWorkflow(false);
            Sender.RegisterDataSourceBinding('BUILTIN_SALELINE');

            Sender.RegisterOptionParameter('InputType', 'stringPad,intPad,List', 'stringPad');
            Sender.RegisterTextParameter('FixedSeatingCode', '');
            Sender.RegisterTextParameter('SeatingFilter', '');
            Sender.RegisterTextParameter('LocationFilter', '');
            Sender.RegisterBooleanParameter('OpenWaiterPad', false);
            Sender.RegisterBooleanParameter('ShowOnlyActiveWaiPad', false);
            Sender.RegisterBooleanParameter('ReturnToDefaultView', false);
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
            'createNewWaiterPad':
                OnActionCreateNewWaiterPad(JSON);
            'selectWaiterPad':
                OnActionSelectWaiterPad(JSON, FrontEnd);
            'saveSale2Pad':
                OnActionSaveSale2Pad(JSON, POSSession);
        end;

        Handled := true;
    end;

    local procedure OnActionAddPresetValuesToContext(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        ConfirmString: Text;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSetup(POSSetup);

        JSON.SetContext('restaurantCode', POSSetup.RestaurantCode());

        if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
            NPRESeating.Get(SalePOS."NPRE Pre-Set Seating Code");
            JSON.SetContext('seatingCode', SalePOS."NPRE Pre-Set Seating Code");

            if SalePOS."NPRE Pre-Set Waiter Pad No." = '' then begin
                ConfirmString := GetConfirmString(NPRESeating);
                if ConfirmString <> '' then
                    JSON.SetContext('confirmString', ConfirmString);
            end;
        end;

        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
            NPREWaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            if SalePOS."NPRE Pre-Set Seating Code" <> '' then
                if not NPRESeatingWaiterPadLink.Get(NPRESeating.Code, NPREWaiterPad."No.") then
                    WaiterPadMgt.AddNewWaiterPadForSeating(NPRESeating.Code, NPREWaiterPad, NPRESeatingWaiterPadLink);
            JSON.SetContext('waiterPadNo', SalePOS."NPRE Pre-Set Waiter Pad No.");
        end;

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSeatingInput(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        ConfirmString: Text;
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);

        JSON.SetContext('seatingCode', NPRESeating.Code);
        ConfirmString := GetConfirmString(NPRESeating);
        if ConfirmString <> '' then
            JSON.SetContext('confirmString', ConfirmString);

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionCreateNewWaiterPad(JSON: Codeunit "NPR POS JSON Management")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        WaiterPadMgt.AddNewWaiterPadForSeating(NPRESeating.Code, NPREWaiterPad, NPRESeatingWaiterPadLink);
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

    local procedure OnActionSaveSale2Pad(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        WaiterPadNo: Code[20];
        OpenWaiterPad: Boolean;
        ReturnToDefaultView: Boolean;
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        JSON.SetScopeRoot();
        WaiterPadNo := JSON.GetStringOrFail('waiterPadNo', StrSubstNo(ReadingErr, ActionCode()));
        NPREWaiterPad.Get(WaiterPadNo);

        OpenWaiterPad := JSON.GetBooleanParameter('OpenWaiterPad');
        ReturnToDefaultView := JSON.GetBooleanParameter('ReturnToDefaultView');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        NPREWaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, NPREWaiterPad, true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        Commit();
        POSSession.RequestRefreshData();

        if OpenWaiterPad then
            NPREWaiterPadPOSMgt.UIShowWaiterPad(NPREWaiterPad);

        if ReturnToDefaultView then
            POSSale.SelectViewForEndOfSale(POSSession);
    end;

    local procedure GetConfirmString(NPRESeating: Record "NPR NPRE Seating") ConfirmString: Text
    var
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        NPRESeatingWaiterPadLink.SetCurrentKey(Closed);
        NPRESeatingWaiterPadLink.SetRange(Closed, false);
        NPRESeatingWaiterPadLink.SetRange("Seating Code", NPRESeating.Code);
        if NPRESeatingWaiterPadLink.FindFirst() then
            exit('');

        ConfirmString := StrSubstNo(Text001, NPRESeating.Code);
        exit(ConfirmString);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        CaptionReturnToDefaultView: Label 'Return to Default View on Finish';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ReturnToDefaultView':
                Caption := CaptionReturnToDefaultView;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        DescReturnToDefaultView: Label 'Switch to the default view defined for the POS Unit after the Waiter Pad Action has completed';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ReturnToDefaultView':
                Caption := DescReturnToDefaultView;
        end;
    end;
}
