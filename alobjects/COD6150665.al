codeunit 6150665 "NPRE POS Action - New Wa."
{
    // NPR5.45/MHA /20180827 CASE 318369 Object created
    // NPR5.53/ALPO/20191211 CASE 380609 NPRE: New guest arrival procedure. Store preselected Waiterpad No. and Seating Code as well as Number of Guests on Sale POS


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Create new Waiter Pad on Seating';
        Text001: Label 'There are already active waiter pad(s) on seating %1.\Press Yes to add new waiterpad.\Press No to abort.';
        Text002: Label 'Waiter Pad added for seating %1.';
        Text003: Label 'Open new waiter pad?';
        Text004: Label 'New Waiter Pad';
        NumberOfGuestsLbl: Label 'Number of guests';

    local procedure ActionCode(): Text
    begin
        exit ('NEW_WAITER_PAD');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.1');  //NPR5.53 [380609]
        //EXIT ('1.0');  //NPR5.53 [380609]-revoked
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
              '}'
            );
            //-NPR5.53 [380609]
            RegisterWorkflowStep('SetNumberOfGuests',
              'if (param.AskForNumberOfGuests) {' +
              '  intpad(labels["NumberOfGuestsLabel"]).respond("numberOfGuests").cancel(abort);' +
              '}'
            );
            //+NPR5.53 [380609]
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
            RegisterDataSourceBinding(ThisDataSource);  //NPR5.53 [380609]

            RegisterOptionParameter('InputType','stringPad,intPad,List','stringPad');
            RegisterTextParameter('FixedSeatingCode','');
            RegisterTextParameter('SeatingFilter','');
            RegisterTextParameter('LocationFilter','');
            RegisterBooleanParameter('OpenWaiterPad',false);
            RegisterBooleanParameter('AskForNumberOfGuests',false);  //NPR5.53 [380609]
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
        Captions.AddActionCaption(ActionCode(),'NumberOfGuestsLabel',NumberOfGuestsLbl);  //NPR5.53 [380609]
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
          //-NPR5.53 [380609]
          'SetNumberOfGuests':
            OnActionSetNumberOfGuests(JSON,FrontEnd);
          //+NPR5.53 [380609]
          'newWaiterPad':
            //OnActionNewWaiterPad(JSON,FrontEnd);  //NPR5.53 [380609]-revoked
            OnActionNewWaiterPad(JSON,FrontEnd,POSSession);  //NPR5.53 [380609]
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

    local procedure OnActionSetNumberOfGuests(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    begin
        //-NPR5.53 [380609]
        JSON.SetContext('numberOfGuests',JSON.GetString('numberOfGuests',false));
        FrontEnd.SetActionContext(ActionCode(),JSON);
        //+NPR5.53 [380609]
    end;

    local procedure OnActionNewWaiterPad(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session")
    var
        NPRESeating: Record "NPRE Seating";
        NPREWaiterPad: Record "NPRE Waiter Pad";
        NPRESeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        WaiterPadPOSManagement: Codeunit "NPRE Waiter Pad POS Management";
        SeatingCode: Code[10];
        NumberOfGuests: Integer;
        OpenWaiterPad: Boolean;
    begin
        SeatingCode := JSON.GetString('seatingCode',true);
        NumberOfGuests := JSON.GetInteger('numberOfGuests',false);  //NPR5.53 [380609]
        NPRESeating.Get(SeatingCode);

        WaiterPadPOSManagement.AddNewWaiterPadForSeating(NPRESeating.Code,NPREWaiterPad,NPRESeatingWaiterPadLink);
        //-NPR5.53 [380609]
        NPREWaiterPad."Number of Guests" := NumberOfGuests;
        NPREWaiterPad.Modify;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;
        SalePOS."NPRE Number of Guests" := NumberOfGuests;
        SalePOS."NPRE Pre-Set Waiter Pad No." := NPREWaiterPad."No.";
        SalePOS.Validate("NPRE Pre-Set Seating Code",SeatingCode);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true,false);
        POSSession.RequestRefreshData();
        //+NPR5.53 [380609]
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

    procedure "//Data Source Extension"()
    begin
    end;

    local procedure ThisDataSource(): Text
    begin
        exit('BUILTIN_SALE');  //NPR5.53 [380609]
    end;

    local procedure ThisExtension(): Text
    begin
        exit('NPRE');  //NPR5.53 [380609]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', true, false)]
    local procedure OnDiscoverDataSourceExtension(DataSourceName: Text;Extensions: DotNet npNetList_Of_T)
    begin
        //-NPR5.53 [380609]
        if ThisDataSource <> DataSourceName then
          exit;

        Extensions.Add(ThisExtension);
        //+NPR5.53 [380609]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', true, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text;ExtensionName: Text;var DataSource: DotNet npNetDataSource0;var Handled: Boolean;Setup: Codeunit "POS Setup")
    var
        DataType: DotNet npNetDataType;
    begin
        //-NPR5.53 [380609]
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
          exit;

        Handled := true;

        DataSource.AddColumn('TableNo','Pre-selected Seating (table) code',DataType.String,true);
        DataSource.AddColumn('WaiterPadNo','Pre-selected Waiter Pad No.',DataType.String,true);
        //+NPR5.53 [380609]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', true, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text;ExtensionName: Text;var RecRef: RecordRef;DataRow: DotNet npNetDataRow0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
    begin
        //-NPR5.53 [380609]
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
          exit;

        Handled := true;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        DataRow.Add('TableNo',SalePOS."NPRE Pre-Set Seating Code");
        DataRow.Add('WaiterPadNo',SalePOS."NPRE Pre-Set Waiter Pad No.");
        //+NPR5.53 [380609]
    end;
}

