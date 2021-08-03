codeunit 6150677 "NPR NPRE RVA: Run WPad Act."
{
    local procedure ActionCode(): Code[20]
    begin
        exit('RV_RUN_W/PAD_ACTION');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action");
    var
        ActionDescription: Label 'This built-in action allows to run Waiter Pad related functions directly from Restaurant View';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20('await workflow.respond();');

            Sender.RegisterTextParameter('WaiterPadCode', '');
            Sender.RegisterOptionParameter('WaiterPadAction', 'Print Pre-Receipt,Send Kitchen Order,Request Next Serving,Request Specific Serving,Merge Waiter Pad,Open Waiter Pad', 'Print Pre-Receipt');
            Sender.RegisterOptionParameter('LinesToSend', 'New/Updated,All', 'New/Updated');
            Sender.RegisterTextParameter('ServingStep', '');
            Sender.RegisterBooleanParameter('ReturnToDefaultView', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20(Action: Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        POSSale: Codeunit "NPR POS Sale";
        ReturnToDefaultView: Boolean;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        ReturnToDefaultView := Context.GetBooleanParameter('ReturnToDefaultView');

        RunWaiterPadAction(Context);

        if ReturnToDefaultView then begin
            POSSession.GetSale(POSSale);
            POSSale.SelectViewForEndOfSale(POSSession);
        end;

        POSSession.RequestRefreshData();
    end;

    local procedure RunWaiterPadAction(Context: Codeunit "NPR POS JSON Management");
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad2: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Open Waiter Pad";
        WPadLinesToSend: Option "New/Updated",All;
        ServingStepToRequest: Code[10];
        WPadIsOpenedInPOSSale: Label 'The waiter pad is opened in a POS sale at the moment and might have unsaved changes. Are you sure you want to continue on running the action?';
    begin
        WaiterPad."No." := CopyStr(Context.GetStringParameterOrFail('WaiterPadCode', ActionCode()), 1, MaxStrLen(WaiterPad."No."));
        WPadAction := Context.GetIntegerParameterOrFail('WaiterPadAction', ActionCode());

        WaiterPad.Find();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetFilter("Sale Retail ID", '<>%1', WaiterPadPOSMgt.GetNullGuid());
        if not WaiterPadLine.IsEmpty then
            if not Confirm(WPadIsOpenedInPOSSale, false) then
                Error('');

        case WPadAction of
            WPadAction::"Print Pre-Receipt":
                begin
                    RestaurantPrint.PrintWaiterPadPreReceiptPressed(WaiterPad);
                end;

            WPadAction::"Send Kitchen Order":
                begin
                    WPadLinesToSend := Context.GetIntegerParameter('LinesToSend');
                    RestaurantPrint.PrintWaiterPadPreOrderToKitchenPressed(WaiterPad, WPadLinesToSend = WPadLinesToSend::All);
                end;

            WPadAction::"Request Next Serving":
                begin
                    RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, true, '');
                end;

            WPadAction::"Request Specific Serving":
                begin
                    ServingStepToRequest := CopyStr(Context.GetStringParameter('ServingStep'), 1, MaxStrLen(ServingStepToRequest));
                    if ServingStepToRequest = '' then
                        if not LookupServingStep(ServingStepToRequest) then
                            Error('');
                    RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, false, ServingStepToRequest);
                end;

            WPadAction::"Merge Waiter Pad":
                begin
                    if not WaiterPadPOSMgt.SelectWaiterPadToMergeTo(WaiterPad, WaiterPad2) then
                        Error('');
                    WaiterPadMgt.MergeWaiterPad(WaiterPad, WaiterPad2);
                end;

            WPadAction::"Open Waiter Pad":
                begin
                    Page.Run(Page::"NPR NPRE Waiter Pad", WaiterPad);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean);
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value");
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        FlowStatusCodeLbl: Label '@%1*', Locked = true;
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
                    if not FlowStatus.Find() then begin
                        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
                        FlowStatus.SetFilter(Code, CopyStr(StrSubstNo(FlowStatusCodeLbl, POSParameterValue.Value), 1, MaxStrLen(FlowStatus.Code)));
                        FlowStatus.FindFirst();
                    end;
                    POSParameterValue.Value := FlowStatus.Code;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text);
    var
        CaptionLinesToSend: Label 'Lines to Send to Kitchen';
        CaptionReturnToDefaultView: Label 'Return to Default View on Finish';
        CaptionServingStep: Label 'Serving Step to Request';
        CaptionWaiterPadAction: Label 'Waiter Pad Action';
        CaptionWaiterPadCode: Label 'Waiter Pad Code';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'WaiterPadCode':
                Caption := CaptionWaiterPadCode;
            'WaiterPadAction':
                Caption := CaptionWaiterPadAction;
            'LinesToSend':
                Caption := CaptionLinesToSend;
            'ServingStep':
                Caption := CaptionServingStep;
            'ReturnToDefaultView':
                Caption := CaptionReturnToDefaultView;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text);
    var
        DescLinesToSend: Label 'Defines which waiter pad lines are to be sent to kitchen, if ''Send Kitchen Order'' is selected as Waiter Pad Action';
        DescReturnToDefaultView: Label 'Switch to the default view defined for the POS Unit after the Waiter Pad Action has completed';
        DescServingStep: Label 'Defines which serving step is to be requested, if ''Request Specific Serving'' is selected as Waiter Pad Action';
        DescWaiterPadAction: Label 'Defines which waiter pad action is to be run by the POS action';
        DescWaiterPadCode: Label 'Defines waiter pad number the action is to be run upon. The parameter is set automatically by the system on the runtime';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'WaiterPadCode':
                Caption := DescWaiterPadCode;
            'WaiterPadAction':
                Caption := DescWaiterPadAction;
            'LinesToSend':
                Caption := DescLinesToSend;
            'ServingStep':
                Caption := DescServingStep;
            'ReturnToDefaultView':
                Caption := DescReturnToDefaultView;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterOptionStringCaption', '', true, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text);
    var
        OptionLinesToSend: Label 'New/Updated,All';
        OptionWaiterPadAction: Label 'Print Pre-Receipt,Send Kitchen Order,Request Next Serving,Request Specific Serving,Merge Waiter Pad,Open Waiter Pad';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'WaiterPadAction':
                Caption := OptionWaiterPadAction;
            'LinesToSend':
                Caption := OptionLinesToSend;
        end;
    end;

    local procedure LookupServingStep(var SelectedServingStep: Code[10]): Boolean;
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
        if Page.RunModal(0, FlowStatus) = Action::LookupOK then begin
            SelectedServingStep := FlowStatus.Code;
            exit(true);
        end;
        exit(false);
    end;
}