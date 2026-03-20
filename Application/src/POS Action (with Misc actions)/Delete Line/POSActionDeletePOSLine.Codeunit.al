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
        WorkflowConfig.AddLabel('notAllowed', NotAllowedLbl);
        WorkflowConfig.AddLabel('Prompt', PromptLbl);
        WorkflowConfig.SetNonBlockingUI();
        WorkflowConfig.HideSelectedLineOnClick();
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
        Response: JsonObject;
    begin
        case Step of
            'deleteOrGetPreWorkflows':
                begin
                    Response := PreparePreWorkflows(Context, Sale, POSSession, SaleLine, PaymentLine);
                    if not ResponseContainsPreWorkflows(Response) then
                        DeletePosLine(POSSession, SaleLine, PaymentLine);
                    FrontEnd.WorkflowResponse(Response)
                end;
            'deleteLineAfterPreWorkflows':
                DeletePosLine(POSSession, SaleLine, PaymentLine);
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionDeleteLine.js###
        'let main=async({workflow:t,parameters:n,captions:r})=>{let e;switch(t.scope.view){case"payment":e=runtime.getData("BUILTIN_PAYMENTLINE");break;default:e=runtime.getData("BUILTIN_SALELINE")}if(!e.length||e._invalid){await popup.error(r.notAllowed);return}if(n.ConfirmDialog&&!await popup.confirm({title:r.title,caption:r.Prompt.substitute(e._current[10])}))return;const{preWorkflows:a}=await t.respond("deleteOrGetPreWorkflows");!a||Object.keys(a).length===0||(await processWorkflows(t,a),await t.respond("deleteLineAfterPreWorkflows"))};async function processWorkflows(t,n){if(n)for(const[r,{mainParameters:e,customParameters:a}]of Object.entries(n))await t.run(r,{context:{customParameters:a},parameters:e})}'
        )
    end;

    local procedure PreparePreWorkflows(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; POSSession: Codeunit "NPR POS Session"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line") Response: JsonObject
    var
        POSActionPublishers: Codeunit "NPR POS Action Publishers";
        PreWorkflows: JsonObject;
    begin
        PreWorkflows.ReadFrom('{}');
        POSActionPublishers.OnAddPreWorkflowsToRunOnDeletePOSLine(Context, Sale, POSSession, SaleLine, PaymentLine, PreWorkflows);
        Response.Add('preWorkflows', PreWorkflows);
    end;

    local procedure DeletePosLine(POSSession: Codeunit "NPR POS Session"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line")
    var
        CurrentView: Codeunit "NPR POS View";
        DeletePOSLineB: Codeunit "NPR POSAct:Delete POS Line-B";
    begin
        if (not POSSession.IsInitialized()) then
            exit;

        POSSession.GetCurrentView(CurrentView);

        if (CurrentView.GetType() = CurrentView.GetType() ::Sale) then begin
            if (not SaleLine.RefreshCurrent()) then
                exit;

            OnBeforeDeleteSaleLinePOS(SaleLine);
            DeletePOSLineB.DeleteSaleLine(SaleLine);
        end;

        if (CurrentView.GetType() = CurrentView.GetType() ::Payment) then begin
            if (not PaymentLine.RefreshCurrent()) then
                exit;

            DeletePOSLineB.DeletePaymentLine(PaymentLine);
        end;
    end;


    local procedure ResponseContainsPreWorkflows(Response: JsonObject): Boolean
    var
        PreWorkflows: JsonToken;
        PreWorkflowKeys: List of [Text];
    begin
        if Response.SelectToken('preWorkflows', PreWorkflows) then begin
            PreWorkflowKeys := PreWorkflows.AsObject().Keys();
            exit(PreWorkflowKeys.Count > 0)
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
        POSSession: Codeunit "NPR POS Session";
        POSView: Codeunit "NPR POS View";
    begin
        POSSession.GetCurrentView(POSView);
        Response.Add('viewType', Format(POSView.GetType()));
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDeleteSaleLinePOS(POSSaleLine: Codeunit "NPR POS Sale Line")
    begin
    end;
}
