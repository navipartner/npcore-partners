codeunit 6150665 "NPR NPRE POSAction: New Wa."
{
    var
        Text000: Label 'Create new Waiter Pad on Seating';
        Text001: Label 'There are already active waiter pad(s) on seating %1.\Press Yes to add new waiterpad.\Press No to abort.';
        Text002: Label 'Waiter Pad added for seating %1.';
        Text003: Label 'Open new waiter pad?';
        Text004: Label 'New Waiter Pad';
        NumberOfGuestsLbl: Label 'Number of guests';

    local procedure ActionCode(): Text
    begin
        exit('NEW_WAITER_PAD');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
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
              'if (!context.seatingCode) || (!param.UseSeatingFromContext) {' +
              '  if (param.FixedSeatingCode) {' +
              '    context.seatingCode = param.FixedSeatingCode;' +
              '    respond();' +
              '  } else {' +
              '    switch(param.InputType + "") {' +
              '      case "0":' +
              '        stringpad(labels["InputTypeLabel"]).respond("seatingCode").cancel(abort);' +
              '        break;' +
              '      case "1":' +
              '        intpad(labels["InputTypeLabel"]).respond("seatingCode").cancel(abort);' +
              '        break;' +
              '      case "2":' +
              '        respond();' +
              '        break;' +
              '    }' +
              '  }' +
              '}'
            );
            Sender.RegisterWorkflowStep('confirmNewWaiterPad',
              'if (context.confirmString) {' +
                'confirm(labels["ConfirmLabel"], context.confirmString, true, true).no(abort);' +
              '}'
            );
            Sender.RegisterWorkflowStep('SetNumberOfGuests',
              'if (param.AskForNumberOfGuests) {' +
              '  intpad(labels["NumberOfGuestsLabel"]).respond("numberOfGuests").cancel(abort);' +
              '}'
            );
            Sender.RegisterWorkflowStep('newWaiterPad',
              'if (context.seatingCode) {' +
              '  respond();' +
              '}'
            );
            Sender.RegisterWorkflowStep('actionMessage',
              'if (context.actionMessage) {' +
              '  message(labels["ActionMessageLabel"], context.actionMessage);' +
              '}'
            );
            Sender.RegisterWorkflow(false);
            Sender.RegisterDataSourceBinding(ThisDataSource);

            Sender.RegisterOptionParameter('InputType', 'stringPad,intPad,List', 'stringPad');
            Sender.RegisterTextParameter('FixedSeatingCode', '');
            Sender.RegisterTextParameter('SeatingFilter', '');
            Sender.RegisterTextParameter('LocationFilter', '');
            Sender.RegisterBooleanParameter('OpenWaiterPad', false);
            Sender.RegisterBooleanParameter('AskForNumberOfGuests', false);
            Sender.RegisterBooleanParameter('UseSeatingFromContext', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        NPRESeating: Record "NPR NPRE Seating";
    begin
        Captions.AddActionCaption(ActionCode(), 'InputTypeLabel', NPRESeating.TableCaption);
        Captions.AddActionCaption(ActionCode(), 'ConfirmLabel', Text003);
        Captions.AddActionCaption(ActionCode(), 'ActionMessageLabel', Text004);
        Captions.AddActionCaption(ActionCode(), 'NumberOfGuestsLabel', NumberOfGuestsLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'addPresetValuesToContext':
                OnActionAddPresetValuesToContext(JSON, FrontEnd, POSSession);
            'seatingInput':
                OnActionSeatingInput(JSON, FrontEnd);
            'SetNumberOfGuests':
                OnActionSetNumberOfGuests(JSON, FrontEnd);
            'newWaiterPad':
                OnActionNewWaiterPad(JSON, FrontEnd, POSSession);
        end;

        Handled := true;
    end;

    local procedure OnActionSeatingInput(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSManagement: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        ConfirmString: Text;
    begin
        NPREWaiterPadPOSManagement.FindSeating(JSON, NPRESeating);

        JSON.SetContext('seatingCode', NPRESeating.Code);
        ConfirmString := GetConfirmString(NPRESeating);
        if ConfirmString <> '' then
            JSON.SetContext('confirmString', ConfirmString);

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSetNumberOfGuests(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        JSON.SetContext('numberOfGuests', JSON.GetString('numberOfGuests', false));
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionNewWaiterPad(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        WaiterPadPOSManagement: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SeatingCode: Code[10];
        NumberOfGuests: Integer;
        OpenWaiterPad: Boolean;
    begin
        SeatingCode := JSON.GetString('seatingCode', true);
        NumberOfGuests := JSON.GetInteger('numberOfGuests', false);
        NPRESeating.Get(SeatingCode);

        WaiterPadMgt.AddNewWaiterPadForSeating(NPRESeating.Code, NPREWaiterPad, NPRESeatingWaiterPadLink);
        NPREWaiterPad."Number of Guests" := NumberOfGuests;
        NPREWaiterPad.Modify;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find;
        SalePOS."NPRE Number of Guests" := NumberOfGuests;
        SalePOS."NPRE Pre-Set Waiter Pad No." := NPREWaiterPad."No.";
        SalePOS.Validate("NPRE Pre-Set Seating Code", SeatingCode);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
        POSSession.RequestRefreshData();
        Commit;

        if OpenWaiterPad then begin
            WaiterPadPOSManagement.UIShowWaiterPad(NPREWaiterPad);
            exit;
        end;

        JSON.SetContext('actionMessage', StrSubstNo(Text002, NPRESeating.Description));
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionAddPresetValuesToContext(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR Sale POS";
        Seating: Record "NPR NPRE Seating";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(POSSetup);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        JSON.SetContext('restaurantCode', POSSetup.RestaurantCode());

        if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
            Seating.Get(SalePOS."NPRE Pre-Set Seating Code");
            JSON.SetContext('seatingCode', SalePOS."NPRE Pre-Set Seating Code");
        end;

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure GetConfirmString(NPRESeating: Record "NPR NPRE Seating") ConfirmString: Text
    var
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        NPRESeatingWaiterPadLink.SetCurrentKey(Closed);
        NPRESeatingWaiterPadLink.SetRange(Closed, false);
        NPRESeatingWaiterPadLink.SetRange("Seating Code", NPRESeating.Code);
        if NPRESeatingWaiterPadLink.IsEmpty then
            exit('');

        NPRESeatingWaiterPadLink.FindSet;
        ConfirmString := StrSubstNo(Text001, NPRESeating.Code);
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

    local procedure ThisDataSource(): Text
    begin
        exit('BUILTIN_SALE');
    end;

    local procedure ThisExtension(): Text
    begin
        exit('NPRE');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', true, false)]
    local procedure OnDiscoverDataSourceExtension(DataSourceName: Text; Extensions: List of [Text])
    begin
        if ThisDataSource <> DataSourceName then
            exit;

        Extensions.Add(ThisExtension);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', true, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        Handled := true;

        DataSource.AddColumn('TableNo', 'Pre-selected Seating (table) code', DataType::String, true);
        DataSource.AddColumn('WaiterPadNo', 'Pre-selected Waiter Pad No.', DataType::String, true);
        DataSource.AddColumn('NoOfGuests', 'Number of guests', DataType::Integer, true);
        DataSource.AddColumn('TableStatus', 'Seating (table) status', DataType::String, true);
        DataSource.AddColumn('WPadStatus', 'Waiter pad status', DataType::String, true);
        DataSource.AddColumn('MealFlowStatus', 'Meal flow status', DataType::String, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', true, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalePOS: Record "NPR Sale POS";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSale: Codeunit "NPR POS Sale";
    begin
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        Handled := true;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if Seating.Get(SalePOS."NPRE Pre-Set Seating Code") then
            Seating.CalcFields("Status Description FF")
        else
            Seating.Init();
        if WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.") then
            WaiterPad.CalcFields("Status Description FF", "Serving Step Description")
        else
            WaiterPad.Init();


        DataRow.Add('TableNo', SalePOS."NPRE Pre-Set Seating Code");
        DataRow.Add('WaiterPadNo', SalePOS."NPRE Pre-Set Waiter Pad No.");
        DataRow.Add('NoOfGuests', SalePOS."NPRE Number of Guests");
        DataRow.Add('TableStatus', Seating."Status Description FF");
        DataRow.Add('WPadStatus', WaiterPad."Status Description FF");
        DataRow.Add('MealFlowStatus', WaiterPad."Serving Step Description");
    end;
}