codeunit 6150670 "NPR NPRE POS Action: SplitBill" implements "NPR IPOS Workflow"
{
    Access = Internal;

    internal procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::SPLIT_BILL));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action splits waiter pads (bills). It can be run from both Sale and Restaurant View';
        ParamInputType_OptionLbl: Label 'stringPad,intPad,List', locked = true;
        ParamInputType_CptLbl: Label 'Seating Selection Method';
        ParamInputType_DescLbl: Label 'Specifies seating selection method.';
        ParamInputType_OptionCptLbl: Label 'stringPad,intPad,List';
        ParamWaiterPadCode_CptLbl: Label 'Waiter Pad Code';
        ParamWaiterPadCode_DescLbl: Label 'Defines waiter pad number the action is to be run upon. The parameter is set automatically by the system and should not be preset manually.';
        ParamSeatingCode_CptLbl: Label 'Seating Code';
        ParamSeatingCode_DescLbl: Label 'Specifies seating number the action is to be run upon.';
        ParamSeatingFilter_CptLbl: Label 'Seating Filter';
        ParamSeatingFilter_DescLbl: Label 'Specifies a filter for seating.';
        ParamLocationFilter_CptLbl: Label 'Location Filter';
        ParamLocationFilter_DescLbl: Label 'Specifies a filter for seating location.';
        ParamIncludeAllWPads_OptionLbl: Label 'No,Yes,Ask', locked = true;
        ParamIncludeAllWPads_CptLbl: Label 'All Waiter Pads';
        ParamIncludeAllWPads_DescLbl: Label 'Specifies whether all assigned to a seating waiter pads should be included in the scope.';
        ParamIncludeAllWPads_OptionCptLbl: Label 'No,Yes,Ask';
        ParamReturnToDefaultView_CptLbl: Label 'Return to Default View on Finish';
        ParamReturnToDefaultView_DescLbl: Label 'Switch to the default view defined for the POS Unit after the Waiter Pad Action has completed.';
        LabelPopupCaptionLbl: Label 'Please configure your bills';
        LabelSeatingIDLbl: Label 'Seating Code';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddOptionParameter('InputType',
                                        ParamInputType_OptionLbl,
                                        CopyStr(SelectStr(1, ParamInputType_OptionLbl), 1, 250),
                                        ParamInputType_CptLbl,
                                        ParamInputType_DescLbl,
                                        ParamInputType_OptionCptLbl);
        WorkflowConfig.AddTextParameter('WaiterPadCode', '', ParamWaiterPadCode_CptLbl, ParamWaiterPadCode_DescLbl);
        WorkflowConfig.AddTextParameter('SeatingCode', '', ParamSeatingCode_CptLbl, ParamSeatingCode_DescLbl);
        WorkflowConfig.AddTextParameter('SeatingFilter', '', ParamSeatingFilter_CptLbl, ParamSeatingFilter_DescLbl);
        WorkflowConfig.AddTextParameter('LocationFilter', '', ParamLocationFilter_CptLbl, ParamLocationFilter_DescLbl);
        WorkflowConfig.AddOptionParameter('IncludeAllWPads',
                                        ParamIncludeAllWPads_OptionLbl,
                                        CopyStr(SelectStr(2, ParamIncludeAllWPads_OptionLbl), 1, 250),
                                        ParamIncludeAllWPads_CptLbl,
                                        ParamIncludeAllWPads_DescLbl,
                                        ParamIncludeAllWPads_OptionCptLbl);
        WorkflowConfig.AddBooleanParameter('ReturnToDefaultView', false, ParamReturnToDefaultView_CptLbl, ParamReturnToDefaultView_DescLbl);
        WorkflowConfig.AddLabel('PopupCaption', LabelPopupCaptionLbl);
        WorkflowConfig.AddLabel('SeatingIDLbl', LabelSeatingIDLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogic: Codeunit "NPR NPRE POS Action: SplitB.-B";
        CurrWaiterPadNo: Code[20];
        NothingToDoErr: Label 'Nothing has been changed';
    begin
        case Step of
            'AddPresetValuesToContext':
                AddPresetValuesToContext(Context, Sale, Setup);
            'SelectSeating':
                SelectSeating(Context);
            'SelectWaiterPad':
                SelectWaiterPad(Context);
            'GenerateSplitBillContext':
                begin
                    BusinessLogic.SaveChangesToWaiterPad(Sale);
                    GenerateSplitBillContext(Context);
                end;
            'DoSplit':
                begin
                    BusinessLogic.CleanupSale(SaleLine);
                    if not ProcessWaiterPadSplit(Context, CurrWaiterPadNo) then
                        Error(NothingToDoErr);
                    UpdateFrontEndView(Context, Sale, CurrWaiterPadNo);
                end;
        end;
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogic: Codeunit "NPR NPRE POS Action: SplitB.-B";
        RestaurantCode: Code[20];
        SeatingCode: Code[20];
        WaiterPadNo: Code[20];
        ParameterValueText: Text;
    begin
        ParameterValueText := '';
        if Context.GetStringParameter('SeatingCode', ParameterValueText) and (ParameterValueText <> '') then
            SeatingCode := CopyStr(ParameterValueText, 1, MaxStrLen(SeatingCode));
        ParameterValueText := '';
        if Context.GetStringParameter('WaiterPadCode', ParameterValueText) and (ParameterValueText <> '') then
            WaiterPadNo := CopyStr(ParameterValueText, 1, MaxStrLen(WaiterPadNo));

        BusinessLogic.GetPresetValues(Sale, Setup, RestaurantCode, SeatingCode, WaiterPadNo);

        Context.SetContext('restaurantCode', RestaurantCode);
        if SeatingCode <> '' then
            Context.SetContext('seatingCode', SeatingCode);
        if WaiterPadNo <> '' then
            Context.SetContext('waiterPadNo', WaiterPadNo);
    end;

    local procedure SelectSeating(Context: Codeunit "NPR POS JSON Helper")
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        WaiterPadPOSMgt.FindSeating(Context, Seating);
        Context.SetContext('seatingCode', Seating.Code);
    end;

    local procedure SelectWaiterPad(Context: Codeunit "NPR POS JSON Helper")
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        Seating: Record "NPR NPRE Seating";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        WaiterPadPOSMgt.FindSeating(Context, Seating);
        if not WaiterPadPOSMgt.SelectWaiterPad(Seating, WaiterPad) then
            exit;
        Context.SetContext('waiterPadNo', WaiterPad."No.");
    end;

    local procedure GenerateSplitBillContext(Context: Codeunit "NPR POS JSON Helper")
    var
        BusinessLogic: Codeunit "NPR NPRE POS Action: SplitB.-B";
        BillCollection: JsonArray;
        WPadLineCollection: JsonArray;
        SeatingParamValue: Text;
        SeatingCode: Code[20];
        WaiterPadNo: Code[20];
        IncludeAllWPads: Option No,Yes,Ask;
    begin
        WaiterPadNo := CopyStr(Context.GetString('waiterPadNo'), 1, MaxStrLen(WaiterPadNo));
        if Context.GetString('seatingCode', SeatingParamValue) then
            SeatingCode := CopyStr(SeatingParamValue, 1, MaxStrLen(SeatingCode));
        IncludeAllWPads := Context.GetIntegerParameter('IncludeAllWPads');

        BusinessLogic.GenerateSplitBillContext(WaiterPadNo, SeatingCode, IncludeAllWPads, WPadLineCollection, BillCollection);

        Context.SetContext('items', WPadLineCollection);
        if IncludeAllWPads = IncludeAllWPads::Yes then
            Context.SetContext('bills', BillCollection);
    end;

    local procedure ProcessWaiterPadSplit(Context: Codeunit "NPR POS JSON Helper"; var CurrWaiterPadNo: Code[20]) ChangesFound: Boolean
    var
        BusinessLogic: Codeunit "NPR NPRE POS Action: SplitB.-B";
        Bills: JsonToken;
        ContextJToken: JsonToken;
    begin
        CurrWaiterPadNo := CopyStr(Context.GetString('waiterPadNo'), 1, MaxStrLen(CurrWaiterPadNo));
        ContextJToken.ReadFrom(Context.ToString());
        if ContextJToken.SelectToken('bills', Bills) then
            ChangesFound := BusinessLogic.ProcessWaiterPadSplit(CurrWaiterPadNo, Bills);
    end;

    local procedure UpdateFrontEndView(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; WaiterPadNo: Code[20])
    var
        BusinessLogic: Codeunit "NPR NPRE POS Action: SplitB.-B";
        CurrentView: Codeunit "NPR POS View";
        POSSession: Codeunit "NPR POS Session";
        CleanupMessageText: Text;
        InSale: Boolean;
        ReturnToDefaultView: Boolean;
    begin
        POSSession.GetCurrentView(CurrentView);
        InSale := CurrentView.GetType() in [CurrentView.GetType() ::Sale, CurrentView.GetType() ::Payment];
        ReturnToDefaultView := Context.GetBooleanParameter('ReturnToDefaultView');
        if InSale then
            BusinessLogic.UpdateSaleAfterSplit(Sale, WaiterPadNo, ReturnToDefaultView, CleanupMessageText);
        if ReturnToDefaultView then
            Sale.SelectViewForEndOfSale(POSSession)
        else
            if CleanupMessageText <> '' then
                Context.SetContext('CleanupMessageText', CleanupMessageText);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPREPOSActionSplitBill.js###
'let main=async({workflow:a,popup:i,parameters:s,context:e,captions:t})=>{debugger;if(await a.respond("AddPresetValuesToContext"),!e.seatingCode)if(e.seatingCode="",s.SeatingCode)e.seatingCode=s.SeatingCode;else switch(s.InputType+""){case"0":e.seatingCode=await i.input({caption:t.SeatingIDLbl});break;case"1":e.seatingCode=await i.numpad({caption:t.SeatingIDLbl});break;case"2":await a.respond("SelectSeating");break}!e.seatingCode||(e.waiterPadNo||await a.respond("SelectWaiterPad"),e.waiterPadNo&&(await a.respond("GenerateSplitBillContext"),console.log("Context: "+JSON.stringify(e)),result=await i.hospitality.splitBill({caption:t.PopupCaption,waiterPadNo:e.waiterPadNo,items:e.items,bills:e.bills}),result&&await a.respond("DoSplit",result),e.CleanupMessageText&&i.message(e.CleanupMessageText)))};'
        );
    end;
}
