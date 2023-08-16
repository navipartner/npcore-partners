codeunit 6150669 "NPR NPRE POSAction: Show Wa." implements "NPR IPOS Workflow"
{
    Access = Internal;

    internal procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::SHOW_WAITER_PAD));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        NPRESeating: Record "NPR NPRE Seating";
        ActionDescription: Label 'This is a built in function for handling move between pos and waiter pad.';
        ParamActiveWaiterPad_CptLbl: Label 'Show Only Active Waiter Pad';
        ParamActiveWaiterPad_DescLbl: Label 'Specifies whether to show only active waiter pad.';
        ParamFixedSeatingCode_CptLbl: Label 'Fixed Seating Code';
        ParamFixedSeatingCode_DescLbl: Label 'Specifies seating number the action is to be run upon.';
        ParamInputType_CptLbl: Label 'Seating Selection Method';
        ParamInputType_DescLbl: Label 'Specifies seating selection method.';
        ParamInputType_OptionCptLbl: Label 'stringPad,intPad,List';
        ParamInputType_OptionLbl: Label 'stringPad,intPad,List', Locked = true;
        ParamLocationFilter_CptLbl: Label 'Location Filter';
        ParamLocationFilter_DescLbl: Label 'Specifies a filter for seating location.';
        ParamSeatingFilter_CptLbl: Label 'Seating Filter';
        ParamSeatingFilter_DescLbl: Label 'Specifies a filter for seating.';
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
        WorkflowConfig.AddBooleanParameter('ShowOnlyActiveWaiPad', false, ParamActiveWaiterPad_CptLbl, ParamActiveWaiterPad_DescLbl);
        WorkflowConfig.AddLabel('InputTypeLabel', NPRESeating.TableCaption);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'addPresetValuesToContext':
                OnActionAddPresetValuesToContext(Context);
            'seatingInput':
                OnActionSeatingInput(Context);
            'selectWaiterPad':
                OnActionSelectWaiterPad(Context);
            'showWaiterPad':
                OnActionShowWaiterPad(Context);
        end;
    end;

    local procedure OnActionSeatingInput(Context: Codeunit "NPR POS JSON Helper")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        NPREWaiterPadPOSMgt.FindSeating(Context, NPRESeating);

        Context.SetContext('seatingCode', NPRESeating.Code);
    end;

    local procedure OnActionSelectWaiterPad(Context: Codeunit "NPR POS JSON Helper")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        NPREWaiterPadPOSMgt.FindSeating(Context, NPRESeating);
        if not NPREWaiterPadPOSMgt.SelectWaiterPad(NPRESeating, NPREWaiterPad) then
            exit;

        Context.SetContext('waiterPadNo', NPREWaiterPad."No.");
    end;

    local procedure OnActionShowWaiterPad(Context: Codeunit "NPR POS JSON Helper")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPadNo: Code[20];
    begin
        NPREWaiterPadPOSMgt.FindSeating(Context, NPRESeating);
        Context.SetScopeRoot();
        WaiterPadNo := CopyStr(Context.GetString('waiterPadNo'), 1, MaxStrLen(WaiterPadNo));
        NPREWaiterPad.Get(WaiterPadNo);

        NPREWaiterPadPOSMgt.UIShowWaiterPad(NPREWaiterPad);
    end;

    local procedure OnActionAddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper")
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSetup(POSSetup);

        Context.SetContext('restaurantCode', POSSetup.RestaurantCode());

        if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
            Context.SetContext('seatingCode', SalePOS."NPRE Pre-Set Seating Code");
            if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then
                Context.SetContext('waiterPadNo', SalePOS."NPRE Pre-Set Waiter Pad No.");
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPREPOSActionShowWa.js###
'let main=async({workflow:e,popup:d,parameters:i,context:a,captions:s})=>{if(await e.respond("addPresetValuesToContext"),!a.seatingCode)if(i.FixedSeatingCode)a.seatingCode=i.FixedSeatingCode;else switch(i.InputType+""){case"0":a.seatingCode=await d.input({caption:s.InputTypeLabel});break;case"1":a.seatingCode=await d.numpad({caption:s.InputTypeLabel});break;case"2":await e.respond("seatingInput");break}a.waiterPadNo||a.seatingCode&&await e.respond("selectWaiterPad"),a.waiterPadNo&&await e.respond("showWaiterPad")};'
        );
    end;
}
