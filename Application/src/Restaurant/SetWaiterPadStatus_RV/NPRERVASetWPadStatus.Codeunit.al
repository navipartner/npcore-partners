codeunit 6150684 "NPR NPRE RVA: Set WPad Status" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ParamStatusCodeLbl: Label 'StatusCode', MaxLength = 30, Locked = true;
        _ParamWaiterPadCodeLbl: Label 'WaiterPadCode', MaxLength = 30, Locked = true;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::"RV_SET_W/PAD_STATUS"));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action allows to set Waiter Pad status or serving step from both Restaurant and Sales View';
        ParamWaiterPadCode_CptLbl: Label 'Waiter Pad Code';
        ParamWaiterPadCode_DescLbl: Label 'Selected waiter pad code.';
        ParamStatusCode_CptLbl: Label 'Status Code';
        ParamStatusCode_DescLbl: Label 'Selected waiter pad status or serving step.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter(_ParamWaiterPadCodeLbl, '', ParamWaiterPadCode_CptLbl, ParamWaiterPadCode_DescLbl);
        WorkflowConfig.AddTextParameter(_ParamStatusCodeLbl, '', ParamStatusCode_CptLbl, ParamStatusCode_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogic: Codeunit "NPR NPRE RVA: Set WP Status-B";
        NewStatusParamValue: Text;
        ResultMessageText: Text;
        WaiterPadNoParamValue: Text;
    begin
        if not Context.GetStringParameter(_ParamStatusCodeLbl, NewStatusParamValue) or (NewStatusParamValue = '') then
            exit;
        if not Context.GetStringParameter(_ParamWaiterPadCodeLbl, WaiterPadNoParamValue) then
            WaiterPadNoParamValue := '';

        BusinessLogic.SetWaiterPadStatus(Sale, CopyStr(WaiterPadNoParamValue, 1, 20), CopyStr(NewStatusParamValue, 1, 10), ResultMessageText);

        Context.SetContext('ShowResultMessage', ResultMessageText <> '');
        Context.SetContext('ResultMessageText', ResultMessageText);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        SelectedFlowStatusCode: Code[10];
        SelectedWaiterPadNo: Code[20];
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            _ParamWaiterPadCodeLbl:
                begin
                    SelectedWaiterPadNo := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedWaiterPadNo));
                    if LookupWaiterPadNo(SelectedWaiterPadNo) then
                        POSParameterValue.Value := SelectedWaiterPadNo;
                end;
            _ParamStatusCodeLbl:
                begin
                    SelectedFlowStatusCode := CopyStr(POSParameterValue.Value, 1, MaxStrLen(SelectedFlowStatusCode));
                    if LookupFlowStatus(SelectedFlowStatusCode) then
                        POSParameterValue.Value := SelectedFlowStatusCode;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        CodeFilterTok: Label '@%1*', Locked = true;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            _ParamWaiterPadCodeLbl:
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    WaiterPad."No." := CopyStr(POSParameterValue.Value, 1, MaxStrLen(WaiterPad."No."));
                    if not WaiterPad.Find() then begin
                        WaiterPad.SetFilter("No.", CopyStr(StrSubstNo(CodeFilterTok, POSParameterValue.Value), 1, MaxStrLen(WaiterPad."No.")));
                        WaiterPad.FindFirst();
                    end;
                    POSParameterValue.Value := WaiterPad."No.";
                end;
            _ParamStatusCodeLbl:
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPad, FlowStatus."Status Object"::WaiterPadLineMealFlow);
                    FlowStatus.SetRange(Code, CopyStr(POSParameterValue.Value, 1, MaxStrLen(FlowStatus.Code)));
                    if not FlowStatus.FindFirst() then begin
                        FlowStatus.SetFilter(Code, CopyStr(StrSubstNo(CodeFilterTok, POSParameterValue.Value), 1, MaxStrLen(FlowStatus.Code)));
                        FlowStatus.FindFirst();
                    end;
                    POSParameterValue.Value := FlowStatus.Code;
                end;
        end;
    end;

    local procedure LookupFlowStatus(var SelectedFlowStatus: Code[10]): Boolean
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        FlowStatus.FilterGroup(2);
        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPad, FlowStatus."Status Object"::WaiterPadLineMealFlow);
        FlowStatus.FilterGroup(0);
        if SelectedFlowStatus <> '' then begin
            FlowStatus.Code := SelectedFlowStatus;
            if FlowStatus.Find('=><') then;
        end;
        if Page.RunModal(0, FlowStatus) = Action::LookupOK then begin
            SelectedFlowStatus := FlowStatus.Code;
            exit(true);
        end;
        exit(false);
    end;

    local procedure LookupWaiterPadNo(var SelectedWaiterPadNo: Code[20]): Boolean
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        if SelectedWaiterPadNo <> '' then begin
            WaiterPad."No." := SelectedWaiterPadNo;
            if WaiterPad.Find('=><') then;
        end;
        if Page.RunModal(0, WaiterPad) = Action::LookupOK then begin
            SelectedWaiterPadNo := WaiterPad."No.";
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPRERVASetWPadStatus.js###
'let main=async({workflow:s,context:e,popup:a})=>{await s.respond(),e.ShowResultMessage&&a.message(e.ResultMessageText)};'
        );
    end;
}
