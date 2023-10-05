codeunit 6150721 "NPR POS Action - Login" implements "NPR IPOS Workflow"
{
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescriptionLbl: Label 'This is a built-in action for completing the login request passed on from the front end.';

    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        ActionContext: JsonObject;
    begin
        case Step of
            'prepareWorkflow':
                FrontEnd.WorkflowResponse(OnAction(Context, FrontEnd, Setup, ActionContext));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionLogin.js###
'let main=async({workflow:r,context:l})=>{debugger;let e=await r.respond("prepareWorkflow");const a=e.preWorkflows;if(a)for(const o of Object.entries(a)){let[t,s]=o;if(t){let{mainParameters:m,customParameters:f}=s;await r.run(t,{context:{customParameters:f},parameters:m})}}e.workflowName!=""&&(e.workflowName=="START_POS"?await r.run(e.workflowName):await r.run(e.workflowName,{parameters:e.parameters}))};'
        )
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindSalesperson(var SalespersonPurchaser: Record "Salesperson/Purchaser")
    begin
    end;

    local procedure OnAction(var Context: Codeunit "NPR POS JSON Helper"; var FrontEnd: Codeunit "NPR POS Front End Management"; var Setup: Codeunit "NPR POS Setup"; var ActionContext: JsonObject) Response: JsonObject
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        BusinessLogic: Codeunit "NPR POS Action - Login-B";
        POSSession: Codeunit "NPR POS Session";
        Text001: Label 'Unknown login type requested by JavaScript: %1.';
        Password: Text;
        Type: Text;
        LoginEvents: Codeunit "NPR POS Login Events";
    begin
        Type := Context.GetString('type');

        Clear(SalespersonPurchaser);
        case Type of
            'SalespersonCode':
                begin
                    Password := Context.GetString('password');
                    if (DelChr(Password, '<=>', ' ') = '') then
                        Error('Illegal password.');

                    SalespersonPurchaser.SetRange("NPR Register Password", Password);

                    if ((SalespersonPurchaser.FindFirst() and (Password <> ''))) then begin
                        OnAfterFindSalesperson(SalespersonPurchaser);
                        Setup.SetSalesperson(SalespersonPurchaser);
                        BusinessLogic.OpenPosUnit(FrontEnd, Setup, POSSession, ActionContext);
                    end else begin
                        Error('Illegal password.');
                    end;
                end;
            else
                Error(Text001, Type);
        end;
        HandleWorkflowResponse(Response, ActionContext);
        Response.Add('preWorkflows', AddPreWorkflowsToRun(Context));
        LoginEvents.OnAfterLogin(POSSession);

        exit(Response);
    end;

    local procedure AddPreWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper") PreWorkflows: JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        LoginEvents: Codeunit "NPR POS Login Events";
        POSSession: Codeunit "NPR POS Session";
        POSFunctProfile: Record "NPR POS Functionality Profile";
    begin
        PreWorkflows.ReadFrom('{}');
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        if POSFunctProfile.Get(POSUnit."POS Functionality Profile") then begin

            if POSFunctProfile."Require Select Member" then
                AddMemberWorkflow(PreWorkflows);
            if POSFunctProfile."Require Select Customer" then
                AddCustomerWorkflow(PreWorkflows);
        end;
        LoginEvents.OnAddPreWorkflowsToRun(Context, SalePOS, PreWorkflows);
    end;

    local procedure AddMemberWorkflow(PreWorkflows: JsonObject)
    var
        ActionParameters: JsonObject;
        MainParameters: JsonObject;
        CustomParameters: JsonObject;
    begin
        MainParameters.Add('Function', 'Select Membership');
        MainParameters.Add('DialogPrompt', 'No Dialog');

        CustomParameters.Add('SelectionRequired', true);

        ActionParameters.Add('mainParameters', MainParameters);
        ActionParameters.Add('customParameters', CustomParameters);

        PreWorkflows.Add('MM_MEMBERMGMT_WF3', ActionParameters);
    end;

    local procedure AddCustomerWorkflow(var PreWorkflows: JsonObject)
    var
        ActionParameters: JsonObject;
        MainParameters: JsonObject;
        CustomParameters: JsonObject;
    begin
        MainParameters.Add('Operation', 'Attach');
        CustomParameters.Add('SelectionRequired', true);

        ActionParameters.Add('mainParameters', MainParameters);
        ActionParameters.Add('customParameters', CustomParameters);

        PreWorkflows.Add('CUSTOMER_SELECT', ActionParameters);
    end;

    internal procedure HandleWorkflowResponse(var Response: JsonObject; ActionContextIn: JsonObject): Boolean
    var
        Jobj: JsonObject;
        Jtoken: JsonToken;
    begin
        if not ActionContextIn.Get('name', Jtoken) then begin
            Response.Add('workflowName', '');
            exit(true);
        end;
        if Jtoken.AsValue().AsText() = '' then
            exit(true);

        Response.Add('workflowName', Jtoken.AsValue().AsText());

        ActionContextIn.Get('parameters', Jtoken);
        Jobj := Jtoken.AsObject();
        Response.Add('parameters', Jobj);
    end;
}
