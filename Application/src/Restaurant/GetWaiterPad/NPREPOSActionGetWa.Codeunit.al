codeunit 6150667 "NPR NPRE POSAction: Get Wa." implements "NPR IPOS Workflow"
{
    Access = Internal;

    internal procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::GET_WAITER_PAD));
    end;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        NPRESeating: Record "NPR NPRE Seating";
        ActionDescriptionLbl: Label 'Transfer Waiter Pad to POS Sale';
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
        ParamActiveWaiPad_CptLbl: Label 'Show Only Active Waiter Pad';
        ParamActiveWaiPad_DescLbl: Label 'Specifies whether to show only active waiter pad.';
        ParamWarning_CaptLbl: Label 'Warning Before Table Retrieval';
        ParamWarning_DescLbl: Label 'Specifies whether to show warning before table retrieval.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddOptionParameter('InputType',
                                        ParamInputType_OptionLbl,
                                        CopyStr(SelectStr(1, ParamInputType_OptionLbl), 1, 250),
                                        ParamInputType_CptLbl,
                                        ParamInputType_DescLbl,
                                        ParamInputType_OptionCptLbl);
        WorkflowConfig.AddTextParameter('FixedSeatingCode', '', ParamFixedSeatingCode_CptLbl, ParamFixedSeatingCode_DescLbl);
        WorkflowConfig.AddTextParameter('SeatingFilter', '', ParamSeatingFilter_CptLbl, ParamSeatingFilter_DescLbl);
        WorkflowConfig.AddTextParameter('LocationFilter', '', ParamLocationFilter_CptLbl, ParamLocationFilter_DescLbl);
        WorkflowConfig.AddBooleanParameter('ShowOnlyActiveWaiPad', false, ParamActiveWaiPad_CptLbl, ParamActiveWaiPad_DescLbl);
        WorkflowConfig.AddBooleanParameter('WarnBeforeTableRetrieval', false, ParamWarning_CaptLbl, ParamWarning_DescLbl);
        WorkflowConfig.AddLabel('InputTypeLabel', NPRESeating.TableCaption);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'addPresetValuesToContext':
                OnActionAddPresetValuesToContext(Context, Setup);
            'seatingInput':
                OnActionSeatingInput(Context);
            'selectWaiterPad':
                OnActionSelectWaiterPad(Context);
            'getSaleFromPad':
                OnActionGetSaleFromPad(Context);
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPREPOSActionGetWa.js###
'let main=async({workflow:a,popup:d,parameters:i,context:e,captions:n})=>{if(await a.respond("addPresetValuesToContext"),i.FixedSeatingCode)e.seatingCode=i.FixedSeatingCode;else switch(i.InputType+""){case"0":e.seatingCode=await d.input({caption:n.InputTypeLabel});break;case"1":e.seatingCode=await d.numpad({caption:n.InputTypeLabel});break;case"2":await a.respond("seatingInput");break}!e.seatingCode||(e.seatingCode&&await a.respond("selectWaiterPad"),e.waiterPadNo&&await a.respond("getSaleFromPad"))};'
        );
    end;

    local procedure OnActionSeatingInput(Context: Codeunit "NPR POS JSON Helper")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WarnBeforeTableRetrieval: Boolean;
        ConfirmTableCaption: Label 'Are you sure you want to retrieve from %1?';
    begin
        NPREWaiterPadPOSMgt.FindSeating(Context, NPRESeating);

        if not Context.GetBooleanParameter('WarnBeforeTableRetrieval', WarnBeforeTableRetrieval) then
            WarnBeforeTableRetrieval := false;
        if WarnBeforeTableRetrieval then
            if not Confirm(ConfirmTableCaption, true, NPRESeating.Description) then
                Error('');

        Context.SetContext('seatingCode', NPRESeating.Code);
    end;

    local procedure OnActionSelectWaiterPad(Context: Codeunit "NPR POS JSON Helper")
    var
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        NPREWaiterPadPOSMgt.FindSeating(Context, NPRESeating);
        if not NPREWaiterPadPOSMgt.SelectWaiterPad(NPRESeating, NPREWaiterPad) then
            exit;

        Context.SetContext('waiterPadNo', NPREWaiterPad."No.");
    end;

    local procedure OnActionGetSaleFromPad(Context: Codeunit "NPR POS JSON Helper")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPadNo: Code[20];
    begin
        NPREWaiterPadPOSMgt.FindSeating(Context, NPRESeating);
        Context.SetScopeRoot();
        WaiterPadNo := CopyStr(Context.GetString('waiterPadNo'), 1, MaxStrLen(WaiterPadNo));
        NPREWaiterPad.Get(WaiterPadNo);

        NPREWaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(NPREWaiterPad, POSSession);
    end;

    local procedure OnActionAddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; POSSetup: Codeunit "NPR POS Setup")
    begin
        Context.SetContext('restaurantCode', POSSetup.RestaurantCode());
    end;
}
