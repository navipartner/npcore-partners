codeunit 6184573 "NPR POSAction SS EFTReconcile" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'EFT Reconcile for Self Service';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        EftInterface: CodeUnit "NPR EFT Interface";
        ListOfWorkflows: Dictionary of [Text, JsonObject];
        WorkflowName: Text;
        WorkflowsArray: JsonArray;
        WorkflowContext: JsonObject;
    begin

        case Step of
            'GetEftIntegrationsForOnEndOfDay':
                begin
                    EftInterface.OnEndOfDayCloseEft(1, ListOfWorkflows);

                    //turn the dictionary into a pure JSON array for easier parsing in workflow JS:
                    foreach WorkflowName in ListOfWorkflows.Keys do begin
                        WorkflowContext := ListOfWorkflows.Get(WorkflowName);
                        WorkflowContext.Add('WorkflowName', WorkflowName);
                        WorkflowsArray.Add(WorkflowContext);
                    end;

                    FrontEnd.WorkflowResponse(WorkflowsArray);
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSEFTReconcile.js###    
'let main=async({workflow:e})=>{let t=await e.respond("GetEftIntegrationsForOnEndOfDay");debugger;for(var a=0;a<t.length;a++)await e.run(t[a].WorkflowName,{context:t[a]})};'
        );
    end;
}
