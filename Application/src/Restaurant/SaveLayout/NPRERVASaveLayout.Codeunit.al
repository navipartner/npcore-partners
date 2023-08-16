codeunit 6150683 "NPR NPRE RVA: Save Layout" implements "NPR IPOS Workflow"
{
    Access = Internal;

    internal procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::RV_SAVE_LAYOUT));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action stores the restaurant layout from the front-end editor.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogic: Codeunit "NPR NPRE RVA: Save Layout-B";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        RestaurantCode: Code[20];
    begin
        RestaurantCode := '';
        BusinessLogic.SaveLayout(Context.GetString('layout'), RestaurantCode);
        if RestaurantCode <> '' then
            FrontendAssistant.SetRestaurant(POSSession, FrontEnd, RestaurantCode);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPRERVASaveLayout.js###
'let main=async({})=>await workflow.respond();'
        );
    end;
}
