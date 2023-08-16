codeunit 6150668 "NPR NPRE POSAction: Split Wa." implements "NPR IPOS Workflow"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR25.0';
    ObsoleteReason = 'Not supported in Dragonglass environment. Please use POS action ''SPLIT_BILL'' instead.';

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        NPRESeating: Record "NPR NPRE Seating";
        //ActionDescription: Label 'This built-in action splits waiter pads (bills). It can be run from both Sale and Restaurant View';
        ActionDescription: Label 'This action is not supported anymore. Please use POS action ''SPLIT_BILL'' instead.';
        ParamInputType_OptionLbl: Label 'stringPad,intPad,List', locked = true;
        ParamInputType_CptLbl: Label 'Seating Selection Method';
        ParamInputType_DescLbl: Label 'Specifies seating selection method.';
        ParamInputType_OptionCptLbl: Label 'stringPad,intPad,List';
        ParamFixedSeatingCode_CptLbl: Label 'Fixed Seating Code';
        ParamFixedSeatingCode_DescLbl: Label 'Defines fixed seating code that will be used.';
        ParamSeatingFilter_CptLbl: Label 'Seating Filter';
        ParamSeatingFilter_DescLbl: Label 'Specifies a filter for seating.';
        ParamLocationFilter_CptLbl: Label 'Location Filter';
        ParamLocationFilter_DescLbl: Label 'Specifies a filter for seating location.';
        ParamShowOnlyActiveWaiPad_CptLbl: Label 'Show Only Active Waiter Pads';
        ParamShowOnlyActiveWaiPad_DescLbl: Label 'Specifies whether only active waiter pads should be included in the scope.';
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
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        NotSupportedErr: Label 'This action is not supported anymore. Please use POS action ''SPLIT_BILL'' instead.';
    begin
        Error(NotSupportedErr);
        /*
        case Step of
            'addPresetValuesToContext':
                OnActionAddPresetValuesToContext(Context, POSSession);
            'seatingInput':
                OnActionSeatingInput(Context);
            'selectWaiterPad':
                OnActionSelectWaiterPad(Context);
            'splitWaiterPad':
                OnActionSplitWaiterPad(Context, POSSession);
        end;
        
    end;

    local procedure OnActionAddPresetValuesToContext(JSON: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSetup(POSSetup);

        JSON.SetContext('restaurantCode', POSSetup.RestaurantCode());

        if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
            NPRESeating.Get(SalePOS."NPRE Pre-Set Seating Code");
            JSON.SetContext('seatingCode', SalePOS."NPRE Pre-Set Seating Code");
        end;

        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
            NPREWaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            if SalePOS."NPRE Pre-Set Seating Code" <> '' then
                if not NPRESeatingWaiterPadLink.Get(NPRESeating.Code, NPREWaiterPad."No.") then
                    WaiterPadMgt.AddNewWaiterPadForSeating(NPRESeating.Code, NPREWaiterPad, NPRESeatingWaiterPadLink);
            WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, NPREWaiterPad, false);
            JSON.SetContext('waiterPadNo', SalePOS."NPRE Pre-Set Waiter Pad No.");
        end;
    end;

    local procedure OnActionSeatingInput(JSON: Codeunit "NPR POS JSON Helper")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);

        JSON.SetContext('seatingCode', NPRESeating.Code);
    end;

    local procedure OnActionSelectWaiterPad(JSON: Codeunit "NPR POS JSON Helper")
    var
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        if not NPREWaiterPadPOSMgt.SelectWaiterPad(NPRESeating, NPREWaiterPad) then
            exit;

        JSON.SetContext('waiterPadNo', NPREWaiterPad."No.");
    end;

    local procedure OnActionSplitWaiterPad(JSON: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPadNo: Code[20];
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        JSON.SetScopeRoot();
        WaiterPadNo := CopyStr(JSON.GetString('waiterPadNo'), 1, MaxStrLen(WaiterPadNo));
        NPREWaiterPad.Get(WaiterPadNo);

        NPREWaiterPadPOSMgt.SplitBill(NPREWaiterPad, POSSession, 1, true);
        */
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPREPOSActionSplitWa.js###
'let main=async({workflow:a,popup:d,parameters:i,context:e,captions:s})=>{debugger;if(await a.respond("addPresetValuesToContext"),!e.seatingCode)if(e.seatingCode="",i.FixedSeatingCode)e.seatingCode=i.FixedSeatingCode;else switch(i.InputType+""){case"0":e.seatingCode=await d.input({caption:s.InputTypeLabel});break;case"1":e.seatingCode=await d.numpad({caption:s.InputTypeLabel});break;case"2":await a.respond("seatingInput");break}!e.seatingCode||(e.waiterPadNo||e.seatingCode&&await a.respond("selectWaiterPad"),e.waiterPadNo&&await a.respond("splitWaiterPad"))};'
        );
    end;
}
