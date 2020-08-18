codeunit 6150666 "NPRE POS Action - Save to Wa."
{
    // NPR5.45/MHA /20180827 CASE 318369 Object created
    // NPR5.50/TJ  /20190530 CASE 346384 New parameter added
    // NPR5.53/ALPO/20191211 CASE 380609 NPRE: New guest arrival procedure. Use preselected Waiterpad No. and Seating Code as well as Number of Guests
    // NPR5.55/ALPO/20200623 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale
    // NPR5.55/ALPO/20200730 CASE 414938 POS Store/POS Unit - Restaurant link (filter seatings by restaurant)


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Save POS Sale to Waiter Pad';
        Text001: Label 'No Water Pad exists on %1\Create new Water Pad?';

    local procedure ActionCode(): Text
    begin
        exit ('SAVE_TO_WAITER_PAD');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');  //NPR5.55 [399170]
        exit ('1.1');
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
            //-NPR5.53 [380609]
            RegisterWorkflowStep('addPresetValuesToContext','respond();');
            //+NPR5.53 [380609]
            RegisterWorkflowStep('seatingInput',
              'if (!context.seatingCode) {' +  //NPR5.53 [380609]
                'if (param.FixedSeatingCode) {' +
                '  context.seatingCode = param.FixedSeatingCode;' +
                '  respond();' +
                '} else {' +
                '  switch(param.InputType + "") {' +
                '    case "0":' +
                //'      stringpad(labels["InputTypeLabel"]).respond("seatingCode");' +  //NPR5.53 [380609]-revoked
                '      stringpad(labels["InputTypeLabel"]).respond("seatingCode").cancel(abort);' +  //NPR5.53 [380609]
                '      break;' +
                '    case "1":' +
                //'      intpad(labels["InputTypeLabel"]).respond("seatingCode");' +  //NPR5.53 [380609]-revoked
                '      intpad(labels["InputTypeLabel"]).respond("seatingCode").cancel(abort);' +  //NPR5.53 [380609]
                '      break;' +
                '    case "2":' +
                '      respond();' +
                '      break;' +
                '  }' +
                '}' +  //NPR5.53 [380609]
              '}'
            );
            RegisterWorkflowStep('createNewWaiterPad',
              'if ((context.seatingCode) && (context.confirmString)) {' +
              '  confirm(" ", context.confirmString, true, true).no(abort).yes(respond);' +
              '}'
            );
            RegisterWorkflowStep('selectWaiterPad',
              'if (!context.waiterPadNo) {' +  //NPR5.53 [380609]
                'if (context.seatingCode) {' +
                '  respond();' +
                '}' +  //NPR5.53 [380609]
              '}'
            );
            RegisterWorkflowStep('saveSale2Pad',
              'if (context.waiterPadNo) {' +
              '  respond();' +
              '}'
            );
            RegisterWorkflow(false);
            RegisterDataSourceBinding('BUILTIN_SALELINE');

            RegisterOptionParameter('InputType','stringPad,intPad,List','stringPad');
            RegisterTextParameter('FixedSeatingCode','');
            RegisterTextParameter('SeatingFilter','');
            RegisterTextParameter('LocationFilter','');
            RegisterBooleanParameter('OpenWaiterPad',false);
            //-NPR5.50 [346384]
            RegisterBooleanParameter('ShowOnlyActiveWaiPad',false);
            //+NPR5.50 [346384]
            RegisterBooleanParameter('ReturnToDefaultView',false);  //NPR5.55 [399170]
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
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          //-NPR5.53 [380609]
          'addPresetValuesToContext':
            OnActionAddPresetValuesToContext(JSON,FrontEnd,POSSession);
          //+NPR5.53 [380609]
          'seatingInput':
            OnActionSeatingInput(JSON,FrontEnd);
          'createNewWaiterPad':
            OnActionCreateNewWaiterPad(JSON);
          'selectWaiterPad':
            OnActionSelectWaiterPad(JSON,FrontEnd);
          'saveSale2Pad' :
            OnActionSaveSale2Pad(JSON,POSSession);
        end;

        Handled := true;
    end;

    local procedure OnActionAddPresetValuesToContext(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session")
    var
        NPRESeating: Record "NPRE Seating";
        NPRESeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        NPREWaiterPad: Record "NPRE Waiter Pad";
        SalePOS: Record "Sale POS";
        WaiterPadMgt: Codeunit "NPRE Waiter Pad Management";
        POSSale: Codeunit "POS Sale";
        POSSetup: Codeunit "POS Setup";
        ConfirmString: Text;
    begin
        //-NPR5.53 [380609]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        //-NPR5.55 [414938]
        POSSession.GetSetup(POSSetup);

        JSON.SetContext('restaurantCode', POSSetup.RestaurantCode());
        //+NPR5.55 [414938]

        if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
          NPRESeating.Get(SalePOS."NPRE Pre-Set Seating Code");
          JSON.SetContext('seatingCode',SalePOS."NPRE Pre-Set Seating Code");

          if SalePOS."NPRE Pre-Set Waiter Pad No." = '' then begin
            ConfirmString := GetConfirmString(NPRESeating);
            if ConfirmString <> '' then
              JSON.SetContext('confirmString',ConfirmString);
          end;
        end;

        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
          NPREWaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
          if SalePOS."NPRE Pre-Set Seating Code" <> '' then
            if not NPRESeatingWaiterPadLink.Get(NPRESeating.Code,NPREWaiterPad."No.") then
              //NPREWaiterPadPOSMgt.AddNewWaiterPadForSeating(NPRESeating.Code,NPREWaiterPad,NPRESeatingWaiterPadLink);  //NPR5.55 [399170]-revoked
              WaiterPadMgt.AddNewWaiterPadForSeating(NPRESeating.Code,NPREWaiterPad,NPRESeatingWaiterPadLink);  //NPR5.55 [399170]
          JSON.SetContext('waiterPadNo',SalePOS."NPRE Pre-Set Waiter Pad No.");
        end;

        FrontEnd.SetActionContext(ActionCode(),JSON);
        //+NPR5.53 [380609]
    end;

    local procedure OnActionSeatingInput(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        NPRESeating: Record "NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
        ConfirmString: Text;
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON,NPRESeating);

        JSON.SetContext('seatingCode',NPRESeating.Code);
        ConfirmString := GetConfirmString(NPRESeating);
        if ConfirmString <> '' then
          JSON.SetContext('confirmString',ConfirmString);

        FrontEnd.SetActionContext(ActionCode(),JSON);
    end;

    local procedure OnActionCreateNewWaiterPad(JSON: Codeunit "POS JSON Management")
    var
        NPRESeating: Record "NPRE Seating";
        NPRESeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        NPREWaiterPad: Record "NPRE Waiter Pad";
        NPREWaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
        WaiterPadMgt: Codeunit "NPRE Waiter Pad Management";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON,NPRESeating);
        //NPREWaiterPadPOSMgt.AddNewWaiterPadForSeating(NPRESeating.Code,NPREWaiterPad,NPRESeatingWaiterPadLink);  //NPR5.55 [399170]-revoked
        WaiterPadMgt.AddNewWaiterPadForSeating(NPRESeating.Code,NPREWaiterPad,NPRESeatingWaiterPadLink);  //NPR5.55 [399170]
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

    local procedure OnActionSaveSale2Pad(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        NPRESeating: Record "NPRE Seating";
        NPREWaiterPad: Record "NPRE Waiter Pad";
        SalePOS: Record "Sale POS";
        NPREWaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
        POSSale: Codeunit "POS Sale";
        WaiterPadNo: Code[20];
        OpenWaiterPad: Boolean;
        ReturnToDefaultView: Boolean;
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON,NPRESeating);
        JSON.SetScope('/',true);
        WaiterPadNo := JSON.GetString('waiterPadNo',true);
        NPREWaiterPad.Get(WaiterPadNo);
        
        OpenWaiterPad := JSON.GetBooleanParameter('OpenWaiterPad',false);
        ReturnToDefaultView := JSON.GetBooleanParameter('ReturnToDefaultView',false);  //NPR5.55 [399170]
        
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        
        //-NPR5.55 [399170]-revoked
        /*
        NPREWaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS,NPREWaiterPad);
        //-NPR5.53 [380609]
        SalePOS.FIND;
        NPREWaiterPadPOSMgt.ClearSaleHdrNPREPresetFields(SalePOS,FALSE);
        */
        //+NPR5.55 [399170]-revoked
        NPREWaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS,NPREWaiterPad,true);  //NPR5.55 [399170]
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true,false);
        //+NPR5.53 [380609]
        
        Commit;
        POSSession.RequestRefreshData();
        
        if OpenWaiterPad then
          NPREWaiterPadPOSMgt.UIShowWaiterPad(NPREWaiterPad);
        
        //-NPR5.55 [399170]
        if ReturnToDefaultView then
          POSSale.SelectViewForEndOfSale(POSSession);
        //+NPR5.55 [399170]

    end;

    local procedure GetConfirmString(NPRESeating: Record "NPRE Seating") ConfirmString: Text
    var
        NPRESeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        //+NPR5.55 [399170]
        NPRESeatingWaiterPadLink.SetCurrentKey(Closed);
        NPRESeatingWaiterPadLink.SetRange(Closed, false);
        //+NPR5.55 [399170]
        NPRESeatingWaiterPadLink.SetRange("Seating Code",NPRESeating.Code);
        if NPRESeatingWaiterPadLink.FindFirst then
          exit('');

        ConfirmString := StrSubstNo(Text001,NPRESeating.Code);
        exit(ConfirmString);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    var
        CaptionReturnToDefaultView: Label 'Return to Default View on Finish';
    begin
        //-NPR5.55 [399170]
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'ReturnToDefaultView': Caption := CaptionReturnToDefaultView;
        end;
        //+NPR5.55 [399170]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    var
        DescReturnToDefaultView: Label 'Switch to the default view defined for the POS Unit after the Waiter Pad Action has completed';
    begin
        //-NPR5.55 [399170]
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'ReturnToDefaultView': Caption := DescReturnToDefaultView;
        end;
        //+NPR5.55 [399170]
    end;
}

