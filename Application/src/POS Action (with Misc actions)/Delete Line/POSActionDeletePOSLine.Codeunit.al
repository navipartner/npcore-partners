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
        case Step of
            'preparePreWorkflows':
                FrontEnd.WorkflowResponse(PreparePreWorkflows(Context, Sale, POSSession, SaleLine, PaymentLine));
            'deleteLine':
                DeletePosLine(POSSession, Context);
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionDeleteLine.js###
        'let main=async({workflow:e,parameters:t,captions:r})=>{if("payment"===e.scope.view)var a=runtime.getData("BUILTIN_PAYMENTLINE");else a=runtime.getData("BUILTIN_SALELINE");if(!a.length||a._invalid)return void await popup.error(r.notallowed);if(t.ConfirmDialog&&!await popup.confirm({title:r.title,caption:r.Prompt.substitute(a._current[10])}))return;let{preWorkflows:o}=await e.respond("preparePreWorkflows");await processWorkflows(o),await e.respond("deleteLine")};async function processWorkflows(e){if(e)for(const[t,{mainParameters:r,customParameters:a}]of Object.entries(e))await workflow.run(t,{context:{customParameters:a},parameters:r})}'
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
