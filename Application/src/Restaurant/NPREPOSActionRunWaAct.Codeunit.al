codeunit 6150676 "NPR NPRE POSAction: Run Wa.Act"
{
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'An action to run Waiter Pad functions';
        WPadNotSelectedErr: Label 'Please select a waiter pad first.';

    local procedure ActionCode(): Text
    begin
        exit('RUN_W/PAD_ACTION');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
                ActionCode(),
                ActionDescription,
                ActionVersion,
                Type::Generic,
                "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('RunWorkflowSteps', 'respond();');
                RegisterWorkflow(false);

                RegisterOptionParameter('WaiterPadAction', 'Print Pre-Receipt,Send Kitchen Order,Request Next Serving,Request Specific Serving,Merge Waiter Pad,Close w/out Saving', 'Print Pre-Receipt');
                RegisterOptionParameter('LinesToSend', 'New/Updated,All', 'New/Updated');
                RegisterTextParameter('ServingStep', '');
                RegisterBooleanParameter('MoveSaleToWPadOnFinish', false);
                RegisterBooleanParameter('ReturnToDefaultView', false);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalePOS: Record "NPR Sale POS";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad2: Record "NPR NPRE Waiter Pad";
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Close w/out Saving";
        WPadLinesToSend: Option "New/Updated",All;
        ServingStepToRequest: Code[10];
        ClearSaleOnFinish: Boolean;
        ReturnToDefaultView: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        WPadAction := JSON.GetIntegerParameter('WaiterPadAction', true);
        ClearSaleOnFinish := JSON.GetBooleanParameter('MoveSaleToWPadOnFinish', false);
        ReturnToDefaultView := JSON.GetBooleanParameter('ReturnToDefaultView', false);
        if ReturnToDefaultView then
            ClearSaleOnFinish := true;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if WPadAction <> WPadAction::"Close w/out Saving" then begin
            if SalePOS."NPRE Pre-Set Waiter Pad No." = '' then
                Error(WPadNotSelectedErr);
            WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, false);
            Commit;

            case WPadAction of
                WPadAction::"Print Pre-Receipt":
                    begin
                        RestaurantPrint.PrintWaiterPadPreReceiptPressed(WaiterPad);
                    end;

                WPadAction::"Send Kitchen Order":
                    begin
                        WPadLinesToSend := JSON.GetIntegerParameter('LinesToSend', false);
                        RestaurantPrint.PrintWaiterPadPreOrderToKitchenPressed(WaiterPad, WPadLinesToSend = WPadLinesToSend::All);
                    end;

                WPadAction::"Request Next Serving":
                    begin
                        RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, true, '');
                    end;

                WPadAction::"Request Specific Serving":
                    begin
                        ServingStepToRequest := JSON.GetStringParameter('ServingStep', false);
                        if ServingStepToRequest = '' then
                            if not LookupServingStep(ServingStepToRequest) then
                                Error('');
                        RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, false, ServingStepToRequest);
                    end;

                WPadAction::"Merge Waiter Pad":
                    begin
                        if not WaiterPadPOSMgt.SelectWaiterPadToMergeTo(WaiterPad, WaiterPad2) then
                            Error('');
                        POSSession.GetSaleLine(POSSaleLine);
                        POSSaleLine.DeleteAll;
                        WaiterPadMgt.MergeWaiterPad(WaiterPad, WaiterPad2);
                        WaiterPad := WaiterPad2;
                    end;
            end;
        end;

        if ClearSaleOnFinish or
           (WPadAction in [WPadAction::"Merge Waiter Pad", WPadAction::"Close w/out Saving"])
        then begin
            if WPadAction <> WPadAction::"Merge Waiter Pad" then begin
                POSSession.GetSaleLine(POSSaleLine);
                POSSaleLine.DeleteAll;
            end;

            SalePOS.Find;
            WaiterPadPOSMgt.ClearSaleHdrNPREPresetFields(SalePOS, false);
            POSSale.Refresh(SalePOS);
            POSSale.Modify(true, false);

            if (WPadAction = WPadAction::"Merge Waiter Pad") and not ClearSaleOnFinish then
                WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);

            if ReturnToDefaultView then
                POSSale.SelectViewForEndOfSale(POSSession);

            POSSession.RequestRefreshData();
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        SelectedServingStep: Code[10];
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ServingStep':
                begin
                    SelectedServingStep := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedServingStep));
                    if LookupServingStep(SelectedServingStep) then
                        POSParameterValue.Value := SelectedServingStep;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ServingStep':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    FlowStatus."Status Object" := FlowStatus."Status Object"::WaiterPadLineMealFlow;
                    FlowStatus.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(FlowStatus.Code));
                    if not FlowStatus.Find then begin
                        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
                        FlowStatus.SetFilter(Code, CopyStr(StrSubstNo('@%1*', POSParameterValue.Value), 1, MaxStrLen(FlowStatus.Code)));
                        FlowStatus.FindFirst;
                    end;
                    POSParameterValue.Value := FlowStatus.Code;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        CaptionLinesToSend: Label 'Lines to Send to Kitchen';
        CaptionMoveSaleToWPadOnFinish: Label 'Move Sale to W/Pad on Finish';
        CaptionReturnToDefaultView: Label 'Return to Default View on Finish';
        CaptionServingStep: Label 'Serving Step to Request';
        CaptionWaiterPadAction: Label 'Waiter Pad Action';
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'WaiterPadAction':
                Caption := CaptionWaiterPadAction;
            'LinesToSend':
                Caption := CaptionLinesToSend;
            'ServingStep':
                Caption := CaptionServingStep;
            'MoveSaleToWPadOnFinish':
                Caption := CaptionMoveSaleToWPadOnFinish;
            'ReturnToDefaultView':
                Caption := CaptionReturnToDefaultView;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        DescLinesToSend: Label 'Defines which waiter pad lines are to be sent to kitchen, if ''Send Kitchen Order'' is selected as Waiter Pad Action';
        DescMoveSaleToWPadOnFinish: Label 'Move POS sale lines to waiter pad after the Waiter Pad Action has completed';
        DescReturnToDefaultView: Label 'Switch to the default view defined for the POS Unit after the Waiter Pad Action has completed';
        DescServingStep: Label 'Defines which serving step is to be requested, if ''Request Specific Serving'' is selected as Waiter Pad Action';
        DescWaiterPadAction: Label 'Defines which waiter pad action is to be run by the POS action';
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'WaiterPadAction':
                Caption := DescWaiterPadAction;
            'LinesToSend':
                Caption := DescLinesToSend;
            'ServingStep':
                Caption := DescServingStep;
            'MoveSaleToWPadOnFinish':
                Caption := DescMoveSaleToWPadOnFinish;
            'ReturnToDefaultView':
                Caption := DescReturnToDefaultView;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', true, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        OptionLinesToSend: Label 'New/Updated,All';
        OptionWaiterPadAction: Label 'Print Pre-Receipt,Send Kitchen Order,Request Next Serving,Request Specific Serving,Merge Waiter Pad,Close w/out Saving';
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'WaiterPadAction':
                Caption := OptionWaiterPadAction;
            'LinesToSend':
                Caption := OptionLinesToSend;
        end;
    end;

    local procedure LookupServingStep(var SelectedServingStep: Code[10]): Boolean
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        FlowStatus.FilterGroup(2);
        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
        FlowStatus.FilterGroup(0);
        if SelectedServingStep <> '' then begin
            FlowStatus."Status Object" := FlowStatus."Status Object"::WaiterPadLineMealFlow;
            FlowStatus.Code := SelectedServingStep;
            if FlowStatus.Find('=><') then;
        end;
        if PAGE.RunModal(0, FlowStatus) = ACTION::LookupOK then begin
            SelectedServingStep := FlowStatus.Code;
            exit(true);
        end;
        exit(false);
    end;
}

