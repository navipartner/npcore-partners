codeunit 6059840 "NPR POS Action Take Photo" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a function for adding image using camera to a active POS Sale.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        TakePhoto(Sale);
    end;

    local procedure TakePhoto(POSSaleCU: Codeunit "NPR POS Sale"): JsonObject
    var
        POSSaleMediaInfo: Record "NPR POS Sale Media Info";
        POSSale: Record "NPR POS Sale";
    begin
        POSSaleCU.GetCurrentSale(POSSale);
        POSSaleMediaInfo.CreateNewEntry(POSSale, 1);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionTakePhoto.js###        
        'let main=async({})=>await workflow.respond();'
        );
    end;
}