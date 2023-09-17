codeunit 6150666 "NPR POSAction: Save2Wa." implements "NPR IPOS Workflow"
{
    Access = Internal;

    internal procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::SAVE_TO_WAITER_PAD));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        NPRESeating: Record "NPR NPRE Seating";
        POSDataMgt: Codeunit "NPR POS Data Management";
        ActionDescription: Label 'This built-in action saves currently selected items to Waiter Pad and switches to the Restaurant View';
        ConfirmLabelLbl: Label 'Create new waiter pad?';
        ParamInputType_OptLbl: Label 'stringPad,intPad,List', locked = true;
        ParamInputType_NameLbl: Label 'Input Type';
        ParamInputType_DescLbl: Label 'Specifies waiter pad input type.';
        ParamInputType_OptDescLbl: Label 'stringPad,intPad,List';
        ParamFixedSeatingCode_CptLbl: Label 'Fixed Seating Code';
        ParamFixedSeatingCode_DescLbl: Label 'Defines fixed seating code that will be used.';
        ParamSeatingFilter_CptLbl: Label 'Seating Filter';
        ParamSeatingFilter_DescLbl: Label 'Specifies a filter for seating.';
        ParamLocationFilter_CptLbl: Label 'Location Filter';
        ParamLocationFilter_DescLbl: Label 'Specifies a filter for seating location.';
        ParamOpenWaiterPad_CptLbl: Label 'Open Waiter Pad';
        ParamOpenWaiterPad_DescLbl: Label 'Opens selected waiter pad.';
        ParamShowOnlyActiveWaiPad_CptLbl: Label 'Show Only Active Waiter Pads';
        ParamShowOnlyActiveWaiPad_DescLbl: Label 'Specifies whether only active waiter pads should be included in the scope.';
        ParamReturnToDefaultView_CptLbl: Label 'Return to Default View on Finish';
        ParamReturnToDefaultView_DescLbl: Label 'Switch to the default view defined for the POS Unit after the Waiter Pad Action has completed.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSaleLine());
        WorkflowConfig.AddOptionParameter('InputType',
                                          ParamInputType_OptLbl,
                                          CopyStr(SelectStr(1, ParamInputType_OptLbl), 1, 250),
                                          ParamInputType_NameLbl,
                                          ParamInputType_DescLbl,
                                          ParamInputType_OptDescLbl);
        WorkflowConfig.AddTextParameter('FixedSeatingCode', '', ParamFixedSeatingCode_CptLbl, ParamFixedSeatingCode_DescLbl);
        WorkflowConfig.AddTextParameter('SeatingFilter', '', ParamSeatingFilter_CptLbl, ParamSeatingFilter_DescLbl);
        WorkflowConfig.AddTextParameter('LocationFilter', '', ParamLocationFilter_CptLbl, ParamLocationFilter_DescLbl);
        WorkflowConfig.AddBooleanParameter('OpenWaiterPad', false, ParamOpenWaiterPad_CptLbl, ParamOpenWaiterPad_DescLbl);
        WorkflowConfig.AddBooleanParameter('ShowOnlyActiveWaiPad', false, ParamShowOnlyActiveWaiPad_CptLbl, ParamShowOnlyActiveWaiPad_DescLbl);
        WorkflowConfig.AddBooleanParameter('ReturnToDefaultView', false, ParamReturnToDefaultView_CptLbl, ParamReturnToDefaultView_DescLbl);
        WorkflowConfig.AddLabel('InputTypeLabel', NPRESeating.TableCaption);
        WorkflowConfig.AddLabel('confirmLabel', ConfirmLabelLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'addPresetValuesToContext':
                AddPresetValuesToContext(Context, Sale, Setup);
            'seatingInput':
                SeatingInput(Context);
            'createNewWaiterPad':
                CreateNewWaiterPad(Context, Sale);
            'selectWaiterPad':
                SelectWaiterPad(Context);
            'saveSale2Pad':
                SaveSale2Pad(Context, Sale);
        end;
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogic: Codeunit "NPR POSAction: Save2WP-B";
        RestaurantCode: Code[20];
        SeatingCode: Code[20];
        WaiterPadNo: Code[20];
    begin
        BusinessLogic.GetPresetValues(Sale, Setup, RestaurantCode, SeatingCode, WaiterPadNo);
        Context.SetContext('restaurantCode', RestaurantCode);
        if SeatingCode <> '' then
            Context.SetContext('seatingCode', SeatingCode);
        if WaiterPadNo <> '' then
            Context.SetContext('waiterPadNo', WaiterPadNo);
    end;

    local procedure SeatingInput(Context: Codeunit "NPR POS JSON Helper")
    var
        Seating: Record "NPR NPRE Seating";
        BusinessLogic: Codeunit "NPR POSAction: Save2WP-B";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        ConfirmString: Text;
    begin
        WaiterPadPOSMgt.FindSeating(Context, Seating);
        Context.SetContext('seatingCode', Seating.Code);
        ConfirmString := BusinessLogic.GetSeatingConfirmString(Seating);
        if ConfirmString <> '' then
            Context.SetContext('confirmString', ConfirmString);
    end;

    local procedure CreateNewWaiterPad(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        Sale.GetCurrentSale(SalePOS);
        WaiterPadPOSMgt.FindSeating(Context, Seating);
        WaiterPadMgt.CreateNewWaiterPad(Seating.Code, SalePOS."NPRE Number of Guests", SalePOS."Salesperson Code", '', WaiterPad);
    end;

    local procedure SelectWaiterPad(Context: Codeunit "NPR POS JSON Helper")
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        WaiterPadPOSMgt.FindSeating(Context, Seating);
        if not WaiterPadPOSMgt.SelectWaiterPad(Seating, WaiterPad) then
            exit;

        Context.SetContext('waiterPadNo', WaiterPad."No.");
    end;

    local procedure SaveSale2Pad(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        BusinessLogic: Codeunit "NPR POSAction: Save2WP-B";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPadNo: Code[20];
        OpenWaiterPad: Boolean;
        ReturnToDefaultView: Boolean;
        SaleCleanupSuccessful: Boolean;
    begin
        WaiterPadNo := CopyStr(Context.GetString('waiterPadNo'), 1, MaxStrLen(WaiterPadNo));
        if not Context.GetBooleanParameter('OpenWaiterPad', OpenWaiterPad) then
            OpenWaiterPad := false;
        if not Context.GetBooleanParameter('ReturnToDefaultView', ReturnToDefaultView) then
            ReturnToDefaultView := false;

        BusinessLogic.SaveSale2WPad(Sale, WaiterPadNo, OpenWaiterPad, SaleCleanupSuccessful);

        if ReturnToDefaultView and SaleCleanupSuccessful then
            Sale.SelectViewForEndOfSale();
        if not SaleCleanupSuccessful then begin
            Context.SetContext('ShowResultMessage', true);
            Context.SetContext('ResultMessageText', WaiterPadPOSMgt.UnableToCleanupSaleMsgText(false));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionSave2Wa.js###
'let main=async({workflow:a,context:e,popup:s,parameters:d,captions:t})=>{if(await a.respond("addPresetValuesToContext"),!e.seatingCode)if(d.FixedSeatingCode)e.seatingCode=d.FixedSeatingCode;else switch(d.InputType+""){case"0":{let i=await s.input({caption:t.InputTypeLabel});if(!i)return;e.seatingCode=i;break}case"1":{let i=await s.numpad({caption:t.InputTypeLabel});if(!i)return;e.seatingCode=i;break}}if(await a.respond("seatingInput"),!!e.seatingCode){if(e.seatingCode&&e.confirmString)if(await s.confirm({title:t.confirmLabel,caption:e.confirmString}))await a.respond("createNewWaiterPad");else return;e.waiterPadNo||e.seatingCode&&await a.respond("selectWaiterPad"),e.waiterPadNo&&await a.respond("saveSale2Pad"),e.ShowResultMessage&&s.message(e.ResultMessageText)}};'
        );
    end;
}
