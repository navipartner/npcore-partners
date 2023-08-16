codeunit 6150661 "NPR NPRE POSAction: Print Wa." implements "NPR IPOS Workflow"
{
    Access = Internal;

    internal procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::PRINT_WAITER_PAD));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        NPRESeating: Record "NPR NPRE Seating";
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
        ParamShowOnlyActiveWaiPad_CptLbl: Label 'Show Only Active Waiter Pads';
        ParamShowOnlyActiveWaiPad_DescLbl: Label 'Specifies if only active waiter pads will be shown.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
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
        WorkflowConfig.AddBooleanParameter('ShowOnlyActiveWaiPad', false, ParamShowOnlyActiveWaiPad_CptLbl, ParamShowOnlyActiveWaiPad_DescLbl);
        WorkflowConfig.AddLabel('InputTypeLabel', NPRESeating.TableCaption);
        //type of report for printing could be added as a parameter as well if needed
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'addPresetValuesToContext':
                OnActionAddPresetValuesToContext(Context, Sale, Setup);
            'seatingInput':
                OnActionSeatingInput(Context);
            'selectWaiterPad':
                OnActionSelectWaiterPad(Context);
            'printWaiterPad':
                OnActionPrintWaiterPad(Context);
        end;
    end;

    local procedure OnActionAddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogic: Codeunit "NPR NPRE POSAction: Print WP-B";
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

    local procedure OnActionSeatingInput(Context: Codeunit "NPR POS JSON Helper")
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        WaiterPadPOSMgt.FindSeating(Context, Seating);
        Context.SetContext('seatingCode', Seating.Code);
    end;

    local procedure OnActionSelectWaiterPad(Context: Codeunit "NPR POS JSON Helper")
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

    local procedure OnActionPrintWaiterPad(Context: Codeunit "NPR POS JSON Helper")
    var
        BusinessLogic: Codeunit "NPR NPRE POSAction: Print WP-B";
    begin
        BusinessLogic.PrintWaiterPad(Context.GetString('waiterPadNo'));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPREPOSActionPrintWa.js###
'let main=async({workflow:e,popup:d,parameters:i,context:a,captions:n})=>{if(await e.respond("addPresetValuesToContext"),!a.seatingCode)if(a.seatingCode="",i.FixedSeatingCode)a.seatingCode=i.FixedSeatingCode;else switch(i.InputType+""){case"0":a.seatingCode=await d.input({caption:n.InputTypeLabel});break;case"1":a.seatingCode=await d.numpad({caption:n.InputTypeLabel});break;case"2":await e.respond("seatingInput");break}!a.seatingCode||(a.waiterPadNo||a.seatingCode&&await e.respond("selectWaiterPad"),!!a.waiterPadNo&&a.waiterPadNo&&await e.respond("printWaiterPad"))};'
        );
    end;
}
