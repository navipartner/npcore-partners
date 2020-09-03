codeunit 6150661 "NPR NPRE POSAction: Print Wa."
{
    // NPR5.50/TJ  /20190502 CASE 346387 New object
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale
    // NPR5.55/ALPO/20200730 CASE 414938 POS Store/POS Unit - Restaurant link (filter seatings by restaurant)


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Print waiterpad';
        NoWaiterpadsMsg: Label 'There are none or multiple waiterpads to print from!';

    local procedure ActionCode(): Text
    begin
        exit('PRINT_WAITER_PAD');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do begin
            if DiscoverAction(
              ActionCode(),
              Text000,
              ActionVersion(),
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('addPresetValuesToContext', 'respond();');  //NPR5.55 [399170]
                RegisterWorkflowStep('seatingInput',
                  'if (!context.seatingCode) {' +  //NPR5.55 [399170]
                  '  if (param.FixedSeatingCode) {' +
                  '    context.seatingCode = param.FixedSeatingCode;' +
                  '    respond();' +
                  '  } else {' +
                  '    switch(param.InputType + "") {' +
                  '      case "0":' +
                  //'      stringpad(labels["InputTypeLabel"]).respond("seatingCode");' +  //NPR5.55 [399170]-revoked
                  '        stringpad(labels["InputTypeLabel"]).respond("seatingCode").cancel(abort);' +  //NPR5.55 [399170]
                  '        break;' +
                  '      case "1":' +
                  //'      intpad(labels["InputTypeLabel"]).respond("seatingCode");' +  //NPR5.55 [399170]-revoked
                  '        intpad(labels["InputTypeLabel"]).respond("seatingCode").cancel(abort);' +  //NPR5.55 [399170]
                  '        break;' +
                  '      case "2":' +
                  '        respond();' +
                  '       break;' +
                  '    }' +
                  '  }' +  //NPR5.55 [399170]
                  '}'
                );
                //-NPR5.55 [399170]
                RegisterWorkflowStep('selectWaiterPad',
                  'if (!context.waiterPadNo) {' +
                  '  if (context.seatingCode) {' +
                  '    respond();' +
                  '  }' +
                  '}'
                );
                RegisterWorkflowStep('printWaiterPad',
                  'if (context.waiterPadNo) {' +
                  '  respond();' +
                  '}'
                );
                //+NPR5.55 [399170]
                //RegisterWorkflowStep('printWaiterPad','respond();');  //NPR5.55 [399170]-revoked
                RegisterWorkflow(false);

                RegisterOptionParameter('InputType', 'stringPad,intPad,List', 'stringPad');
                RegisterTextParameter('FixedSeatingCode', '');
                RegisterTextParameter('SeatingFilter', '');
                RegisterTextParameter('LocationFilter', '');
                RegisterBooleanParameter('ShowOnlyActiveWaiPad', false);
                //type of report for printing could be added as a parameter as well if needed
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        NPRESeating: Record "NPR NPRE Seating";
    begin
        Captions.AddActionCaption(ActionCode(), 'InputTypeLabel', NPRESeating.TableCaption);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            //-NPR5.55 [399170]
            'addPresetValuesToContext':
                OnActionAddPresetValuesToContext(JSON, FrontEnd, POSSession);
            //+NPR5.55 [399170]
            'seatingInput':
                OnActionSeatingInput(JSON, FrontEnd);
            //-NPR5.55 [399170]
            'selectWaiterPad':
                OnActionSelectWaiterPad(JSON, FrontEnd);
            //+NPR5.55 [399170]
            'printWaiterPad':
                OnActionPrintWaiterPad(JSON);
        end;

        Handled := true;
    end;

    local procedure OnActionAddPresetValuesToContext(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR Sale POS";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        ConfirmString: Text;
    begin
        //-NPR5.55 [399170]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        //-NPR5.55 [414938]
        POSSession.GetSetup(POSSetup);

        JSON.SetContext('restaurantCode', POSSetup.RestaurantCode());
        //+NPR5.55 [414938]

        if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
            NPRESeating.Get(SalePOS."NPRE Pre-Set Seating Code");
            JSON.SetContext('seatingCode', SalePOS."NPRE Pre-Set Seating Code");
        end;

        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
            NPREWaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            if SalePOS."NPRE Pre-Set Seating Code" <> '' then
                if not NPRESeatingWaiterPadLink.Get(NPRESeating.Code, NPREWaiterPad."No.") then
                    WaiterPadMgt.AddNewWaiterPadForSeating(NPRESeating.Code, NPREWaiterPad, NPRESeatingWaiterPadLink);
            WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, NPREWaiterPad, false);
            JSON.SetContext('waiterPadNo', SalePOS."NPRE Pre-Set Waiter Pad No.");
        end;

        FrontEnd.SetActionContext(ActionCode(), JSON);
        //+NPR5.55 [399170]
    end;

    local procedure OnActionSeatingInput(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);

        JSON.SetContext('seatingCode', NPRESeating.Code);

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSelectWaiterPad(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        //-NPR5.55 [399170]
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        if not NPREWaiterPadPOSMgt.SelectWaiterPad(NPRESeating, NPREWaiterPad) then
            exit;

        JSON.SetContext('waiterPadNo', NPREWaiterPad."No.");

        FrontEnd.SetActionContext(ActionCode(), JSON);
        //+NPR5.55 [399170]
    end;

    local procedure OnActionPrintWaiterPad(JSON: Codeunit "NPR POS JSON Management")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPadNo: Code[20];
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        HospitalityPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        //-NPR5.55 [399170]-revoked
        //NPRESeatingWaiterPadLink.SETRANGE("Seating Code",NPRESeating.Code);
        //IF (NOT NPRESeatingWaiterPadLink.FINDFIRST) OR (NPRESeatingWaiterPadLink.COUNT > 1) THEN BEGIN
        //  MESSAGE(NoWaiterpadsMsg);
        //  EXIT;
        //END;
        //NPREWaiterPad.GET(NPRESeatingWaiterPadLink."Waiter Pad No.");
        //+NPR5.55 [399170]-revoked
        //-NPR5.55 [399170]
        JSON.SetScope('/', true);
        WaiterPadNo := JSON.GetString('waiterPadNo', true);
        NPREWaiterPad.Get(WaiterPadNo);
        //+NPR5.55 [399170]
        HospitalityPrint.PrintWaiterPadPreReceiptPressed(NPREWaiterPad);
    end;
}

