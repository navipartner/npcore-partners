codeunit 6150665 "NPR NPRE POSAction: New Wa." implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        Text001: Label 'There are already active waiter pad(s) on seating %1.\Press Yes to add new waiterpad.\Press No to abort.';
        Text002: Label 'Waiter Pad added for seating %1.';

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        NPRESeating: Record "NPR NPRE Seating";
        POSDataMgt: Codeunit "NPR POS Data Management";
        ActionDescription: Label 'This built-in action splits waiter pads (bills). It can be run from both Sale and Restaurant View';
        ParamInputType_OptionLbl: Label 'stringPad,intPad,List', locked = true;
        ParamInputType_CptLbl: Label 'Seating Selection Method';
        ParamInputType_DescLbl: Label 'Specifies seating selection method.';
        ParamInputType_OptionCptLbl: Label 'stringPad,intPad,List';
        ParamFixedSeatingCode_CptLbl: Label 'Fixed Seating Code';
        ParamFixedSeatingCode_DescLbl: Label 'Specifies seating number the action is to be run upon.';
        ParamSeatingFilter_CptLbl: Label 'Seating Filter';
        ParamSeatingFilter_DescLbl: Label 'Specifies a filter for seating.';
        ParamLocationFilter_CptLbl: Label 'Location Filter';
        ParamLocationFilter_DescLbl: Label 'Specifies a filter for seating location.';
        ParamOpenWaiterPad_CptLbl: Label 'Open Waiter Pad';
        ParamOpenWaiterPad_DescLbl: Label 'Open waiter pad after creation.';
        ParamAskForNumberOfGuests_CptLbl: Label 'Ask for number of guests';
        ParamAskForNumberOfGuests_DescLbl: Label 'Ask for number of guests before ne waiter pad is created.';
        ParamUseSeatingFromContext_CptLbl: Label 'Use seating from context';
        ParamUseSeatingFromContext_DescLbl: Label 'Use seating code from context.';
        ConfirmLbl: Label 'Open new waiter pad?';
        ActionMessageLbl: Label 'New Waiter Pad';
        NumberOfGuestsLbl: Label 'Number of guests';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSale());
        WorkflowConfig.AddOptionParameter('InputType',
                                        ParamInputType_OptionLbl,
#pragma warning disable AA0139
                                        CopyStr(SelectStr(1, ParamInputType_OptionLbl), 1, 250),
#pragma warning restore
                                        ParamInputType_CptLbl,
                                        ParamInputType_DescLbl,
                                        ParamInputType_OptionCptLbl);
        WorkflowConfig.AddTextParameter('FixedSeatingCode', '', ParamFixedSeatingCode_CptLbl, ParamFixedSeatingCode_DescLbl);
        WorkflowConfig.AddTextParameter('SeatingFilter', '', ParamSeatingFilter_CptLbl, ParamSeatingFilter_DescLbl);
        WorkflowConfig.AddTextParameter('LocationFilter', '', ParamLocationFilter_CptLbl, ParamLocationFilter_DescLbl);
        WorkflowConfig.AddBooleanParameter('OpenWaiterPad', false, ParamOpenWaiterPad_CptLbl, ParamOpenWaiterPad_DescLbl);
        WorkflowConfig.AddBooleanParameter('AskForNumberOfGuests', false, ParamAskForNumberOfGuests_CptLbl, ParamAskForNumberOfGuests_DescLbl);
        WorkflowConfig.AddBooleanParameter('UseSeatingFromContext', false, ParamUseSeatingFromContext_CptLbl, ParamUseSeatingFromContext_DescLbl);
        WorkflowConfig.AddLabel('InputTypeLabel', NPRESeating.TableCaption);
        WorkflowConfig.AddLabel('ConfirmLabel', ConfirmLbl);
        WorkflowConfig.AddLabel('ActionMessageLabel', ActionMessageLbl);
        WorkflowConfig.AddLabel('NumberOfGuestsLabel', NumberOfGuestsLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        case Step of
            'addPresetValuesToContext':
                AddPresetValuesToContext(Context, POSSession);
            'seatingInput':
                SeatingInput(Context);
            'SetNumberOfGuests':
                SetNumberOfGuests(Context);
            'newWaiterPad':
                NewWaiterPad(Context, POSSession);
        end;
    end;

    local procedure SeatingInput(JSON: Codeunit "NPR POS JSON Helper")
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPadPOSManagement: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        ConfirmString: Text;
    begin
        WaiterPadPOSManagement.FindSeating(JSON, Seating);

        JSON.SetContext('seatingCode', Seating.Code);
        ConfirmString := GetConfirmString(Seating);
        if ConfirmString <> '' then
            JSON.SetContext('confirmString', ConfirmString);
    end;

    local procedure SetNumberOfGuests(JSON: Codeunit "NPR POS JSON Helper")
    begin
        JSON.SetContext('numberOfGuests', JSON.GetInteger('numberOfGuests'));
    end;

    local procedure NewWaiterPad(JSON: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session")
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        WaiterPadPOSManagement: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SeatingCode: Code[20];
        NumberOfGuests: Integer;
        OpenWaiterPad: Boolean;
    begin
        SeatingCode := CopyStr(JSON.GetString('seatingCode'), 1, MaxStrLen(SeatingCode));
        if not JSON.GetInteger('numberOfGuests', NumberOfGuests) then
            NumberOfGuests := 0;
        Seating.Get(SeatingCode);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        WaiterPadMgt.CreateNewWaiterPad(Seating.Code, NumberOfGuests, SalePOS."Salesperson Code", '', WaiterPad);

        SalePOS.Find();
        SalePOS."NPRE Number of Guests" := NumberOfGuests;
        SalePOS."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
        SalePOS.Validate("NPRE Pre-Set Seating Code", SeatingCode);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
        Commit();

        if OpenWaiterPad then begin
            WaiterPadPOSManagement.UIShowWaiterPad(WaiterPad);
            exit;
        end;

        JSON.SetContext('actionMessage', StrSubstNo(Text002, Seating.Description));
    end;

    local procedure AddPresetValuesToContext(JSON: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR POS Sale";
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
    end;

    local procedure GetConfirmString(NPRESeating: Record "NPR NPRE Seating") ConfirmString: Text
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        SeatingWaiterPadLink.SetCurrentKey(Closed);
        SeatingWaiterPadLink.SetRange(Closed, false);
        SeatingWaiterPadLink.SetRange("Seating Code", NPRESeating.Code);
        if SeatingWaiterPadLink.IsEmpty then
            exit('');

        SeatingWaiterPadLink.FindSet();
        ConfirmString := StrSubstNo(Text001, NPRESeating.Code);
        ConfirmString += '\';
        repeat
            if WaiterPad.Get(SeatingWaiterPadLink."Waiter Pad No.") then
                ConfirmString += '\  - ' + WaiterPad."No.";
            ConfirmString += ' ' + Format(WaiterPad."Start Date");
            ConfirmString += ' ' + Format(WaiterPad."Start Time");
            if WaiterPad.Description <> '' then
                ConfirmString += ' ' + WaiterPad.Description;
        until SeatingWaiterPadLink.Next() = 0;

        exit(ConfirmString);
    end;

    local procedure ThisExtension(): Text
    begin
        exit('NPRE');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', true, false)]
    local procedure OnDiscoverDataSourceExtension(DataSourceName: Text; Extensions: List of [Text])
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if POSDataMgt.POSDataSource_BuiltInSale() <> DataSourceName then
            exit;

        Extensions.Add(ThisExtension());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', true, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale()) or (ExtensionName <> ThisExtension()) then
            exit;

        Handled := true;

        DataSource.AddColumn('TableId', 'Pre-selected seating internal Id', DataType::String, true);
        DataSource.AddColumn('TableNo', 'Pre-selected seating number', DataType::String, true);
        DataSource.AddColumn('WaiterPadNo', 'Pre-selected waiter pad No.', DataType::String, true);
        DataSource.AddColumn('NoOfGuests', 'Number of guests', DataType::Integer, true);
        DataSource.AddColumn('TableStatus', 'Seating status', DataType::String, true);
        DataSource.AddColumn('WPadStatus', 'Waiter pad status', DataType::String, true);
        DataSource.AddColumn('MealFlowStatus', 'Meal flow status', DataType::String, true);
        DataSource.AddColumn('AssignedWaiter', 'Assigned waiter', DataType::String, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', true, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        Salesperson: Record "Salesperson/Purchaser";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSDataMgt: Codeunit "NPR POS Data Management";
        AssignedWiaterLbl: Label '%1 %2', Locked = true;
    begin
        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale()) or (ExtensionName <> ThisExtension()) then
            exit;

        Handled := true;

        if RecRef.Number <> Database::"NPR POS Sale" then
            exit;

        RecRef.SetTable(SalePOS);

        if Seating.Get(SalePOS."NPRE Pre-Set Seating Code") then
            Seating.CalcFields("Status Description FF")
        else
            Seating.Init();

        if WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.") then
            WaiterPad.CalcFields("Status Description FF", "Serving Step Description")
        else
            WaiterPad.Init();

        if not Salesperson.get(WaiterPad."Assigned Waiter Code") then
            Salesperson.Init();

        DataRow.Add('TableId', SalePOS."NPRE Pre-Set Seating Code");
        DataRow.Add('TableNo', Seating."Seating No.");
        DataRow.Add('WaiterPadNo', SalePOS."NPRE Pre-Set Waiter Pad No.");
        DataRow.Add('NoOfGuests', SalePOS."NPRE Number of Guests");
        DataRow.Add('TableStatus', Seating."Status Description FF");
        DataRow.Add('WPadStatus', WaiterPad."Status Description FF");
        DataRow.Add('MealFlowStatus', WaiterPad."Serving Step Description");
        DataRow.Add('AssignedWaiter', StrSubstNo(AssignedWiaterLbl, WaiterPad."Assigned Waiter Code", Salesperson.Name));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPREPOSActionNewWa.js###
'let main=async({workflow:s,popup:i,parameters:n,context:e,captions:a})=>{if(await s.respond("addPresetValuesToContext"),!e.seatingCode||!n.UseSeatingFromContext)if(e.seatingCode="",n.FixedSeatingCode)e.seatingCode=n.FixedSeatingCode;else switch(n.InputType+""){case"0":e.seatingCode=await i.input({caption:a.InputTypeLabel});break;case"1":e.seatingCode=await i.numpad({caption:a.InputTypeLabel});break;case"2":await s.respond("seatingInput");break}if(!!e.seatingCode&&!(e.confirmString&&(result=await i.confirm({caption:a.ConfirmLabel,label:a.confirmString}),result))&&!(n.AskForNumberOfGuests&&(e.numberOfGuests=await i.numpad({caption:a.NumberOfGuestsLabel}),!e.numberOfGuests))&&(e.seatingCode&&await s.respond("newWaiterPad"),e.actionMessage)){await i.message({caption:a.ActionMessageLabel,label:a.actionMessage});return}};'
        );
    end;
}
