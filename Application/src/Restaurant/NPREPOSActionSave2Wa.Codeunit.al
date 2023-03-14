codeunit 6150666 "NPR NPRE POSAction: Save2Wa." implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        Text001: Label 'No Water Pad exists on %1\Create new Water Pad?';

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        NPRESeating: Record "NPR NPRE Seating";
        ActionDescription: Label 'This built-in action saves currently selected items to Waiter Pad and switches to the Restaurant View';
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
        WorkflowConfig.AddLabel('confirmLabel', NPRESeating.TableCaption);
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
        ConfirmString: Text;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSetup(POSSetup);

        JSON.SetContext('restaurantCode', POSSetup.RestaurantCode());

        if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
            NPRESeating.Get(SalePOS."NPRE Pre-Set Seating Code");
            JSON.SetContext('seatingCode', SalePOS."NPRE Pre-Set Seating Code");

            if SalePOS."NPRE Pre-Set Waiter Pad No." = '' then begin
                ConfirmString := GetConfirmString(NPRESeating);
                if ConfirmString <> '' then
                    JSON.SetContext('confirmString', ConfirmString);
            end;
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
    begin
        NPRESeatingWaiterPadLink.SetCurrentKey(Closed);
        NPRESeatingWaiterPadLink.SetRange(Closed, false);
        NPRESeatingWaiterPadLink.SetRange("Seating Code", NPRESeating.Code);
        if NPRESeatingWaiterPadLink.FindFirst() then
            exit('');

        ConfirmString := StrSubstNo(Text001, NPRESeating.Code);
        exit(ConfirmString);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPREPOSActionSave2Wa.js###
'let main=async({workflow:e,context:a,popup:i,parameters:n,captions:d})=>{if(await e.respond("AddPresetValuesToContext"),!a.seatingCode)if(n.FixedSeatingCode)a.seatingCode=n.FixedSeatingCode;else switch(param.InputType+""){case"0":a.seatingCode=await i.input({caption:d.InputTypeLabel});break;case"1":a.seatingCode=await i.numpad({caption:d.InputTypeLabel});break;case"2":await e.respond("seatingInput");break}if(a.seatingCode&&a.confirmString)if(await i.confirm({caption:d.confirmLabel,label:a.confirmString}))await e.respond("createNewWaiterPad");else return;a.waiterPadNo||a.seatingCode&&await e.respond("selectWaiterPad"),a.waiterPadNo&&await e.respond("saveSale2Pad")};'
        );
    end;
}
