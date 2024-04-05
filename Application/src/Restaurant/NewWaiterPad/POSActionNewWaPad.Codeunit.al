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
        ParamAskForCustomerEmail_CptLbl: Label 'Request customer email';
        ParamAskForCustomerEmail_DescLbl: Label 'Ask for customer email address.';
        ParamAskForCustomerName_CptLbl: Label 'Request customer name';
        ParamAskForCustomerName_DescLbl: Label 'Ask for customer name.';
        ParamAskForCustomerPhoneNo_CptLbl: Label 'Request customer phone No.';
        ParamAskForCustomerPhoneNo_DescLbl: Label 'Ask for customer phone number.';
        ParamUseSeatingFromContext_CptLbl: Label 'Use seating from context';
        ParamUseSeatingFromContext_DescLbl: Label 'Use seating code from context.';
        ParamHideConfirmDialog_CptLbl: Label 'Hide Confirmation';
        ParamHideConfirmDialog_DescLbl: Label 'Hide the confirmation dialog about the number of existing waiter pads for the seating.';
        ConfirmLbl: Label 'Open new waiter pad?';
        ActionMessageLbl: Label 'New Waiter Pad';
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
        WorkflowConfig.AddBooleanParameter('RequestCustomerName', false, ParamAskForCustomerName_CptLbl, ParamAskForCustomerName_DescLbl);
        WorkflowConfig.AddBooleanParameter('RequestCustomerPhone', false, ParamAskForCustomerPhoneNo_CptLbl, ParamAskForCustomerPhoneNo_DescLbl);
        WorkflowConfig.AddBooleanParameter('RequestCustomerEmail', false, ParamAskForCustomerEmail_CptLbl, ParamAskForCustomerEmail_DescLbl);
        WorkflowConfig.AddBooleanParameter('UseSeatingFromContext', false, ParamUseSeatingFromContext_CptLbl, ParamUseSeatingFromContext_DescLbl);
        WorkflowConfig.AddBooleanParameter('HideConfirmDialog', false, ParamHideConfirmDialog_CptLbl, ParamHideConfirmDialog_DescLbl);
        WorkflowConfig.AddLabel('InputTypeLabel', NPRESeating.TableCaption);
        WorkflowConfig.AddLabel('ConfirmLabel', ConfirmLbl);
        WorkflowConfig.AddLabel('ActionMessageLabel', ActionMessageLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'addPresetValuesToContext':
                AddPresetValuesToContext(Context, Sale, Setup);
            'seatingInput':
                SeatingInput(Context);
            'setNumberOfGuests':
                SetNumberOfGuests(Context);
            'newWaiterPad':
                NewWaiterPad(Context, Sale);
        end;
    end;

    local procedure SeatingInput(Context: Codeunit "NPR POS JSON Helper")
    var
        Seating: Record "NPR NPRE Seating";
        BusinessLogic: Codeunit "NPR POSAction New Wa. Pad-B";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        ConfirmString: Text;
    begin
        WaiterPadPOSMgt.FindSeating(Context, Seating);
        Context.SetContext('seatingCode', Seating.Code);
        if HideConfirmDialog(Context) then
            exit;
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
        WaiterPad: Record "NPR NPRE Waiter Pad";
        BusinessLogic: Codeunit "NPR POSAction New Wa. Pad-B";
        CustomerDetails: Dictionary of [Text, Text];
        SeatingCode: Code[20];
        ActionMessage: Text;
        OpenWaiterPad: Boolean;
    begin
        SeatingCode := CopyStr(Context.GetString('seatingCode'), 1, MaxStrLen(SeatingCode));
        if not Context.GetBooleanParameter('OpenWaiterPad', OpenWaiterPad) then
            OpenWaiterPad := false;

        CustomerDetails.Add(WaiterPad.FieldName(Description), TableName(Context));
        CustomerDetails.Add(WaiterPad.FieldName("Customer Phone No."), PhoneNo(Context));
        CustomerDetails.Add(WaiterPad.FieldName("Customer E-Mail"), Email(Context));
        BusinessLogic.NewWaiterPad(Sale, SeatingCode, CustomerDetails, PartySize(Context), OpenWaiterPad, ActionMessage);

        if not OpenWaiterPad and (ActionMessage <> '') and not HideConfirmDialog(Context) then
            Context.SetContext('actionMessage', ActionMessage);
    end;

    local procedure HideConfirmDialog(Context: Codeunit "NPR POS JSON Helper"): Boolean
    var
        ParamValue: Boolean;
    begin
        if not Context.GetBooleanParameter('HideConfirmDialog', ParamValue) then
            ParamValue := false;
        exit(ParamValue);
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale"; POSSetup: Codeunit "NPR POS Setup")
    var
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterpadInfoConfig: JsonObject;
        RestaurantCode: Code[20];
        AskForNumberOfGuests: Boolean;
        RequestCustomerName: Boolean;
        RequestCustomerPhone: Boolean;
        RequestCustomerEmail: Boolean;
    begin
        RestaurantCode := POSSetup.RestaurantCode();
        POSSale.GetCurrentSale(SalePOS);
        Context.SetContext('restaurantCode', RestaurantCode);
        if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
            Seating.Get(SalePOS."NPRE Pre-Set Seating Code");
            Context.SetContext('seatingCode', SalePOS."NPRE Pre-Set Seating Code");
        end else
            if RestaurantCode <> '' then begin
                Seating.SetFilter("Seating Location", SeatingMgt.RestaurantSeatingLocationFilter(RestaurantCode));
                if Seating.Count() = 1 then begin
                    Seating.FindFirst();
                    Context.SetContext('seatingCode', Seating.Code);
                end;
            end;

        if Context.GetBooleanParameter('AskForNumberOfGuests', AskForNumberOfGuests) then;
        if Context.GetBooleanParameter('RequestCustomerName', RequestCustomerName) then;
        if Context.GetBooleanParameter('RequestCustomerPhone', RequestCustomerPhone) then;
        if Context.GetBooleanParameter('RequestCustomerEmail', RequestCustomerEmail) then;
        if WaiterPadPOSMgt.GenerateNewWaiterPadConfig(SalePOS, AskForNumberOfGuests, RequestCustomerName, RequestCustomerPhone, RequestCustomerEmail, WaiterpadInfoConfig) then begin
            Context.SetContext('requestCustomerInfo', true);
            Context.SetContext('waiterpadInfoConfig', WaiterpadInfoConfig);
        end else
            Context.SetContext('requestCustomerInfo', false);
    end;

    local procedure TableName(Context: Codeunit "NPR POS JSON Helper"): Text
    begin
        exit(GetConfigurableOption(Context, 'waiterpadInfo', 'tablename'));
    end;

    local procedure PhoneNo(Context: Codeunit "NPR POS JSON Helper"): Text
    begin
        exit(GetConfigurableOption(Context, 'waiterpadInfo', 'phoneNo'));
    end;

    local procedure Email(Context: Codeunit "NPR POS JSON Helper"): Text
    begin
        exit(GetConfigurableOption(Context, 'waiterpadInfo', 'email'));
    end;

    local procedure PartySize(Context: Codeunit "NPR POS JSON Helper"): Integer
    var
        NumberOfGuests: Integer;
    begin
        if not Evaluate(NumberOfGuests, GetConfigurableOption(Context, 'waiterpadInfo', 'guests')) then
            NumberOfGuests := 1;
        exit(NumberOfGuests);
    end;

    local procedure GetConfigurableOption(Context: Codeunit "NPR POS JSON Helper"; Scope: Text; "Key": Text): Text
    var
        ResultOut: text;
    begin
        Context.SetScopeRoot();
        if not Context.TrySetScope(Scope) then
            exit('');

        if Context.GetString("Key", ResultOut) then
            exit(ResultOut)
        else
            exit('');
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
        DataSource.AddColumn('NoOfGuests', 'Number of guests', DataType::String, true);
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
        DataRow.Add('NoOfGuests', Format(SalePOS."NPRE Number of Guests", 0, 9));
        DataRow.Add('TableStatus', Seating."Status Description FF");
        DataRow.Add('WPadStatus', WaiterPad."Status Description FF");
        DataRow.Add('MealFlowStatus', WaiterPad."Serving Step Description");
        DataRow.Add('AssignedWaiter', StrSubstNo(AssignedWiaterLbl, WaiterPad."Assigned Waiter Code", Salesperson.Name));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionNewWaPad.js###
'let main=async({workflow:s,popup:a,parameters:e,context:i,captions:n})=>{if(await s.respond("addPresetValuesToContext"),!i.seatingCode||!e.UseSeatingFromContext)if(i.seatingCode="",e.FixedSeatingCode)i.seatingCode=e.FixedSeatingCode;else switch(e.InputType+""){case"0":i.seatingCode=await a.input({caption:n.InputTypeLabel});break;case"1":i.seatingCode=await a.numpad({caption:n.InputTypeLabel});break;case"2":await s.respond("seatingInput");break}!i.seatingCode||i.confirmString&&(result=await a.confirm({title:n.ConfirmLabel,caption:i.confirmString}),!result)||i.requestCustomerInfo&&(i.waiterpadInfo=await a.configuration(i.waiterpadInfoConfig),i.waiterpadInfo===null)||(i.seatingCode&&await s.respond("newWaiterPad"),i.actionMessage&&a.message({title:n.ActionMessageLabel,caption:i.actionMessage}))};'
        );
    end;
}
