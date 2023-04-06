codeunit 6150666 "NPR NPRE POSAction: Save2Wa." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        NPRESeating: Record "NPR NPRE Seating";
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
        WorkflowConfig.SetDataSourceBinding('BUILTIN_SALELINE');
        WorkflowConfig.AddOptionParameter('InputType',
                                          ParamInputType_OptLbl,
#pragma warning disable AA0139
                                          SelectStr(1, ParamInputType_OptLbl),
#pragma warning restore                                          
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
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        case Step of
            'addPresetValuesToContext':
                AddPresetValuesToContext(Context, POSSession);
            'seatingInput':
                SeatingInput(Context);
            'createNewWaiterPad':
                CreateNewWaiterPad(Context, POSSession);
            'selectWaiterPad':
                SelectWaiterPad(Context);
            'saveSale2Pad':
                SaveSale2Pad(Context, POSSession);
        end;
    end;

    local procedure AddPresetValuesToContext(JSON: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
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
            JSON.SetContext('waiterPadNo', SalePOS."NPRE Pre-Set Waiter Pad No.");
        end;
    end;

    local procedure SeatingInput(JSON: Codeunit "NPR POS JSON Helper")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        ConfirmString: Text;
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);

        JSON.SetContext('seatingCode', NPRESeating.Code);
        ConfirmString := GetConfirmString(NPRESeating);
        if ConfirmString <> '' then
            JSON.SetContext('confirmString', ConfirmString);
    end;

    local procedure CreateNewWaiterPad(JSON: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSale: Codeunit "NPR POS Sale";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        WaiterPadPOSMgt.FindSeating(JSON, Seating);
        WaiterPadMgt.CreateNewWaiterPad(Seating.Code, SalePOS."NPRE Number of Guests", SalePOS."Salesperson Code", '', WaiterPad);
    end;

    local procedure SelectWaiterPad(JSON: Codeunit "NPR POS JSON Helper")
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

    local procedure SaveSale2Pad(JSON: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session")
    var
        NPRESeating: Record "NPR NPRE Seating";
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        WaiterPadNo: Code[20];
        OpenWaiterPad: Boolean;
        ReturnToDefaultView: Boolean;
    begin
        NPREWaiterPadPOSMgt.FindSeating(JSON, NPRESeating);
        JSON.SetScopeRoot();
        WaiterPadNo := CopyStr(JSON.GetString('waiterPadNo'), 1, MaxStrLen(WaiterPadNo));
        NPREWaiterPad.Get(WaiterPadNo);

        if not JSON.GetBooleanParameter('OpenWaiterPad', OpenWaiterPad) then
            OpenWaiterPad := false;
        if not JSON.GetBooleanParameter('ReturnToDefaultView', ReturnToDefaultView) then
            ReturnToDefaultView := false;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        NPREWaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, NPREWaiterPad, true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        Commit();

        if OpenWaiterPad then
            NPREWaiterPadPOSMgt.UIShowWaiterPad(NPREWaiterPad);

        if ReturnToDefaultView then
            POSSale.SelectViewForEndOfSale(POSSession);
    end;

    local procedure GetConfirmString(NPRESeating: Record "NPR NPRE Seating") ConfirmString: Text
    var
        NPRESeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        NoWaiterPadOnSeatingQst: Label 'There are no open waiter pads exist for seating %1. Do you want to create a new one?';
    begin
        NPRESeatingWaiterPadLink.SetRange(Closed, false);
        NPRESeatingWaiterPadLink.SetRange("Seating Code", NPRESeating.Code);
        if not NPRESeatingWaiterPadLink.IsEmpty() then
            exit('');

        ConfirmString := StrSubstNo(NoWaiterPadOnSeatingQst, NPRESeating.Code);
        exit(ConfirmString);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPREPOSActionSave2Wa.js###
'let main=async({workflow:a,context:e,popup:n,parameters:t,captions:d})=>{if(await a.respond("AddPresetValuesToContext"),!e.seatingCode)if(t.FixedSeatingCode)e.seatingCode=t.FixedSeatingCode;else switch(t.InputType+""){case"0":{let i=await n.input({caption:d.InputTypeLabel});if(!i)return;e.seatingCode=i;break}case"1":{let i=await n.numpad({caption:d.InputTypeLabel});if(!i)return;e.seatingCode=i;break}}if(await a.respond("seatingInput"),!!e.seatingCode){if(e.seatingCode&&e.confirmString)if(await n.confirm({title:d.confirmLabel,caption:e.confirmString}))await a.respond("createNewWaiterPad");else return;e.waiterPadNo||e.seatingCode&&await a.respond("selectWaiterPad"),e.waiterPadNo&&await a.respond("saveSale2Pad")}};'
        );
    end;
}
