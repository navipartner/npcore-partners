codeunit 6150665 "NPR POSAction: New Wa. Pad" implements "NPR IPOS Workflow"
{
    Access = Internal;

    internal procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::NEW_WAITER_PAD));
    end;

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
                                        CopyStr(SelectStr(1, ParamInputType_OptionLbl), 1, 250),
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
                NewWaiterPad(Context, Sale);
        end;
    end;

    local procedure SeatingInput(Context: Codeunit "NPR POS JSON Helper")
    var
        Seating: Record "NPR NPRE Seating";
        BusinessLogic: Codeunit "NPR POSAction New Wa. Pad-B";
        POSActRVNewWPadB: Codeunit "NPR POSAct. RV New WPad-B";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        ConfirmString: Text;
    begin
        WaiterPadPOSMgt.FindSeating(Context, Seating);

        Context.SetContext('seatingCode', Seating.Code);
        Context.SetContext('defaultNumberOfGuests', POSActRVNewWPadB.GetDefaultNumberOfGuests(Seating.Code));
        ConfirmString := BusinessLogic.GetSeatingConfirmString(Seating);
        if ConfirmString <> '' then
            Context.SetContext('confirmString', ConfirmString);
    end;

    local procedure SetNumberOfGuests(Context: Codeunit "NPR POS JSON Helper")
    begin
        Context.SetContext('numberOfGuests', Context.GetInteger('numberOfGuests'));
    end;

    local procedure NewWaiterPad(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        BusinessLogic: Codeunit "NPR POSAction New Wa. Pad-B";
        SeatingCode: Code[20];
        NumberOfGuests: Integer;
        ActionMessage: Text;
        OpenWaiterPad: Boolean;
    begin
        SeatingCode := CopyStr(Context.GetString('seatingCode'), 1, MaxStrLen(SeatingCode));
        if not Context.GetInteger('numberOfGuests', NumberOfGuests) then
            NumberOfGuests := 0;
        if not Context.GetBooleanParameter('OpenWaiterPad', OpenWaiterPad) then
            OpenWaiterPad := false;

        BusinessLogic.NewWaiterPad(Sale, SeatingCode, NumberOfGuests, OpenWaiterPad, ActionMessage);

        if not OpenWaiterPad and (ActionMessage <> '') then
            Context.SetContext('actionMessage', ActionMessage);
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        POSActRVNewWPadB: Codeunit "NPR POSAct. RV New WPad-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(POSSetup);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        Context.SetContext('restaurantCode', POSSetup.RestaurantCode());

        if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
            Seating.Get(SalePOS."NPRE Pre-Set Seating Code");
            Context.SetContext('seatingCode', SalePOS."NPRE Pre-Set Seating Code");
            Context.SetContext('defaultNumberOfGuests', POSActRVNewWPadB.GetDefaultNumberOfGuests(SalePOS."NPRE Pre-Set Seating Code"));
        end;
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
        //###NPR_INJECT_FROM_FILE:POSActionNewWaPad.js###
'let main=async({workflow:n,popup:a,parameters:i,context:e,captions:s})=>{if(await n.respond("addPresetValuesToContext"),!e.seatingCode||!i.UseSeatingFromContext)if(e.seatingCode="",i.FixedSeatingCode)e.seatingCode=i.FixedSeatingCode;else switch(i.InputType+""){case"0":e.seatingCode=await a.input({caption:s.InputTypeLabel});break;case"1":e.seatingCode=await a.numpad({caption:s.InputTypeLabel});break;case"2":await n.respond("seatingInput");break}!e.seatingCode||e.confirmString&&(result=await a.confirm({title:s.ConfirmLabel,caption:e.confirmString}),!result)||i.AskForNumberOfGuests&&(e.numberOfGuests=await a.numpad({caption:s.NumberOfGuestsLabel,value:e.defaultNumberOfGuests}),e.numberOfGuests===null)||(e.seatingCode&&await n.respond("newWaiterPad"),e.actionMessage&&a.message({title:s.ActionMessageLabel,caption:e.actionMessage}))};'
        );
    end;
}
