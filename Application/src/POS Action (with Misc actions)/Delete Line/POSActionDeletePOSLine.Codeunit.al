codeunit 6150796 "NPR POSAction: Delete POS Line" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This built in function deletes sales or payment line from the POS';
        ConfirmParamCpt: Label 'Confirm Dialog';
        TitleLbl: Label 'Delete Line';
        PromptLbl: Label 'Are you sure you want to delete the line %1?';
        NotAllowedLbl: Label 'This line can''t be deleted.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddBooleanParameter('ConfirmDialog', false, ConfirmParamCpt, ConfirmParamCpt);
        WorkflowConfig.AddLabel('title', TitleLbl);
        WorkflowConfig.AddLabel('notallowed', NotAllowedLbl);
        WorkflowConfig.AddLabel('Prompt', PromptLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        DeletePosLine(POSSession, Context);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionDeleteLine.js###
'let main=async({workflow:a,parameters:i,captions:e})=>{debugger;switch(a.scope.view){case"payment":var t=runtime.getData("BUILTIN_PAYMENTLINE");break;default:var t=runtime.getData("BUILTIN_SALELINE")}if(!t.length||t._invalid){await popup.error(e.notallowed);return}i.ConfirmDialog&&!await popup.confirm({title:e.title,caption:e.Prompt.substitute(t._current[10])})||await a.respond()};'
        )
    end;

    local procedure DeletePosLine(POSSession: Codeunit "NPR POS Session"; Context: Codeunit "NPR POS JSON Helper")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CurrentView: Codeunit "NPR POS View";
        DeletePOSLineB: Codeunit "NPR POSAct:Delete POS Line-B";
    begin
        POSSession.GetCurrentView(CurrentView);

        if (CurrentView.GetType() = CurrentView.GetType() ::Sale) then begin
            POSSession.GetSaleLine(POSSaleLine);
            SetPositionForPOSSaleLine(Context, POSSaleLine);
            OnBeforeDeleteSaleLinePOS(POSSaleLine);
            DeletePOSLineB.DeleteSaleLine(POSSaleLine);
        end;

        if (CurrentView.GetType() = CurrentView.GetType() ::Payment) then begin
            DeletePOSLineB.DeletePaymentLine();
        end;
    end;

    internal procedure SetPositionForPOSSaleLine(Context: Codeunit "NPR POS JSON Helper"; var POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        Position: Text;
    begin
        Position := Context.GetPositionFromDataSource(POSDataMgt.POSDataSource_BuiltInSaleLine());
        IF Position <> '' then
            POSSaleLine.SetPosition(Position);
    end;

    [Obsolete('Not Used', '2023-07-28')]
    procedure GetCurrentViewType() Response: JsonObject;
    var
        NPRPOSSession: Codeunit "NPR POS Session";
        NPRPOSView: Codeunit "NPR POS View";
    begin
        NPRPOSSession.GetCurrentView(NPRPOSView);
        Response.Add('viewType', Format(NPRPOSView.GetType()));
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDeleteSaleLinePOS(POSSaleLine: Codeunit "NPR POS Sale Line")
    begin
    end;
}
