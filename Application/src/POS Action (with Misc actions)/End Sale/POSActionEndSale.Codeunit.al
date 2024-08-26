codeunit 6184623 "NPR POS Action End Sale" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built in function ends the pos sale';
        CalledFromWorkflowDescriptionLbl: Label 'The workflow name from where end of sale was called';
        CalledFromWorkflowNameLbl: Label 'Called from Workflow';
        EndSaleWithBalancingDescriptionLbl: Label 'Ends the sale with balancing';
        EndSaleWithBalancingNameLbl: Label 'End Sale with Balancing';
        PaymentMethodCodeDescriptionLbl: Label 'The Payment Method Code with which the transaction is going to be ended';
        PaymentMethodCodeNameLbl: Label 'Payment Method Code';
        SelectViewForEndOfSaleDescriptionLbl: Label 'Select view for end of sale without starting a new sale';
        SelectViewForEndOfSaleNameLbl: Label 'Select View for End of Sale';
        StartNewSaleDescriptionLbl: Label 'Starts new sale after the sale was ended without balancing';
        StartNewSaleNameLbl: Label 'Start New Sale';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.SetDataBinding();
        WorkflowConfig.AddTextParameter('paymentNo', '', PaymentMethodCodeNameLbl, PaymentMethodCodeDescriptionLbl);
        WorkflowConfig.AddBooleanParameter('endSaleWithBalancing', true, EndSaleWithBalancingNameLbl, EndSaleWithBalancingDescriptionLbl);
        WorkflowConfig.AddBooleanParameter('startNewSale', false, StartNewSaleNameLbl, StartNewSaleDescriptionLbl);
        WorkflowConfig.AddBooleanParameter('selectViewForEndOfSale', false, SelectViewForEndOfSaleNameLbl, SelectViewForEndOfSaleDescriptionLbl);
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
        Context.GetBooleanParameter('selectViewForEndOfSale', SelectViewForEndOfSale);

#pragma warning disable AA0139
        Success := POSActionEndSaleB.EndSale(Sale, POSSession, StartNewSale, PaymentMethodCodeText, EndSaleWithBalancing, SelectViewForEndOfSale);
#pragma warning restore AA0139
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
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        WaiterPadPOSMgt.AddSaveToWPadAndRequestNextServingWorkflow(Sale, Setup, PreWorkflows, Context);
        EndSaleEvents.OnAddPreWorkflowsToRun(Step, Context, FrontEnd, Sale, SaleLine, PaymentLine, Setup, PreWorkflows);
    end;

    local procedure AddPostWorkflowsToRun(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup"; EndSaleSuccess: Boolean) PostWorkflows: JsonObject
    var
        EndSaleEvents: Codeunit "NPR End Sale Events";
        DrawerStatus: Codeunit "NPR POS Action: Drawer Status";
    begin
        if EndSaleSuccess then begin
            AddDigitalReceiptWorkflow(Sale, PostWorkflows);
            DrawerStatus.AddCashDrawerStatusWorkflow(PostWorkflows, Setup);
        end;
        EndSaleEvents.OnAddPostWorkflowsToRun(Step, Context, FrontEnd, Sale, SaleLine, PaymentLine, Setup, EndSaleSuccess, PostWorkflows);
    end;

    local procedure AddDigitalReceiptWorkflow(Sale: Codeunit "NPR POS Sale"; var PostWorkflows: JsonObject)
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        POSReceiptProfile: Record "NPR POS Receipt Profile";
    begin
        Sale.GetLastSalePOSEntry(POSEntry);

        POSUnit.SetLoadFields("POS Receipt Profile");
        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit;
        POSReceiptProfile.SetLoadFields("Enable Digital Receipt");
        if not POSReceiptProfile.Get(POSUnit."POS Receipt Profile") then
            exit;
        if not POSReceiptProfile."Enable Digital Receipt" then
            exit;

        if not (POSEntry."Entry Type" in [POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Cancelled Sale"]) then
            exit;

        PostWorkflows.Add('ISSUE_DIG_RCPT', '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        POSActionEndSaleB: Codeunit "NPR POS Action End Sale B";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'paymentNo':
                POSActionEndSaleB.LookUpPaymentNoParameter(POSParameterValue);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        POSActionEndSaleB: Codeunit "NPR POS Action End Sale B";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'paymentNo':
                POSActionEndSaleB.ValidatePaymentNoParameter(POSParameterValue);
        end;
    end;

    local procedure ActionCode(): Text[20]
    begin
        exit('END_SALE');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionEndSale.js###
'const main=async({workflow:a})=>{let e,o;({preWorkflows:o,postWorkflows:e}=await a.respond("endSaleWithPreWorkflows")),o&&(await processWorkflows(o),{postWorkflows:e}=await a.respond("endSaleWithoutPreWorkflows")),await processWorkflows(e)};async function processWorkflows(a){if(a)for(const[e,{mainParameters:o,customParameters:r}]of Object.entries(a))await workflow.run(e,{context:{customParameters:r},parameters:o})}'
        )
    end;
}

