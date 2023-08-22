codeunit 6151288 "NPR SS Action - Sale Screen" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function changes to sale view';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        case Step of
            'ChangeToSaleView':
                Frontend.WorkflowResponse(ChangeToSaleView(POSSession));
        end;
    end;

    internal procedure ChangeToSaleView(POSSession: Codeunit "NPR POS Session"): JsonObject
    begin
        POSSession.ChangeViewSale();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSaleScreenSS.js###
'let main=async({})=>await workflow.respond("ChangeToSaleView");'
        )
    end;
}

