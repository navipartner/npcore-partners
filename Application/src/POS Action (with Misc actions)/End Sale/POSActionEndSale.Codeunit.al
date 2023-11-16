codeunit 6184623 "NPR POS Action End Sale" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built in function ends the pos sale';
        EndSaleWithBalancingDescriptionLbl: Label 'Ends the sale with balancing.';
        EndSaleWithBalancingNameLbl: Label 'End Sale with Balancing';
        PaymentMethodCodeDescriptionLbl: Label 'The Payment Method Code with which the transaction is going to be ended.';
        PaymentMethodCodeNameLbl: Label 'Payment Method Code';
        selectViewForEndOfSaleDescriptionLbl: Label 'Select view for end of sale without starting a new sale';
        selectViewForEndOfSaleNameLbl: Label 'Select View for End of Sale without start sale';
        StartNewSaleDescriptionLbl: Label 'Starts new sale after the sale was ended without balancing.';
        StartNewSaleNameLbl: Label 'Start New Sale';
        CalledFromWorkflowDescriptionLbl: Label 'The workflow name from where end of sale was called.';
        CalledFromWorkflowNameLbl: Label 'Called from workflow.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.SetDataBinding();
        WorkflowConfig.AddTextParameter('paymentNo', '', PaymentMethodCodeNameLbl, PaymentMethodCodeDescriptionLbl);
        WorkflowConfig.AddBooleanParameter('endSaleWithBalancing', true, EndSaleWithBalancingNameLbl, EndSaleWithBalancingDescriptionLbl);
        WorkflowConfig.AddBooleanParameter('startNewSale', false, StartNewSaleNameLbl, StartNewSaleDescriptionLbl);
        WorkflowConfig.AddBooleanParameter('selectViewForEndOfSale', false, selectViewForEndOfSaleNameLbl, selectViewForEndOfSaleDescriptionLbl);
        WorkflowConfig.AddTextParameter('calledFromWorkflow', '', CalledFromWorkflowNameLbl, CalledFromWorkflowDescriptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'endSaleWithPreWorkflows':
                FrontEnd.WorkflowResponse(EndSaleWithPreWorkflows(Step, Context, FrontEnd, Sale, SaleLine, PaymentLine, Setup));
            'endSaleWithoutPreWorkflows':
                FrontEnd.WorkflowResponse(EndSaleWithoutPreWorkflows(Step, Context, FrontEnd, Sale, SaleLine, PaymentLine, Setup));
        end;
    end;

    local procedure EndSale(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") Success: Boolean;
    var
        POSActionEndSaleB: Codeunit "NPR POS Action End Sale B";
        POSSession: Codeunit "NPR POS Session";
        EndSaleWithBalancing: Boolean;
        SelectViewForEndOfSale: Boolean;
        StartNewSale: Boolean;
        PaymentMethodCodeText: Text;
    begin
        Context.GetStringParameter('paymentNo', PaymentMethodCodeText);
        Context.GetBooleanParameter('endSaleWithBalancing', EndSaleWithBalancing);
        Context.GetBooleanParameter('startNewSale', StartNewSale);
        Context.GetBooleanParameter('selectViewForEndOfSale', selectViewForEndOfSale);

#pragma warning disable AA0139
        Success := POSActionEndSaleB.EndSale(Sale, POSSession, StartNewSale, PaymentMethodCodeText, EndSaleWithBalancing, selectViewForEndOfSale);
#pragma warning restore ALAA0139
    end;

    local procedure EndSaleWithPreWorkflows(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup") Response: JsonObject
    var
        PreWorkflows: JsonObject;
    begin
        PreWorkflows := AddPreWorkflowsToRun(Step, Context, FrontEnd, Sale, SaleLine, PaymentLine, Setup);
        if PreWorkflows.Keys.Count <> 0 then begin
            Response.Add('preWorkflows', PreWorkflows);
            exit;
        end;

        Response := EndSaleWithoutPreWorkflows(Step, Context, FrontEnd, Sale, SaleLine, PaymentLine, Setup);
    end;

    local procedure EndSaleWithoutPreWorkflows(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup") Response: JsonObject
    var
        Success: Boolean;
        PostWorkflows: JsonObject;
    begin
        Success := EndSale(Context, Sale);
        Response.Add('success', Success);


        PostWorkflows := AddPostWorkflowsToRun(Step, Context, FrontEnd, Sale, SaleLine, PaymentLine, Setup, Success);
        Response.Add('postWorkflows', PostWorkflows);
    end;

    local procedure AddPreWorkflowsToRun(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup") PreWorkflows: JsonObject
    var
        EndSaleEvents: Codeunit "NPR End Sale Events";

    begin
        EndSaleEvents.OnAddPreWorkflowsToRun(Step, Context, FrontEnd, Sale, SaleLine, PaymentLine, Setup, PreWorkflows);
    end;

    local procedure AddPostWorkflowsToRun(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup"; EndSaleSuccess: Boolean) PostWorkflows: JsonObject
    var
        EndSaleEvents: Codeunit "NPR End Sale Events";
    begin
        EndSaleEvents.OnAddPostWorkflowsToRun(Step, Context, FrontEnd, Sale, SaleLine, PaymentLine, Setup, EndSaleSuccess, PostWorkflows);
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionEndSale.js###
'let main=async({workflow:e,popup:o,scope:t,parameters:a,context:r,runtime:s,data:f})=>{debugger;const{preWorkflows:n,postWorkflows:i}=await e.respond("endSaleWithPreWorkflows");if(n){await processWorkflows(n);const{postWorkflows:w}=await e.respond("endSaleWithoutPreWorkflows");await processWorkflows(w)}else await processWorkflows(i)};async function processWorkflows(e){if(e)for(const o of Object.entries(e)){let[t,a]=o;if(t){let{mainParameters:r,customParameters:s}=a;await workflow.run(t,{context:{customParameters:s},parameters:r})}}}'
        )
    end;
}

